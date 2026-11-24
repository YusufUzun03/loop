class_name LineOfSight
extends RefCounted
## "Can A see B?" checks, so attacks don't hit through walls.

## Physics layer 1 = "world" (walls, floors, pillars; see project.godot).
const WORLD_MASK: int = 1
## Rays go chest to chest, so low steps don't block a hit.
const CHEST_HEIGHT: float = 1.0


## True when no world geometry sits between `from` and `to`.
static func is_clear(world: World3D, from: Vector3, to: Vector3, mask: int = WORLD_MASK) -> bool:
	if world == null:
		return true
	var query := PhysicsRayQueryParameters3D.create(from, to, mask)
	return world.direct_space_state.intersect_ray(query).is_empty()


## Same check between two characters, measured at chest height.
static func between(a: Node3D, b: Node3D) -> bool:
	if not a.is_inside_tree() or not b.is_inside_tree():
		return true
	var up := Vector3.UP * CHEST_HEIGHT
	return is_clear(a.get_world_3d(), a.global_position + up, b.global_position + up)
