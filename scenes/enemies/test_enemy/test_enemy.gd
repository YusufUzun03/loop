class_name TestEnemy
extends CharacterBody3D
## A training enemy for trying dodge, jump and parry (issue #11).
##
## It walks straight at its target and, once close, picks one of three
## attacks (Memo, decided):
##   swing      can be parried; its weapon glows brighter until the hit
##   sweep      can't be parried; one side is safe, the other glows magenta
##   shockwave  can't be parried; a magenta ring spreads, jump over it
## Danger warnings on the floor are magenta (Memo, decided). Every number is
## @export so it can be tuned in the Inspector.
##
## It walks in a straight line: no pathfinding around pillars yet. That comes
## with the maze.

## The attack is announced: the tell (glow, floor warning) starts now.
signal attack_telegraphed(attack_id: StringName)
## The attack reached its hit moment. `hit` is true if it touched the target.
signal attack_landed(attack_id: StringName, hit: bool)
signal respawned

enum State { CHASE, TELEGRAPH, SHOCKWAVE, RECOVER, DEAD }
enum Attack { SWING, SWEEP, SHOCKWAVE }
## Which side of the enemy is safe during a sweep (seen from the enemy).
enum SweepSide { LEFT = -1, RIGHT = 1 }

## Ids for the run record (ADR 0004): habits are counted per attack.
const ATTACK_IDS: Dictionary = {
	Attack.SWING: &"test_enemy.swing",
	Attack.SWEEP: &"test_enemy.sweep",
	Attack.SHOCKWAVE: &"test_enemy.shockwave",
}
const WEAPON_MAX_GLOW: float = 6.0
const WARNING_MAX_ALPHA: float = 0.7
const HIT_FLASH_TIME: float = 0.1

## The character it chases and attacks (the Player).
@export var target: Node3D
@export var move_speed: float = 3.0
@export var turn_speed: float = 6.0
@export var gravity: float = 22.0
## Starts an attack when the target is this close.
@export var attack_range: float = 3.0
## Pause after each attack before chasing again.
@export var rest_time: float = 1.2
@export var respawn_time: float = 3.0

@export_group("Swing (parryable)")
@export var swing_windup: float = 0.8
@export var swing_reach: float = 2.6
@export_range(0.0, 180.0) var swing_half_angle_degrees: float = 70.0
@export var swing_damage: int = 20

@export_group("Sweep (dodge to the safe side)")
@export var sweep_windup: float = 1.0
@export var sweep_reach: float = 3.5
@export var sweep_damage: int = 25

@export_group("Shockwave (jump over)")
@export var shockwave_windup: float = 0.6
@export var shockwave_speed: float = 8.0
@export var shockwave_max_radius: float = 9.0
## Feet at least this high above the enemy's floor = the ring passes under.
@export var shockwave_clear_height: float = 0.4
@export var shockwave_damage: int = 15

var state: State = State.CHASE
var current_attack: Attack = Attack.SWING
var sweep_safe_side: SweepSide = SweepSide.LEFT

var _timer: float = 0.0
var _shockwave_radius: float = 0.0
var _shockwave_hit_done: bool = false
var _spawn_transform: Transform3D = Transform3D.IDENTITY
var _rng := RandomNumberGenerator.new()

@onready var health: Health = $Health
@onready var body_shape: CollisionShape3D = $CollisionShape3D
@onready var visual: Node3D = $Visual
@onready var weapon_mesh: MeshInstance3D = $Visual/Weapon
@onready var sweep_warning: MeshInstance3D = $SweepWarning
@onready var shockwave_ring: MeshInstance3D = $ShockwaveRing


func _ready() -> void:
	_spawn_transform = global_transform
	health.died.connect(_on_died)
	_hide_warnings()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	match state:
		State.CHASE:
			_process_chase(delta)
		State.TELEGRAPH:
			_process_telegraph(delta)
		State.SHOCKWAVE:
			_process_shockwave(delta)
		State.RECOVER:
			_stop()
			_timer -= delta
			if _timer <= 0.0:
				state = State.CHASE
		State.DEAD:
			tick_respawn(delta)
			return

	move_and_slide()


## Damage from the player's attacks.
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	health.damage(amount)
	_flash_hit()


## Counts down to respawning. Public so tests can drive it.
func tick_respawn(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	health.reset()
	state = State.CHASE
	if is_inside_tree():
		global_transform = _spawn_transform
		visual.visible = true
		body_shape.disabled = false
	respawned.emit()


## Flat velocity that walks from `from` toward `to`.
static func chase_velocity(from: Vector3, to: Vector3, speed: float) -> Vector3:
	var flat := Vector3(to.x - from.x, 0.0, to.z - from.z)
	if flat.is_zero_approx():
		return Vector3.ZERO
	return flat.normalized() * speed


## Swing hits if the target is within reach and inside the front arc.
static func swing_hits(
	enemy_pos: Vector3, forward: Vector3, target_pos: Vector3, reach: float, half_angle_deg: float
) -> bool:
	var to_target := Vector3(target_pos.x - enemy_pos.x, 0.0, target_pos.z - enemy_pos.z)
	if to_target.length() > reach:
		return false
	if to_target.is_zero_approx():
		return true
	var flat_forward := Vector3(forward.x, 0.0, forward.z)
	return rad_to_deg(flat_forward.angle_to(to_target)) <= half_angle_deg


## Sweep covers the square half on the unsafe side of the enemy.
static func sweep_hits(
	enemy_pos: Vector3, forward: Vector3, target_pos: Vector3, reach: float, safe_side: SweepSide
) -> bool:
	var to_target := Vector3(target_pos.x - enemy_pos.x, 0.0, target_pos.z - enemy_pos.z)
	var flat_forward := Vector3(forward.x, 0.0, forward.z).normalized()
	var right := flat_forward.cross(Vector3.UP)
	var ahead := to_target.dot(flat_forward)
	var side := to_target.dot(right)
	if absf(ahead) > reach or absf(side) > reach:
		return false
	var on_safe_side := side * float(safe_side) > 0.0
	return not on_safe_side


## The ring hits when it passes the target this step and the target is on
## the ground (not high enough to clear it).
static func shockwave_hits(
	previous_radius: float, radius: float, distance: float, height: float, clear_height: float
) -> bool:
	var passes := distance >= previous_radius and distance <= radius
	return passes and height < clear_height


func _process_chase(delta: float) -> void:
	if target == null:
		_stop()
		return
	_turn_toward(target.global_position, delta)
	var distance := global_position.distance_to(target.global_position)
	if distance <= attack_range:
		_start_attack(_pick_attack())
		return
	var chase := chase_velocity(global_position, target.global_position, move_speed)
	velocity.x = chase.x
	velocity.z = chase.z


func _pick_attack() -> Attack:
	return _rng.randi_range(0, Attack.size() - 1) as Attack


func _start_attack(attack: Attack) -> void:
	_stop()
	current_attack = attack
	state = State.TELEGRAPH
	# Aim once at the start, then hold still so the player can read and dodge.
	_face_instantly(target.global_position)
	match attack:
		Attack.SWING:
			_timer = swing_windup
		Attack.SWEEP:
			_timer = sweep_windup
			sweep_safe_side = SweepSide.LEFT if _rng.randf() < 0.5 else SweepSide.RIGHT
			_place_sweep_warning()
		Attack.SHOCKWAVE:
			_timer = shockwave_windup
	attack_telegraphed.emit(ATTACK_IDS[attack])


func _process_telegraph(delta: float) -> void:
	_stop()
	var total := _windup_of(current_attack)
	_timer -= delta
	var progress := clampf(1.0 - _timer / total, 0.0, 1.0) if total > 0.0 else 1.0
	_show_tell(progress)
	if _timer > 0.0:
		return
	match current_attack:
		Attack.SWING:
			var hit := swing_hits(
				global_position,
				_forward(),
				target.global_position,
				swing_reach,
				swing_half_angle_degrees
			)
			_land(hit, swing_damage, true)
		Attack.SWEEP:
			var hit := sweep_hits(
				global_position, _forward(), target.global_position, sweep_reach, sweep_safe_side
			)
			_land(hit, sweep_damage, false)
		Attack.SHOCKWAVE:
			_shockwave_radius = 0.0
			_shockwave_hit_done = false
			state = State.SHOCKWAVE
			return


func _process_shockwave(delta: float) -> void:
	_stop()
	var previous := _shockwave_radius
	_shockwave_radius += shockwave_speed * delta
	shockwave_ring.visible = true
	shockwave_ring.scale = Vector3(_shockwave_radius, 1.0, _shockwave_radius)
	if not _shockwave_hit_done and target:
		var flat_distance := (
			Vector2(
				target.global_position.x - global_position.x,
				target.global_position.z - global_position.z
			)
			. length()
		)
		var height := target.global_position.y - global_position.y
		if shockwave_hits(
			previous, _shockwave_radius, flat_distance, height, shockwave_clear_height
		):
			_shockwave_hit_done = true
			_hit_target(shockwave_damage, false)
			attack_landed.emit(ATTACK_IDS[Attack.SHOCKWAVE], true)
	if _shockwave_radius >= shockwave_max_radius:
		if not _shockwave_hit_done:
			attack_landed.emit(ATTACK_IDS[Attack.SHOCKWAVE], false)
		_finish_attack()


func _land(hit: bool, damage: int, parryable: bool) -> void:
	if hit:
		_hit_target(damage, parryable)
	attack_landed.emit(ATTACK_IDS[current_attack], hit)
	_finish_attack()


func _hit_target(damage: int, parryable: bool) -> void:
	if target and target.has_method("receive_hit"):
		target.receive_hit(global_position, damage, parryable)


func _finish_attack() -> void:
	_hide_warnings()
	state = State.RECOVER
	_timer = rest_time


func _windup_of(attack: Attack) -> float:
	match attack:
		Attack.SWEEP:
			return sweep_windup
		Attack.SHOCKWAVE:
			return shockwave_windup
	return swing_windup


func _show_tell(progress: float) -> void:
	match current_attack:
		Attack.SWING:
			_set_weapon_glow(progress * WEAPON_MAX_GLOW)
		Attack.SWEEP:
			_set_alpha(sweep_warning, progress * WARNING_MAX_ALPHA)
		Attack.SHOCKWAVE:
			shockwave_ring.visible = true
			shockwave_ring.scale = Vector3.ONE * (0.5 + 0.5 * progress)


func _place_sweep_warning() -> void:
	# The warning covers the unsafe half: opposite to the safe side.
	var unsafe := -float(sweep_safe_side)
	sweep_warning.position = Vector3(unsafe * sweep_reach * 0.5, 0.03, 0.0)
	sweep_warning.scale = Vector3(sweep_reach, 1.0, sweep_reach * 2.0)
	sweep_warning.visible = true
	_set_alpha(sweep_warning, 0.0)


func _hide_warnings() -> void:
	if sweep_warning:
		sweep_warning.visible = false
	if shockwave_ring:
		shockwave_ring.visible = false
	_set_weapon_glow(0.0)


func _set_weapon_glow(energy: float) -> void:
	if weapon_mesh == null:
		return
	var material := weapon_mesh.get_active_material(0) as StandardMaterial3D
	if material:
		material.emission_energy_multiplier = energy


func _set_alpha(mesh: MeshInstance3D, alpha: float) -> void:
	var material := mesh.get_active_material(0) as StandardMaterial3D
	if material:
		material.albedo_color.a = alpha


func _flash_hit() -> void:
	if not is_inside_tree():
		return
	visual.scale = Vector3.ONE * 1.1
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector3.ONE, HIT_FLASH_TIME)


func _on_died() -> void:
	state = State.DEAD
	_timer = respawn_time
	_stop()
	if is_inside_tree():
		_hide_warnings()
		visual.visible = false
		body_shape.set_deferred("disabled", true)


func _forward() -> Vector3:
	return -global_transform.basis.z


func _turn_toward(point: Vector3, delta: float) -> void:
	var to := Vector3(point.x - global_position.x, 0.0, point.z - global_position.z)
	if to.is_zero_approx():
		return
	var target_angle := atan2(-to.x, -to.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 1.0 - exp(-turn_speed * delta))


func _face_instantly(point: Vector3) -> void:
	var to := Vector3(point.x - global_position.x, 0.0, point.z - global_position.z)
	if not to.is_zero_approx():
		rotation.y = atan2(-to.x, -to.z)


func _stop() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
