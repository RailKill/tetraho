class_name Spawn
extends Ability


# Scene resource to spawn.
export(PackedScene) var spawn_resource
# Checker to use when determining whether the spawn point is clear or not.
export(PackedScene) var checker_resource = \
		preload("res://assets/scenes/areas/area_checker.tscn")
# Spawn point global position.
export(Vector2) var point setget set_point
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
	
	# Skip check and spawn right away if checker is not set.
	if not checker_resource:
		create(point)
		return
	
	var checker = checker_resource.instance()
	checker.global_position = point
	checker.is_snapped = is_snapped
	caster.get_parent().add_child(checker)
	var collided = yield(checker, "lifetime_expired")
	if not collided:
		create(checker.global_position if is_snapped else point)
	else:
		caster.play_fail_animation(self)
		countdown = Constants.ABILITY_FAILURE_RECOVERY_TIME


func create(destination: Vector2):
	var spawn = spawn_resource.instance()
	caster.get_parent().add_child(spawn)
	spawn.global_position = destination
	spawn.rotation_degrees = angle
	spawn.connect("tree_exiting", self, "erase", [spawn])
	spawned.append(spawn)
	
	if "creator" in spawn:
		spawn.creator = caster


# Clear given spawned object that no longer exist.
func erase(entity):
	spawned.erase(entity)


func set_point(destination: Vector2):
	point = destination
