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
			queue_free()
