class_name Dash
extends Trajectory
# Dash ability that exudes a great burst of speed towards a single direction.


# Cooldown bonus if an enemy is hit by the dash.
export var cooldown_bonus : float
# TODO: Temporary, bad practice, please remove in future.
onready var sound_knockback = get_parent().get_node("SoundKnockback")


func _physics_process(_delta):
	if is_active:
		# Move towards dash direction until dash duration is gone.
		var collision = caster.move_and_collide(direction * speed)
		# If collided with an enemy, knock it back and reset dash.
		if collision:
			var body = collision.get_collider()
			# TODO: The group "enemy" should be renamed
			# to something more appropriate for a knockback-able group.
			if body.is_in_group("pushable") and not body.is_locked():
				var knockback = Knockback.new()
				knockback.direction = direction
				knockback.duration = duration
				body.add_child(knockback)
				knockback.cast()
				sound_knockback.play()
				complete()
				delay -= cooldown_bonus


func complete():
	.complete()
	update()


func reset():
	.reset()
	direction = Vector2.ZERO
	update()


func update():
	if caster.hud:
		caster.hud.update_dash(self)
