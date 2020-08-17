class_name TetrominoBlock
extends Actor
# A general block that is damageable. It is possible for some blocks to be
# moved, or have their own abilities, so it is considered an Actor.


# The collision shape node associated with this block.
onready var collision_shape = $CollisionShape2D
# Reference to the animated sprite for summon animation.
onready var summon = $Summon
# Reference to the animated sprite for unsummon animation.
onready var unsummon = $Unsummon
onready var game_world : GameWorld = get_tree().get_root().get_child(0)
var marked = false;


# Disables collision.
func disable():
	collision_shape.disabled = true
	summon.set_visible(false)
	unsummon.set_visible(true)
	unsummon.play()
	


# Enables collision.
func enable():
	collision_shape.disabled = false
	unsummon.set_visible(false)
	summon.set_visible(true)
	summon.play()


# Gets the rounded global position of the center of the block.
func get_global_vector():
	var vector = collision_shape.get_global_position()
	return Vector2(int(round(vector.x)), int(round(vector.y)))


func solve():
	if marked:
		disable()

func _on_Unsummon_animation_finished():
	game_world.remove_block(self)
	queue_free()
