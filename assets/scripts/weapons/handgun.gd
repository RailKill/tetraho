class_name Handgun
extends Node2D


# The bullet resource that this gun produces.
export(PackedScene) var bullet = \
		preload("res://assets/scenes/objects/bullet.tscn")
# Muzzle velocity of this gun.
export(float) var velocity = Constants.BULLET_SPEED

onready var sprite = $Sprite
onready var muzzle = $Muzzle
onready var user: Actor = get_parent()


func _physics_process(_delta):
	if user.is_locked():
		visible = false


# Rotates the gun so that it looks at the given target.
func aim(target: Vector2):
	sprite.flip_v = int((target - global_position).normalized().x <= 0)
	look_at(target)


# Returns the muzzle position. Used for spawning bullets.
func get_muzzle_position():
	return muzzle.global_position
