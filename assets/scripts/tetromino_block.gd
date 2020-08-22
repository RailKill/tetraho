class_name TetrominoBlock
extends Actor
# A general block that is damageable. It is possible for some blocks to be
# moved, or have their own abilities, so it is considered an Actor.


# Reference to the game world.
onready var game_world : GameWorld = get_tree().get_root().get_child(0)
# Reference to the animated sprite for summon animation.
onready var summon = $Summon
# Reference to the animated sprite for unsummon animation.
onready var unsummon = $Unsummon

# Check if block is marked for solving.
var marked = false
# Actors which are trapped in this block.
var trapped = []


func _ready():
	max_hp = Constants.BLOCK_HP
	hp = Constants.BLOCK_HP
	collision_shape.disabled = true


# Queue the block for destruction.
func disable():
	collision_shape.disabled = true
	summon.set_visible(false)
	unsummon.set_visible(true)
	unsummon.play()


# Summons the block into game existence.
func enable():
	collision_shape.disabled = false
	unsummon.set_visible(false)
	summon.set_visible(true)
	summon.play()
	game_world.add_block(self)


# Return the difference vector from collision origin to the given target.
func get_difference(target : Node2D):
	return collision_shape.get_global_position() - target.get_global_position()


# Gets the rounded global position of the center of the block.
func get_global_vector():
	var vector = collision_shape.get_global_position()
	return Vector2(int(round(vector.x)), int(round(vector.y)))


# Trap the given actor in this block.
func trap(actor):
	trapped.append(actor)
	actor.locked_by.append(self)


# Untrap all actors in this block.
func untrap():
	for actor in trapped:
		# If actor is dead, they will no longer exist, so do a null check.
		if is_instance_valid(actor):
			actor.locked_by.erase(self)


func _on_Unsummon_animation_finished():
	game_world.remove_block(self)
	untrap()
	call_deferred("free")
