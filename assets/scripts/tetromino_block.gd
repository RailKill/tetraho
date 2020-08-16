class_name TetrominoBlock
extends Actor
# A general block that is damageable. It is possible for some blocks to be
# moved, or have their own abilities, so it is considered an Actor.


# The collision shape node associated with this block.
onready var collision_shape = $CollisionShape2D


# Disables collision.
func disable_collision():
	collision_shape.disabled = true


# Enables collision.
func enable_collision():
	collision_shape.disabled = false
