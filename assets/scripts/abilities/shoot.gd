class_name Shoot
extends Ability
# This ability fires a bullet which follows its trajectory.


# The bullet resource to shoot.
export var bullet : PackedScene = preload("res://assets/objects/bullet.tscn")
# Direction of aim.
var aim : Vector2
# Position to spawn the bullet from.
var point : Vector2


func cast():
	if not is_on_cooldown:
		var trajectory = Trajectory.new()
		trajectory.direction = aim
		trajectory.speed = Constants.BULLET_SPEED
		
		var shot = bullet.instance()
		shot.trajectory = trajectory
		
		get_node("/root/Level").add_child(shot)
		shot.set_global_position(point)
		complete()
