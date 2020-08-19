class_name Knockback
extends Trajectory
# One-off effect.


func _physics_process(delta):
	countdown -= delta
	if countdown > 0:
		caster.check_collision(caster.move_and_collide(direction * speed))
	else:
		queue_free()
