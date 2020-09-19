class_name Shoot
extends Trajectory
# This ability fires a bullet which follows its trajectory.


# The bullet resource to shoot.
export(PackedScene) var bullet = \
		preload("res://assets/scenes/objects/bullet.tscn")
# Position to spawn the bullet from.
export(Vector2) var spawn_point


func _ready():
	speed = Constants.BULLET_SPEED
	sound_cast.stream = load("res://assets/sounds/gunner_shoot.wav")


func cast():
	.cast()
	if not is_on_cooldown:
		var shot = bullet.instance()
		shot.trajectory = self
		
		caster.get_parent().add_child(shot)
		shot.global_position = spawn_point
		complete()
