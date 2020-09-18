class_name TetrominoBlock
extends Actor
# A general block that is damageable. It is possible for some blocks to be
# moved, or have their own abilities, so it is considered an Actor.


# Check if block is marked for solving.
var marked = false

# Reference to the animated sprite for summon animation.
onready var summon = $Summon
# Reference to the animated sprite for unsummon animation.
onready var unsummon = $Unsummon


func _ready():
	max_hp = Constants.BLOCK_HP
	hp = Constants.BLOCK_HP
	collision_shape.disabled = true
	
	# warning-ignore:return_value_discarded
	connect("tree_exiting", self, "_on_tree_exiting")
	unsummon.connect("animation_finished", self, "_on_unsummon_complete")


# Built-in function to destroy object when unsummon animation is complete.
# This is for when the block decays naturally.
func _on_unsummon_complete():
	queue_free()


# Built-in function to free the reference to this block in GameWorld.
# This is especially for when the block was killed by damage.
func _on_tree_exiting():
	untrap()


# Queue the block for destruction. Used during a solve.
func disable():
	collision_shape.disabled = true
	summon.visible = false
	unsummon.visible = true
	unsummon.play()
	untrap()


# Summons the block into game existence.
func enable():
	collision_shape.disabled = false
	unsummon.visible = false
	summon.visible = true
	summon.play()
	GameWorld.blocks[self] = []


# Return the difference vector from collision origin to the given target.
func get_difference(target: Node2D):
	return collision_shape.global_position - target.global_position


# Gets the rounded global position of the center of the block.
# This fixes any rotation and rounding problems with the positioning.
func get_global_vector():
	var vector = collision_shape.global_position
	return Vector2(int(round(vector.x)), int(round(vector.y)))


# Traps a given actor by adding a record to the GameWorld.
func trap(actor):
	GameWorld.blocks[self].append(actor)


# Frees all trapped actors associated with this block from the GameWorld.
func untrap():
	GameWorld.blocks.erase(self)
