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
# List of objects spawned by this ability.
var spawned = []
var checker = preload("res://assets/objects/area_checker.tscn")


func cast():
	update()
	if spawned.size() < maximum_spawnable:
		.cast()


func complete():
	.complete()
	var world = get_tree().get_root().get_child(0)
	
	var target = checker.instance()
	world.add_child(target)
	
	target.set_global_position(Vector2(
		stepify(point.x, Constants.GRID_SIZE), 
		stepify(point.y, Constants.GRID_SIZE)))

	yield(get_tree().create_timer(0.1), "timeout")
	if not target.collided:
		var spawn = resource.instance()
		world.add_child(spawn)
		world.move_child(spawn, 0)
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
		if not entity:
			spawned.erase(entity)
