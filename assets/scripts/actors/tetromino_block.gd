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
	
	#warning-ignore:unused_argument
	connect("tree_exited", self, "_on_tree_exited")
	unsummon.connect("animation_finished", self, "_on_unsummon_complete")


func _on_unsummon_complete():
	queue_free()


func _on_tree_exited():
	untrap()


# Queue the block for destruction.
func disable():
	collision_shape.disabled = true
	summon.visible = false
	unsummon.visible = true
	unsummon.play()


# Summons the block into game existence.
func enable():
	collision_shape.disabled = false
	unsummon.visible = false
	summon.visible = true
	summon.play()


# Return the difference vector from collision origin to the given target.
func get_difference(target: Node2D):
	return collision_shape.global_position - target.global_position


# Gets the rounded global position of the center of the block.
func get_global_vector():
	var vector = collision_shape.global_position
	return Vector2(int(round(vector.x)), int(round(vector.y)))


func trap(actor):
	if not GameWorld.blocks.has(self):
		GameWorld.blocks[self] = []
	GameWorld.blocks[self].append(actor)


func untrap():
	GameWorld.blocks.erase(self)
