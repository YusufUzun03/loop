extends RefCounted
## Tests for the player prototype: dodge rules, camera-relative movement,
## input actions and the test room scene.

const PHYSICS_STEP: float = 1.0 / 60.0
## The dodge is measured in whole physics frames, so allow a little slack.
const DISTANCE_TOLERANCE: float = 0.15
const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_forward",
	&"move_back",
	&"move_left",
	&"move_right",
	&"dodge",
	&"jump",
	&"attack",
	&"skill_1",
	&"skill_2",
	&"skill_3",
]


func test_dodge_covers_dodge_distance() -> String:
	var player := Player.new()
	player.start_dodge(Vector3.RIGHT)
	var travelled := 0.0
	var frames := 0
	while player.state == Player.State.DODGING and frames < 120:
		player.tick_dodge(PHYSICS_STEP)
		travelled += player.velocity.x * PHYSICS_STEP
		frames += 1
	var expected := player.dodge_distance
	player.free()
	if absf(travelled - expected) > expected * DISTANCE_TOLERANCE:
		return "dodge travelled %.2f m, expected about %.2f m" % [travelled, expected]
	return ""


func test_dodge_blocked_while_on_cooldown() -> String:
	var player := Player.new()
	var first := player.start_dodge(Vector3.FORWARD)
	while player.state == Player.State.DODGING:
		player.tick_dodge(PHYSICS_STEP)
	var during_cooldown := player.start_dodge(Vector3.FORWARD)
	player.tick_cooldown(player.dodge_cooldown)
	var after_cooldown := player.start_dodge(Vector3.FORWARD)
	player.free()
	if not first:
		return "first dodge did not start"
	if during_cooldown:
		return "a second dodge started during the cooldown"
	if not after_cooldown:
		return "dodge did not start after the cooldown ended"
	return ""


func test_dodge_emits_signal_with_direction() -> String:
	var player := Player.new()
	var received: Array[Vector3] = []
	player.dodged.connect(func(direction: Vector3) -> void: received.append(direction))
	player.start_dodge(Vector3.LEFT)
	player.free()
	if received.size() != 1 or not received[0].is_equal_approx(Vector3.LEFT):
		return "expected one dodged(LEFT) signal, got %s" % [received]
	return ""


func test_standing_dodge_uses_facing() -> String:
	var direction := Player.dodge_direction_for(Vector3.ZERO, Vector3.BACK)
	if not direction.is_equal_approx(Vector3.BACK):
		return "standing dodge went %s, expected facing (BACK)" % direction
	return ""


func test_dodge_direction_stays_flat() -> String:
	var direction := Player.dodge_direction_for(Vector3(1.0, 5.0, 0.0), Vector3.FORWARD)
	if not direction.is_equal_approx(Vector3.RIGHT):
		return "dodge direction %s should ignore height and be RIGHT" % direction
	return ""


func test_forward_key_follows_camera() -> String:
	# Camera turned 90 degrees to the left: "forward" should now be world -X.
	var turned := Basis(Vector3.UP, PI / 2.0)
	var direction := PlayerInput.camera_relative(Vector2(0.0, -1.0), turned)
	if not direction.is_equal_approx(Vector3.LEFT):
		return "W with a turned camera moved %s, expected LEFT" % direction
	return ""


func test_diagonal_is_not_faster() -> String:
	var direction := PlayerInput.camera_relative(Vector2(1.0, -1.0), Basis.IDENTITY)
	if direction.length() > 1.0001:
		return "diagonal input length %.3f is above 1" % direction.length()
	return ""


func test_input_actions_exist() -> String:
	for action in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			return "missing input action: %s" % action
	return ""


func test_test_room_has_player_and_camera() -> String:
	var scene: PackedScene = load("res://scenes/test_room/test_room.tscn")
	if scene == null:
		return "test_room.tscn did not load"
	var room := scene.instantiate()
	var player := room.get_node_or_null("Player")
	var rig := room.get_node_or_null("CameraRig")
	var error := ""
	if not player is Player:
		error = "TestRoom has no Player node"
	elif not rig is CameraRig:
		error = "TestRoom has no CameraRig node"
	elif (rig as CameraRig).target != player:
		error = "CameraRig does not follow the Player"
	room.free()
	return error
