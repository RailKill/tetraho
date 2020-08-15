class_name Player
extends Actor
# Controllable player character.


# Input map to vector directionals.
var direction = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}


func _physics_process(delta):
	var move_vector = Vector2.ZERO
	
	for vector in direction:
		if Input.is_action_pressed(vector):
			move_vector += direction[vector]
		
	move_and_collide(move_vector * move_speed)
