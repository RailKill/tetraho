class_name Dash
extends Trajectory
# Dash ability that exudes a great burst of speed towards a single direction.


# Cooldown bonus if an enemy is hit by the dash.
export(float) var cooldown_bonus = 2

var sound_collide = AudioStreamPlayer2D.new()


func _ready():
	sound_cast.stream = load("res://assets/sounds/dash_start.wav")
	sound_collide.stream = load("res://assets/sounds/dash_collide.wav")
	sound_ready.stream = load("res://assets/sounds/dash_ready.wav")
	sound_collide.bus = AudioServer.get_bus_name(1)
	add_child(sound_collide)


func _physics_process(delta):
	if is_active:
		# Move towards dash direction until dash duration is gone.
		var colliders = caster.move(direction * speed, delta)
		# If collided with an enemy, knock it back and reset dash.
		for collider in colliders:
			if collider.is_in_group("pushable") and not collider.is_locked():
				var knockback = Knockback.new()
				knockback.direction = direction
				knockback.duration = duration
				knockback.speed = speed
				collider.add_child(knockback)
				knockback.cast()
				sound_collide.play()
				complete()
				delay -= cooldown_bonus


func reset():
	.reset()
	direction = Vector2.ZERO
