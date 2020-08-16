class_name PlayerCharacter
extends Actor
# Controllable player character.


# Input map to vector directionals.
const DIRECTIONS = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}

# Current tetromino being controlled.
var current : Tetromino
# The player can hold a tetromino for later use.
var hold : Tetromino
# Queue to generate tetrominos.
var queue = TetrominoQueue.new()


func _ready():
	next_tetromino()


func _process(_delta):
	if Input.is_action_just_pressed("action_special"):
		pass


func _physics_process(_delta):
	var move_vector = Vector2.ZERO
	
	for vector in DIRECTIONS:
		if Input.is_action_pressed(vector):
			move_vector += DIRECTIONS[vector]
		
	var _collision = move_and_collide(move_vector * move_speed)


# Checks if the player is currently controlling the given tetromino.
func is_current(tetromino : Tetromino):
	return current == tetromino


# Generates a random tetromino into 
func next_tetromino():
	current = queue.fetch()
	current.summoner = self
	get_parent().call_deferred("add_child", current)
