class_name CameraRig
extends Node3D
## MMO-style third-person camera: behind and above the character, pulled back
## so you can see the whole arena.
##
## Controls:
##   Mouse        rotate the camera (the mouse is locked to the game window)
##   Mouse wheel  zoom in and out
##   Esc          free the mouse (click the game window to lock it again)
##
## Node layout:  CameraRig (turns left/right) > Pivot (tilts up/down)
##               > SpringArm3D (pulls in when a wall is in the way) > Camera3D

## The character to follow.
@export var target: Node3D
## Look at the chest, not the feet.
@export var follow_height: float = 1.4
## Higher = sticks closer to the target.
@export var follow_smoothing: float = 14.0

@export_group("Rotation")
@export var mouse_sensitivity: float = 0.0025
## Looking down from high.
@export_range(-89.0, 0.0) var min_pitch_degrees: float = -70.0
## Almost level.
@export_range(-89.0, 0.0) var max_pitch_degrees: float = -8.0
@export_range(-89.0, 0.0) var start_pitch_degrees: float = -32.0

@export_group("Zoom")
@export var zoom: float = 10.0
@export var min_zoom: float = 4.0
@export var max_zoom: float = 18.0
@export var zoom_step: float = 1.0
## Higher = the zoom reaches its new distance faster.
@export var zoom_smoothing: float = 10.0

@onready var pivot: Node3D = $Pivot
@onready var spring_arm: SpringArm3D = $Pivot/SpringArm3D


func _ready() -> void:
	# Physics interpolation is on for the project (smooth on high refresh rate
	# monitors). The camera moves every rendered frame itself, so it opts out.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

	top_level = true  # move on our own, not with whatever we're parented to
	pivot.rotation.x = deg_to_rad(start_pitch_degrees)
	spring_arm.spring_length = zoom
	if target is CollisionObject3D:
		# Don't let the camera bump into the player's own body.
		spring_arm.add_excluded_object((target as CollisionObject3D).get_rid())
	if target:
		global_position = _target_point()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and captured:
		var motion := event as InputEventMouseMotion
		rotation.y -= motion.relative.x * mouse_sensitivity
		pivot.rotation.x = clampf(
			pivot.rotation.x - motion.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch_degrees),
			deg_to_rad(max_pitch_degrees)
		)

	elif event is InputEventMouseButton and event.pressed:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = maxf(zoom - zoom_step, min_zoom)
		elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = minf(zoom + zoom_step, max_zoom)
		elif not captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	if target == null:
		return
	var weight := 1.0 - exp(-follow_smoothing * delta)
	global_position = global_position.lerp(_target_point(), weight)
	var zoom_weight := 1.0 - exp(-zoom_smoothing * delta)
	spring_arm.spring_length = lerpf(spring_arm.spring_length, zoom, zoom_weight)


func _target_point() -> Vector3:
	# The interpolated position matches what's drawn on screen this frame.
	return target.get_global_transform_interpolated().origin + Vector3.UP * follow_height
