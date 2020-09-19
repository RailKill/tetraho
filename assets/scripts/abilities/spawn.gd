class_name Spawn
extends Ability


# Scene resource to spawn.
export(PackedScene) var spawn_resource
# Checker to use when determining whether the spawn point is clear or not.
export(PackedScene) var checker_resource = \
		preload("res://assets/objects/areas/area_checker.tscn")
# Spawn point global position.
export(Vector2) var point
# If true, spawn point checker will be snapped to the grid.
export(bool) var is_snapped = true
# Rotation angle in degrees to set the newly spawned object.
export(float) var angle = 0
# Maximum objects spawnable.
export(int, 0, 50) var maximum_spawnable = 3

# List of objects spawned by this ability.
var spawned: Array = []


func cast():
	if spawned.size() < maximum_spawnable:
		.cast()


func complete():
	.complete()
	var level = caster.get_parent()
	var checker = checker_resource.instance()
	checker.global_position = point
	checker.is_snapped = is_snapped
	level.add_child(checker)
	
	var collided = yield(checker, "lifetime_expired")
	if not collided:
		var spawn = spawn_resource.instance()
		level.add_child(spawn)
		level.move_child(spawn, 0)
		spawn.global_position = point
		spawn.rotation_degrees = angle
		spawn.connect("tree_exiting", self, "erase", [spawn])
		spawned.append(spawn)
	else:
		caster.play_fail_animation(self)
		countdown = Constants.ABILITY_FAILURE_RECOVERY_TIME


# Clear given spawned object that no longer exist.
func erase(entity):
	spawned.erase(entity)
