extends Label
## Temporary test readout: player and enemy health. Not the real HUD; that
## comes later following Memo's "small and simple" decision (#16).

@export var player: Player
@export var enemy: TestEnemy


func _process(_delta: float) -> void:
	var lines: PackedStringArray = []
	if player and player.health:
		lines.append("Player HP: %d / %d" % [player.health.current, player.health.max_health])
	if enemy and enemy.health:
		var enemy_state := "dead" if enemy.state == TestEnemy.State.DEAD else ""
		lines.append(
			"Enemy HP: %d / %d %s" % [enemy.health.current, enemy.health.max_health, enemy_state]
		)
	text = "\n".join(lines)
