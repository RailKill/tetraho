class_name Actor
extends KinematicBody2D
# An actor that can perform actions in the game.


# Emitted when the actor takes damage.
signal damage_taken(attacker, verb, victim, amount)

export var hp = Constants.PLAYER_HP setget ,get_hp
export var max_hp = Constants.PLAYER_HP setget ,get_maximum_hp
export var move_speed = Constants.PLAYER_MOVE_SPEED
export var is_invulnerable = false
export(Constants.Team) var team = Constants.Team.MOBS

var checker_resource = load("res://assets/objects/areas/area_checker.tscn")

onready var collision_shape = $CollisionShape2D
onready var sound_hit = $SoundHit
onready var sound_death = $SoundDeath


func _to_string():
	return name


# Checks a given collision and react accordingly. By default, nothing happens.
func check_collision(_collision: KinematicCollision2D):
	pass


# Checks if actor is dead.
func is_dead():
	return hp <= 0


# Get the current hit points of this actor.
func get_hp():
	return hp


func get_hud():
	return null


# Get the maximum hit points for this actor.
func get_maximum_hp():
	return max_hp


# Heals the actor by the given amount.
func heal(amount):
	hp = clamp(hp + amount, 0, max_hp)


# Checks if actor is being locked.
func is_locked():
	return GameWorld.is_actor_locked(self)


# Damage the actor.
func oof(damage, bypass_lock=false, attacker=null, message=""):
	if not is_invulnerable and (bypass_lock or not is_locked()):
		hp -= damage
		print("%s took %d damage." % [name, damage])
		emit_signal("damage_taken", attacker, message, self, damage)
		
		if is_dead():
			play_death_animation()
			visible = false
			collision_shape.call_deferred("set_disabled", true)
		else:
			sound_hit.play()


# Animate the actor channeling the given ability.
func play_casting_animation(_ability):
	pass


# Animate the actor to finish casting based on the given ability.
func play_casted_animation(_ability):
	pass


# Animate the actor dying.
func play_death_animation():
	if not sound_death.is_playing():
		sound_death.play()
		yield(sound_death, "finished")
		queue_free()


# Animate the actor failing to cast the given ability.
func play_fail_animation(_ability):
	pass


# Unstuck this actor by checking for an empty space in adjacent grid cells.
func unstuck():
	var checker = checker_resource.instance()
	checker.is_snapped = true
	
	var still_stuck = true
	var directions = Constants.DIRECTIONALS.duplicate()
	
	while still_stuck:
		for i in range(0, directions.size()):
			var point = global_position + directions[i]
			checker.global_position = point
			get_parent().add_child(checker)
			var collided = yield(checker, "lifetime_expired")
			if not collided:
				still_stuck = false
				global_position = point
				break
			directions[i] *= 2

