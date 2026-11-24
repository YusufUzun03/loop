extends NavigationRegion3D
## Builds the walkable area from the room's walls and floor when the room
## loads, so enemies can path around pillars. The maze will bring baked
## navigation with each hand-made piece instead (TEKNIK-REHBER madde 12).


func _ready() -> void:
	bake_navigation_mesh(false)
