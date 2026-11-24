extends RefCounted
## Tests for attack and parry rules (issue #10, Memo's decisions):
## tap = light, hold = heavy, dodge cancels, light parry window 0.1 s before
## the enemy hit, heavy parry only at the same moment, must face the
## attacker, a parrying swing deals no damage.

const STEP: float = 1.0 / 60.0
const IN_FRONT: Vector3 = Vector3.FORWARD
const BEHIND: Vector3 = Vector3.BACK
const HIT_DAMAGE: int = 30


func _tick(combat: PlayerCombat, seconds: float) -> void:
	var frames := int(round(seconds / STEP))
	for i in frames:
		combat.tick(STEP)


func _tap(combat: PlayerCombat) -> void:
	combat.press_attack()
	combat.tick(STEP)
	combat.release_attack()


func _make_player() -> Player:
	var player := Player.new()
	player.combat = PlayerCombat.new()
	player.health = Health.new()
	return player


func _free_player(player: Player) -> void:
	player.combat.free()
	player.health.free()
	player.free()


func test_tap_gives_light_attack() -> String:
	var combat := PlayerCombat.new()
	_tap(combat)
	var result := combat.kind
	combat.free()
	return "" if result == PlayerCombat.Kind.LIGHT else "a tap did not give a light attack"


func test_hold_gives_heavy_attack() -> String:
	var combat := PlayerCombat.new()
	combat.press_attack()
	_tick(combat, combat.heavy_hold_time + STEP)
	var charged := combat.is_charged()
	combat.release_attack()
	var result := combat.kind
	combat.free()
	if not charged:
		return "holding past heavy_hold_time did not charge"
	return "" if result == PlayerCombat.Kind.HEAVY else "a hold did not give a heavy attack"


func test_light_parry_inside_window_takes_no_damage() -> String:
	var player := _make_player()
	player.combat.press_attack()
	_tick(player.combat, 0.05)
	var was_parried := player.resolve_hit(IN_FRONT, HIT_DAMAGE)
	var hp := player.health.current
	var max_hp := player.health.max_health
	_free_player(player)
	if not was_parried:
		return "press 0.05 s before the hit should parry"
	return "" if hp == max_hp else "parried hit still did damage (%d/%d)" % [hp, max_hp]


func test_light_press_too_early_takes_damage() -> String:
	var player := _make_player()
	player.combat.press_attack()
	_tick(player.combat, 0.15)
	var was_parried := player.resolve_hit(IN_FRONT, HIT_DAMAGE)
	var hp := player.health.current
	var expected := player.health.max_health - HIT_DAMAGE
	_free_player(player)
	if was_parried:
		return "press 0.15 s before the hit should not parry (window is 0.1 s)"
	return "" if hp == expected else "expected %d HP after the hit, got %d" % [expected, hp]


func test_parry_needs_facing_the_attacker() -> String:
	var player := _make_player()
	player.combat.press_attack()
	_tick(player.combat, 0.05)
	var was_parried := player.resolve_hit(BEHIND, HIT_DAMAGE)
	_free_player(player)
	return "" if not was_parried else "a hit from behind was parried"


func test_heavy_parry_only_at_the_same_moment() -> String:
	var combat := PlayerCombat.new()
	var landed: Array[float] = []
	combat.strike_landed.connect(func(_k: PlayerCombat.Kind) -> void: landed.append(0.0))
	combat.press_attack()
	_tick(combat, combat.heavy_hold_time + STEP)
	combat.release_attack()
	while landed.is_empty():
		combat.tick(STEP)
	var same_moment := combat.try_parry(IN_FRONT, IN_FRONT)
	combat.free()

	var late := PlayerCombat.new()
	var landed_late: Array[float] = []
	late.strike_landed.connect(func(_k: PlayerCombat.Kind) -> void: landed_late.append(0.0))
	late.press_attack()
	_tick(late, late.heavy_hold_time + STEP)
	late.release_attack()
	while landed_late.is_empty():
		late.tick(STEP)
	_tick(late, 0.06)
	var too_late := late.try_parry(IN_FRONT, IN_FRONT)
	late.free()

	if not same_moment:
		return "heavy strike landing with the hit should parry"
	return "" if not too_late else "heavy strike 0.06 s before the hit should not parry"


func test_heavy_charge_alone_does_not_parry() -> String:
	var combat := PlayerCombat.new()
	combat.press_attack()
	_tick(combat, combat.heavy_hold_time + 0.1)
	var was_parried := combat.try_parry(IN_FRONT, IN_FRONT)
	combat.free()
	return "" if not was_parried else "holding a charge (no strike yet) parried"


func test_parrying_swing_deals_no_damage() -> String:
	var combat := PlayerCombat.new()
	var results: Array[bool] = []
	combat.strike_resolved.connect(
		func(_k: PlayerCombat.Kind, deals: bool) -> void: results.append(deals)
	)
	_tap(combat)
	combat.try_parry(IN_FRONT, IN_FRONT)
	_tick(combat, 1.0)
	combat.free()
	if results.size() != 1:
		return "expected one resolved strike, got %d" % results.size()
	return "" if results[0] == false else "the parrying swing dealt damage"


func test_normal_swing_deals_damage() -> String:
	var combat := PlayerCombat.new()
	var results: Array[bool] = []
	combat.strike_resolved.connect(
		func(_k: PlayerCombat.Kind, deals: bool) -> void: results.append(deals)
	)
	_tap(combat)
	_tick(combat, 1.0)
	combat.free()
	if results.size() != 1:
		return "expected one resolved strike, got %d" % results.size()
	return "" if results[0] == true else "a normal swing dealt no damage"


func test_parry_starts_bonus_window() -> String:
	var combat := PlayerCombat.new()
	_tap(combat)
	combat.try_parry(IN_FRONT, IN_FRONT)
	var active := combat.is_bonus_active()
	_tick(combat, combat.parry_bonus_duration + 0.1)
	var after := combat.is_bonus_active()
	combat.free()
	if not active:
		return "parry did not start the bonus window"
	return "" if not after else "bonus window did not end"


func test_dodge_cancels_attack() -> String:
	var player := _make_player()
	var results: Array[bool] = []
	player.combat.strike_resolved.connect(
		func(_k: PlayerCombat.Kind, deals: bool) -> void: results.append(deals)
	)
	_tap(player.combat)
	var dodged := player.start_dodge(Vector3.RIGHT)
	var busy := player.combat.is_busy()
	_tick(player.combat, 1.0)
	_free_player(player)
	if not dodged:
		return "dodge did not start during the attack"
	if busy:
		return "attack was still running after the dodge"
	return "" if results.is_empty() else "a cancelled attack still landed"


func test_attack_buffered_during_recovery() -> String:
	var combat := PlayerCombat.new()
	var started: Array[int] = []
	combat.attack_started.connect(func(k: PlayerCombat.Kind) -> void: started.append(k))
	_tap(combat)
	# Run until a few frames before the swing ends, then press again.
	var total := combat.light_windup + combat.light_active + combat.light_recovery
	_tick(combat, total - 0.05)
	combat.press_attack()
	_tick(combat, 0.1)
	var second_started := combat.phase == PlayerCombat.Phase.CHARGING
	combat.free()
	return "" if second_started else "attack pressed near the end did not come out"


func test_dodge_buffered_near_cooldown_end() -> String:
	var player := Player.new()
	player.start_dodge(Vector3.FORWARD)
	while player.state == Player.State.DODGING:
		player.tick_dodge(STEP)
	# Cooldown almost over: press dodge 0.05 s early.
	player.tick_cooldown(player.dodge_cooldown - 0.05)
	var now := player.request_dodge(Vector3.LEFT)
	var later := false
	for i in 10:
		player.tick_cooldown(STEP)
		player.tick_dodge_buffer(STEP)
		if player.state == Player.State.DODGING:
			later = true
			break
	player.free()
	if now:
		return "dodge started while still on cooldown"
	return "" if later else "buffered dodge did not come out when the cooldown ended"


func test_health_damage_and_death() -> String:
	var health := Health.new()
	var deaths: Array[int] = []
	health.died.connect(func() -> void: deaths.append(1))
	health.damage(health.max_health + 50)
	var hp := health.current
	health.damage(10)
	health.free()
	if hp != 0:
		return "health went to %d instead of 0" % hp
	return "" if deaths.size() == 1 else "died emitted %d times" % deaths.size()
