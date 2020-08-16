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


func _on_Unsummon_animation_finished():
	queue_free()
