class_name PlayerInput
extends Node
## Turns THIS computer's keyboard and mouse into "intent" for the player.
##
## Why a separate node? The Player never reads the keyboard itself. It only
## asks "what does my controller want to do?". Today the answer comes from
## the keyboard. In co-op, a friend's player will get its answer from the
## network instead, and the Player script won't need to change at all.
## The Observer will also read these same intents to learn your habits.
##
## The keys live in Project > Project Settings > Input Map (not in code), so
## they can be rebound later. They use physical key positions, so they also
## work on non-QWERTY keyboards (for example a Turkish F keyboard).

## Flat direction on the ground the player wants to move in, length 0..1.
var move_direction: Vector3 = Vector3.ZERO
var wants_jump: bool = false
var wants_dodge: bool = false
var wants_attack: bool = false


## Called by the Player at the start of every physics frame, so the intent
## is always fresh (no one-frame delay).
func poll() -> void:
	# WASD as a 2D vector: x = left/right, y = forward/back.
	var input_2d: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var camera: Camera3D = get_viewport().get_camera_3d()
	var cam_basis: Basis = camera.global_transform.basis if camera else Basis.IDENTITY
	move_direction = camera_relative(input_2d, cam_basis)

	wants_jump = Input.is_action_just_pressed("jump")
	wants_dodge = Input.is_action_just_pressed("dodge")
	wants_attack = Input.is_action_just_pressed("attack")


## Makes WASD relative to where the camera is looking, flattened onto the
## ground. Static so tests can check it without a running game.
static func camera_relative(input_2d: Vector2, cam_basis: Basis) -> Vector3:
	var forward := Vector3(-cam_basis.z.x, 0.0, -cam_basis.z.z).normalized()
	var right := Vector3(cam_basis.x.x, 0.0, cam_basis.x.z).normalized()
	var direction := right * input_2d.x + forward * -input_2d.y
	# Diagonals must not be faster than straight lines.
	return direction.limit_length(1.0)
