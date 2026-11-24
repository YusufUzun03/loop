extends RefCounted
## Tests for the training enemy (issue #11): hit areas of its three attacks,
## parryable vs not, chasing, death and respawn.

const ORIGIN: Vector3 = Vector3.ZERO
const FORWARD: Vector3 = Vector3.FORWARD
const STEP: float = 1.0 / 60.0
const HIT_DAMAGE: int = 20


func test_swing_hits_in_front_only() -> String:
	var in_front := TestEnemy.swing_hits(ORIGIN, FORWARD, Vector3(0, 0, -2), 2.6, 70.0)
	var behind := TestEnemy.swing_hits(ORIGIN, FORWARD, Vector3(0, 0, 2), 2.6, 70.0)
	var too_far := TestEnemy.swing_hits(ORIGIN, FORWARD, Vector3(0, 0, -4), 2.6, 70.0)
	if not in_front:
		return "swing missed a target right in front"
	if behind:
		return "swing hit a target behind the enemy"
	return "" if not too_far else "swing hit a target out of reach"


func test_sweep_spares_the_safe_side() -> String:
	# Enemy looks down -Z, so its right is +X.
	var right_point := Vector3(1.5, 0, -1)
	var left_point := Vector3(-1.5, 0, -1)
	var right_safe := TestEnemy.SweepSide.RIGHT
	var hits_right := TestEnemy.sweep_hits(ORIGIN, FORWARD, right_point, 3.5, right_safe)
	var hits_left := TestEnemy.sweep_hits(ORIGIN, FORWARD, left_point, 3.5, right_safe)
	if hits_right:
		return "sweep hit the safe (right) side"
	return "" if hits_left else "sweep missed the unsafe (left) side"


func test_sweep_misses_out_of_reach() -> String:
	var far := TestEnemy.sweep_hits(
		ORIGIN, FORWARD, Vector3(-5, 0, 0), 3.5, TestEnemy.SweepSide.RIGHT
	)
	return "" if not far else "sweep hit a target out of reach"


func test_shockwave_hits_on_ground() -> String:
	var hit := TestEnemy.shockwave_hits(2.0, 2.2, 2.1, 0.0, 0.4)
	return "" if hit else "ring passing a standing target did not hit"


func test_shockwave_misses_when_jumping() -> String:
	var hit := TestEnemy.shockwave_hits(2.0, 2.2, 2.1, 1.0, 0.4)
	return "" if not hit else "ring hit a target that was in the air"


func test_shockwave_only_where_ring_is() -> String:
	var hit := TestEnemy.shockwave_hits(2.0, 2.2, 5.0, 0.0, 0.4)
	return "" if not hit else "ring hit a target it had not reached yet"


func test_chase_walks_toward_target() -> String:
	var velocity := TestEnemy.chase_velocity(ORIGIN, Vector3(3, 5, 4), 3.0)
	if not is_equal_approx(velocity.length(), 3.0):
		return "chase speed was %.2f, expected 3" % velocity.length()
	if not is_zero_approx(velocity.y):
		return "chase should stay flat"
	return "" if velocity.normalized().is_equal_approx(Vector3(0.6, 0, 0.8)) else "wrong direction"


func test_unparryable_hit_hurts_even_with_good_timing() -> String:
	var player := Player.new()
	player.combat = PlayerCombat.new()
	player.health = Health.new()
	player.combat.press_attack()
	player.combat.tick(0.05)
	var was_parried := player.resolve_hit(FORWARD, HIT_DAMAGE, false)
	var hp := player.health.current
	var expected := player.health.max_health - HIT_DAMAGE
	player.combat.free()
	player.health.free()
	player.free()
	if was_parried:
		return "a sweep/shockwave hit was parried"
	return "" if hp == expected else "expected %d HP, got %d" % [expected, hp]


func test_enemy_dies_and_respawns() -> String:
	var enemy := TestEnemy.new()
	enemy.health = Health.new()
	enemy.health.died.connect(enemy._on_died)
	var respawns: Array[int] = []
	enemy.respawned.connect(func() -> void: respawns.append(1))
	enemy.take_damage(enemy.health.max_health)
	var dead := enemy.state == TestEnemy.State.DEAD
	var frames := int(ceil(enemy.respawn_time / STEP)) + 1
	for i in frames:
		enemy.tick_respawn(STEP)
	var back := enemy.state == TestEnemy.State.CHASE
	var hp := enemy.health.current
	var max_hp := enemy.health.max_health
	enemy.health.free()
	enemy.free()
	if not dead:
		return "enemy did not die at 0 HP"
	if not back or respawns.size() != 1:
		return "enemy did not respawn after respawn_time"
	return "" if hp == max_hp else "respawned enemy had %d/%d HP" % [hp, max_hp]


func test_attack_ids_are_unique() -> String:
	var ids: Array = TestEnemy.ATTACK_IDS.values()
	var unique := {}
	for id in ids:
		unique[id] = true
	if ids.size() != TestEnemy.Attack.size():
		return "every attack needs an id for the run record"
	return "" if unique.size() == ids.size() else "attack ids are not unique"
