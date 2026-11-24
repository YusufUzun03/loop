class_name Player
extends CharacterBody3D
## The player character: walking, jumping, dodging, attacking and parrying.
##
## Every number marked @export shows up in the Inspector when you select the
## Player in Godot, so you can tune the feel while playtesting without
## touching code. Attack and parry values live on the Combat child node.

## Emitted when a dodge starts. The Observer and the run record listen to it.
signal dodged(direction: Vector3)
signal jumped
## An enemy hit was parried. `to_attacker` points from the player to it.
signal parried(to_attacker: Vector3)
signal hit_taken(damage: int)

enum State { NORMAL, DODGING }

## Below this length the movement input counts as "standing still".
const MOVE_DEADZONE: float = 0.1
## How far the weapon swings (radians) when a strike lands.
const SWING_ANGLE: float = 1.2
const SWING_DOWN_TIME: float = 0.08
const SWING_BACK_TIME: float = 0.2
const PARRY_FLASH_TIME: float = 0.15
const PARRY_SOUND_FREQUENCY: float = 1800.0
const PARRY_SOUND_LENGTH: float = 0.18
const CHARGED_GLOW: float = 4.0

@export_group("Movement")
@export var move_speed: float = 6.0
## How fast you reach full speed.
@export var acceleration: float = 45.0
## How fast the body turns to face the movement direction.
@export var turn_speed: float = 14.0

@export_group("Jump")
@export var jump_velocity: float = 7.5
@export var gravity: float = 22.0
@export var can_jump_while_attacking: bool = false

@export_group("Dodge")
## No invincibility: the dodge only saves you if it moves you out of the attack.
@export var dodge_distance: float = 4.5
@export var dodge_duration: float = 0.22
@export var dodge_cooldown: float = 1.2
## A dodge pressed this close to the end of the cooldown still happens.
@export var dodge_input_buffer: float = 0.1

var state: State = State.NORMAL
## The direction the character looks (and attacks).
var facing: Vector3 = Vector3.FORWARD

var _dodge_time_left: float = 0.0
var _dodge_cooldown_left: float = 0.0
var _dodge_direction: Vector3 = Vector3.ZERO
var _dodge_buffer_left: float = 0.0
var _dodge_buffer_direction: Vector3 = Vector3.ZERO
var _attack_buffer_left: float = 0.0
## Enemy hits wait here until this frame's combat step has run.
var _pending_hits: Array[Dictionary] = []

@onready var input_source: PlayerInput = $PlayerInput
@onready var visual: Node3D = $Visual
@onready var combat: PlayerCombat = $Combat
@onready var health: Health = $Health
@onready var attack_hitbox: Area3D = $Visual/AttackHitbox
@onready var weapon: Node3D = $Visual/Weapon
@onready var weapon_mesh: MeshInstance3D = $Visual/Weapon/Mesh
@onready var parry_flash: Node3D = $Visual/ParryFlash
@onready var parry_sound: AudioStreamPlayer3D = $ParrySound


func _ready() -> void:
	combat.strike_landed.connect(_on_strike_landed)
	combat.strike_resolved.connect(_on_strike_resolved)
	# Prototype only: real death (waking up in the hub) comes later.
	health.died.connect(health.reset)
	parry_flash.visible = false
	parry_sound.stream = PlaceholderSfx.ping(PARRY_SOUND_FREQUENCY, PARRY_SOUND_LENGTH)


func _physics_process(delta: float) -> void:
	input_source.poll()
	tick_cooldown(delta)
	tick_dodge_buffer(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if input_source.wants_dodge:
		request_dodge(input_source.move_direction)

	match state:
		State.NORMAL:
			_process_normal(delta)
		State.DODGING:
			tick_dodge(delta)
			# An attack pressed near the end of the dodge comes out right after it.
			if input_source.wants_attack:
				_attack_buffer_left = combat.input_buffer
			else:
				_attack_buffer_left = maxf(_attack_buffer_left - delta, 0.0)

	combat.tick(delta)
	if combat.phase == PlayerCombat.Phase.CHARGING and not input_source.attack_held:
		combat.release_attack()
	_resolve_pending_hits()
	_update_charge_glow()

	move_and_slide()
	_turn_visual(delta)


## True when a new dodge may start right now.
func can_dodge() -> bool:
	return state == State.NORMAL and _dodge_cooldown_left <= 0.0


## Starts a dodge where you're moving; if you're standing still, toward
## `facing`. A dodge cancels an attack. Returns false while on cooldown.
func start_dodge(move_direction: Vector3) -> bool:
	if not can_dodge():
		return false
	if combat and combat.is_busy():
		combat.cancel()
	_dodge_direction = dodge_direction_for(move_direction, facing)
	facing = _dodge_direction
	_dodge_time_left = dodge_duration
	_dodge_cooldown_left = dodge_cooldown
	_dodge_buffer_left = 0.0
	state = State.DODGING
	dodged.emit(_dodge_direction)
	return true


## Dodges now if possible; if the cooldown is almost over, remembers the
## press for `dodge_input_buffer` seconds. Returns true if it dodged now.
func request_dodge(move_direction: Vector3) -> bool:
	if start_dodge(move_direction):
		return true
	if state == State.NORMAL and _dodge_cooldown_left <= dodge_input_buffer:
		_dodge_buffer_left = dodge_input_buffer
		_dodge_buffer_direction = move_direction
	return false


func tick_dodge_buffer(delta: float) -> void:
	if _dodge_buffer_left <= 0.0:
		return
	if can_dodge():
		start_dodge(_dodge_buffer_direction)
		return
	_dodge_buffer_left -= delta


## Moves the dodge forward by one physics step.
func tick_dodge(delta: float) -> void:
	var dodge_speed := dodge_distance / dodge_duration
	velocity.x = _dodge_direction.x * dodge_speed
	velocity.z = _dodge_direction.z * dodge_speed

	_dodge_time_left -= delta
	if _dodge_time_left <= 0.0:
		state = State.NORMAL
		# Come out of the dodge at walking speed instead of sliding far.
		var flat := Vector3(velocity.x, 0.0, velocity.z).limit_length(move_speed)
		velocity.x = flat.x
		velocity.z = flat.z


func tick_cooldown(delta: float) -> void:
	_dodge_cooldown_left = maxf(_dodge_cooldown_left - delta, 0.0)


## 0 = dodge ready, 1 = just used. Handy for a cooldown icon later.
func get_dodge_cooldown_ratio() -> float:
	return _dodge_cooldown_left / dodge_cooldown if dodge_cooldown > 0.0 else 0.0


## Enemies call this when their attack lands on the player. Attacks that
## can't be parried (sweeps, shockwaves) pass `parryable = false`.
func receive_hit(attacker_position: Vector3, damage: int, parryable: bool = true) -> void:
	(
		_pending_hits
		. append(
			{
				"to_attacker": attacker_position - global_position,
				"damage": damage,
				"parryable": parryable,
			}
		)
	)


## Parry or take damage. Returns true if the hit was parried.
func resolve_hit(to_attacker: Vector3, damage: int, parryable: bool = true) -> bool:
	if parryable and combat.try_parry(to_attacker, facing):
		parried.emit(to_attacker)
		_show_parry()
		return true
	health.damage(damage)
	hit_taken.emit(damage)
	return false


## The flat direction a dodge goes: the movement direction, or the current
## facing when standing still. Static so tests can check it directly.
static func dodge_direction_for(move_direction: Vector3, current_facing: Vector3) -> Vector3:
	var flat := Vector3(move_direction.x, 0.0, move_direction.z)
	if flat.length() > MOVE_DEADZONE:
		return flat.normalized()
	return current_facing


func _process_normal(delta: float) -> void:
	var attacking := combat.is_busy()
	var direction := input_source.move_direction
	var target_velocity := direction * move_speed * combat.get_move_multiplier()
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	# Melee attacks go where you face, so facing stays put during a swing.
	if direction.length() > MOVE_DEADZONE and not attacking:
		facing = direction.normalized()

	var may_jump := not attacking or can_jump_while_attacking
	if input_source.wants_jump and is_on_floor() and may_jump:
		velocity.y = jump_velocity
		jumped.emit()

	if input_source.wants_attack or _attack_buffer_left > 0.0:
		_attack_buffer_left = 0.0
		combat.press_attack()


func _resolve_pending_hits() -> void:
	for hit in _pending_hits:
		resolve_hit(hit["to_attacker"], hit["damage"], hit["parryable"])
	_pending_hits.clear()


func _on_strike_landed(_kind: PlayerCombat.Kind) -> void:
	var tween := create_tween()
	tween.tween_property(weapon, "rotation:x", -SWING_ANGLE, SWING_DOWN_TIME)
	tween.tween_property(weapon, "rotation:x", 0.0, SWING_BACK_TIME)


func _on_strike_resolved(_kind: PlayerCombat.Kind, deals_damage: bool) -> void:
	if not deals_damage:
		return
	for body in attack_hitbox.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):
			body.take_damage(combat.get_damage())


func _show_parry() -> void:
	if not is_inside_tree():
		return
	parry_sound.play()
	parry_flash.visible = true
	parry_flash.scale = Vector3.ONE * 0.3
	var tween := create_tween()
	tween.tween_property(parry_flash, "scale", Vector3.ONE * 1.2, PARRY_FLASH_TIME)
	tween.tween_callback(func() -> void: parry_flash.visible = false)


func _update_charge_glow() -> void:
	var material := weapon_mesh.get_active_material(0) as StandardMaterial3D
	if material:
		material.emission_energy_multiplier = CHARGED_GLOW if combat.is_charged() else 0.0


func _turn_visual(delta: float) -> void:
	# The model looks down -Z by default; this turns it to face `facing`.
	var target_angle := atan2(-facing.x, -facing.z)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_angle, 1.0 - exp(-turn_speed * delta))
