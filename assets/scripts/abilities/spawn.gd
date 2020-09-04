class_name Spawn
extends Ability


# Scene resource to spawn.
export var resource : PackedScene
# Spawn point global position.
export var point : Vector2
# Rotation angle in degrees to set the newly spawned object.
export var angle = 0
# Maximum objects spawnable.
export var maximum_spawnable = 3
# Checker to use when determining whether the spawn point is clear or not.
export var checker = preload("res://assets/objects/areas/area_checker.tscn")
# If true, spawn point checker will be snapped to the grid.
export var is_snapped = true

# List of objects spawned by this ability.
var spawned = []


func cast():
	update()
	if spawned.size() < maximum_spawnable:
		.cast()


func complete():
	.complete()
	var level = get_node("/root/Level")
	
	var target = checker.instance()
	level.add_child(target)
	target.reposition(point, is_snapped)
	
	yield(get_tree().create_timer(0.1), "timeout")
	if not target.collided:
		var spawn = resource.instance()
		level.add_child(spawn)
		level.move_child(spawn, 0)
		spawn.set_global_position(point)
		spawn.set_rotation_degrees(angle)
		spawned.append(spawn)
	else:
		caster.play_fail_animation(self)
		reset()
	
	target.queue_free()


# Clear null spawned objects that no longer exist.
func update():
	for entity in spawned:
		if not entity or not is_instance_valid(entity):
			spawned.erase(entity)
