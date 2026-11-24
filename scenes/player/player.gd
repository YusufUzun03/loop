class_name Player
extends CharacterBody3D
## The player character: walking, jumping and dodging.
##
## Every number marked @export shows up in the Inspector when you select the
## Player in Godot, so you can tune the feel while playtesting without
## touching code.

## Emitted when a dodge starts. The Observer and the run record listen to it.
signal dodged(direction: Vector3)
signal jumped

enum State { NORMAL, DODGING }

## Below this length the movement input counts as "standing still".
const MOVE_DEADZONE: float = 0.1

@export_group("Movement")
@export var move_speed: float = 6.0
## How fast you reach full speed.
@export var acceleration: float = 45.0
## How fast the body turns to face the movement direction.
@export var turn_speed: float = 14.0

@export_group("Jump")
@export var jump_velocity: float = 7.5
@export var gravity: float = 22.0

@export_group("Dodge")
## No invincibility: the dodge only saves you if it moves you out of the attack.
@export var dodge_distance: float = 4.5
@export var dodge_duration: float = 0.22
@export var dodge_cooldown: float = 1.2

var state: State = State.NORMAL
## The direction the character looks (and attacks).
var facing: Vector3 = Vector3.FORWARD

var _dodge_time_left: float = 0.0
var _dodge_cooldown_left: float = 0.0
var _dodge_direction: Vector3 = Vector3.ZERO

@onready var input_source: PlayerInput = $PlayerInput
@onready var visual: Node3D = $Visual


func _physics_process(delta: float) -> void:
	input_source.poll()
	tick_cooldown(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	match state:
		State.NORMAL:
			_process_normal(delta)
		State.DODGING:
			tick_dodge(delta)

	move_and_slide()
	_turn_visual(delta)


## True when a new dodge may start right now.
func can_dodge() -> bool:
	return state == State.NORMAL and _dodge_cooldown_left <= 0.0


## Starts a dodge where you're moving; if you're standing still, toward
## `facing`. Returns false (and does nothing) while on cooldown.
func start_dodge(move_direction: Vector3) -> bool:
	if not can_dodge():
		return false
	_dodge_direction = dodge_direction_for(move_direction, facing)
	facing = _dodge_direction
	_dodge_time_left = dodge_duration
	_dodge_cooldown_left = dodge_cooldown
	state = State.DODGING
	dodged.emit(_dodge_direction)
	return true


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


## The flat direction a dodge goes: the movement direction, or the current
## facing when standing still. Static so tests can check it directly.
static func dodge_direction_for(move_direction: Vector3, current_facing: Vector3) -> Vector3:
	var flat := Vector3(move_direction.x, 0.0, move_direction.z)
	if flat.length() > MOVE_DEADZONE:
		return flat.normalized()
	return current_facing


func _process_normal(delta: float) -> void:
	var direction := input_source.move_direction
	var target_velocity := direction * move_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if direction.length() > MOVE_DEADZONE:
		facing = direction.normalized()

	if input_source.wants_jump and is_on_floor():
		velocity.y = jump_velocity
		jumped.emit()

	if input_source.wants_dodge:
		start_dodge(direction)


func _turn_visual(delta: float) -> void:
	# The model looks down -Z by default; this turns it to face `facing`.
	var target_angle := atan2(-facing.x, -facing.z)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_angle, 1.0 - exp(-turn_speed * delta))
