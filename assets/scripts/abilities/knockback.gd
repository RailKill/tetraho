class_name Knockback
extends Trajectory
# One-off effect.


func _physics_process(delta):
	if is_active:
		caster.move(direction * speed, delta)
	else:
		queue_free()
