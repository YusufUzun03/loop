class_name Health
extends Node
## Hit points for anything that can be hurt: the player now, enemies later.

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 200

var current: int = 0


func _init() -> void:
	# Start full even before the node enters the tree (keeps tests simple).
	current = max_health


func _ready() -> void:
	current = max_health


func is_dead() -> bool:
	return current <= 0


## Removes `amount` hit points. Does nothing once dead.
func damage(amount: int) -> void:
	if is_dead() or amount <= 0:
		return
	current = maxi(current - amount, 0)
	health_changed.emit(current, max_health)
	if is_dead():
		died.emit()


func heal(amount: int) -> void:
	if is_dead() or amount <= 0:
		return
	current = mini(current + amount, max_health)
	health_changed.emit(current, max_health)
