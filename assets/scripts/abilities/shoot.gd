class_name Shoot
extends Trajectory
# This ability fires a bullet from a gun which follows its trajectory.


# Currently equipped gun to shoot.
var gun: Handgun


func cast():
	.cast()
	if not is_on_cooldown:
		direction = Vector2.RIGHT.rotated(gun.rotation)
		speed = gun.velocity
		
		var shot = gun.bullet.instance()
		var copy = self.duplicate()
		copy.caster = caster
		shot.trajectory = copy
		
		caster.get_parent().add_child(shot)
		shot.global_position = gun.get_muzzle_position()
		complete()
