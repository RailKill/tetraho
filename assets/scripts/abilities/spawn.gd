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


func cast():
	update()
	if not is_on_cooldown and spawned.size() < maximum_spawnable:
		var spawn = resource.instance()
		var world = get_tree().get_root().get_child(0)
		world.add_child(spawn)
		world.move_child(spawn, 0)
		spawn.set_global_position(point)
		spawn.set_rotation_degrees(angle)
		spawned.append(spawn)
		complete()


# Clear null spawned objects that no longer exist.
func update():
	for entity in spawned:
		if not entity:
			spawned.erase(entity)
