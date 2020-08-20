class_name Knockback
extends Trajectory
# One-off effect.


func _physics_process(_delta):
	if is_active:
		caster.check_collision(caster.move_and_collide(direction * speed))
	else:
		queue_free()
