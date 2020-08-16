class_name Player
extends Actor
# Controllable player character.


# List of tetrominos available for random generation.
const tetrominos = []
# Current tetromino being controlled.
var current : Tetromino
# The player can hold a tetromino for later use.
var hold : Tetromino
# Input map to vector directionals.
var direction = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}


func _process(_delta):
	if Input.is_action_just_pressed("action_special"):
		pass


func _physics_process(_delta):
	var move_vector = Vector2.ZERO
	
	for vector in direction:
		if Input.is_action_pressed(vector):
			move_vector += direction[vector]
		
	var _collision = move_and_collide(move_vector * move_speed)
