class_name Knockback
extends Ability
# One-off effect.


# Direction of the knockback.
var direction : Vector2
var speed = 4


func _physics_process(delta):
	countdown -= delta
	if countdown > 0:
		caster.move_and_collide(direction * speed)
	else:
		queue_free()
