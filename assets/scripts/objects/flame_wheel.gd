extends Node2D
# Just a wheel of flamethrowers.


# Speed of rotation, multiplier to delta.
export var speed = 0.5


func _physics_process(delta):
	rotate(speed * delta)
