class_name Actor
extends KinematicBody2D
# An actor that can perform actions in the game.


# Reference to the collision shape of the actor.
onready var collision_shape = $CollisionShape2D

# Hit points.
var hp = Constants.PLAYER_HP
# Maximum hit points.
var max_hp = Constants.PLAYER_HP
# Speed in which the actor can move.
var move_speed = Constants.PLAYER_MOVE_SPEED
# Invulnerable actor.
export var is_invulnerable = false
# Checks if this actor is being locked by a TetrominoBlock.
var locked_by = []


# Checks a given collision and react accordingly. By default, nothing happens.
func check_collision(_collision : KinematicCollision2D):
	pass


# Checks if actor is dead.
func is_dead():
	return hp <= 0


# Get the current hit points of this actor.
func get_hp():
	return hp

# Get the maximum hit points for this actor.
func get_maximum_hp():
	return max_hp


# Checks if actor is being locked.
func is_locked():
	return locked_by.size() > 0


# Damage the actor.
func oof(damage, bypass_lock=false):
	if not is_invulnerable and (bypass_lock or not is_locked()):
		hp -= damage
		print("%s took %d damage." % [name, damage])
		
		if is_dead():
			play_death_animation()


# Animate the actor channeling the given ability.
func play_casting_animation(_ability):
	pass


# Animate the actor to finish casting based on the given ability.
func play_casted_animation(_ability):
	pass


# Animate the actor dying.
func play_death_animation():
	queue_free()


# Animate the actor failing to cast the given ability.
func play_fail_animation(_ability):
	pass


# Unstuck this actor by checking for an empty space in adjacent grid cells.
func unstuck():
	var checker = preload("res://assets/objects/area_checker.tscn").instance()
	get_parent().add_child(checker)
	
	var still_stuck = true
	var directions = Constants.DIRECTIONALS.duplicate()
	
	while still_stuck:
		for i in range(0, directions.size()):
			var point = get_global_position() + directions[i]
			checker.snap_to_grid(point)
			yield(get_tree().create_timer(0.01), "timeout")
			if not checker.collided:
				still_stuck = false
				set_global_position(point)
				break
			directions[i] *= 2
	
	checker.queue_free()

