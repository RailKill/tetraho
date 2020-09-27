class_name Bullet
extends KinematicBody2D


# Trajectory that marks the direction and speed of the bullet.
var trajectory: Trajectory


func _ready():
	look_at(trajectory.direction)


func _physics_process(delta):
	# If bullet collides with something, damage it, then destroy self.
	var collision = move_and_collide(
			trajectory.direction * trajectory.speed * delta)
	if collision:
		var body = collision.get_collider()
		if body is Actor:
			body.oof(Constants.BULLET_DAMAGE, false, 
					trajectory.caster, "shot")
		queue_free()
