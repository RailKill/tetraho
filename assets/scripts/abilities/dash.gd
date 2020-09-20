class_name Dash
extends Trajectory
# Dash ability that exudes a great burst of speed towards a single direction.


# Cooldown bonus if an enemy is hit by the dash.
export(float) var cooldown_bonus = 2

var sound_collide = AudioStreamPlayer2D.new()


func _ready():
	sound_collide.bus = AudioServer.get_bus_name(1)
	sound_cast.stream = load("res://assets/sounds/dash_start.wav")
	sound_collide.stream = load("res://assets/sounds/dash_collide.wav")
	sound_ready.stream = load("res://assets/sounds/dash_ready.wav")


func _physics_process(_delta):
	if is_active:
		# Move towards dash direction until dash duration is gone.
		var collision = caster.move_and_collide(direction * speed)
		# If collided with an enemy, knock it back and reset dash.
		if collision:
			var body = collision.get_collider()
			if body.is_in_group("pushable") and not body.is_locked():
				var knockback = Knockback.new()
				knockback.direction = direction
				knockback.duration = duration
				body.add_child(knockback)
				knockback.cast()
				sound_collide.play()
				complete()
				delay -= cooldown_bonus


func reset():
	.reset()
	direction = Vector2.ZERO
