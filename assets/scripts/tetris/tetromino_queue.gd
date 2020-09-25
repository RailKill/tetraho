class_name TetrominoQueue
extends Node
# Contains a queue of tetromino blocks using 7-bag randomization.


# Resource path of the tetromino object to be generated.
var resource = preload("res://assets/scenes/tetris/tetromino.tscn")
# List of tetromino configurations available for random generation.
var configurations = [
	# I-Block
	{"top": [1, 1, 1, 1], "bottom": [0, 0, 0, 0], "color": Color.aqua},
	# J-Block
	{"top": [0, 0, 1], "bottom": [1, 1, 1], "color": Color.mediumblue},
	# L-Block
	{"top": [1, 0, 0], "bottom": [1, 1, 1], "color": Color.orange},
	# O-Block
	{"top": [1, 1], "bottom": [1, 1], "color": Color.yellow},
	# S-Block
	{"top": [0, 1, 1], "bottom": [1, 1, 0], "color": Color.mediumspringgreen},
	# T-Block
	{"top": [0, 1, 0], "bottom": [1, 1, 1], "color": Color.purple},
	# Z-Block
	{"top": [1, 1, 0], "bottom": [0, 1, 1], "color": Color.mediumvioletred},
]
# Current index of the queue.
var index: int


func _init():
	refresh()


# Serve and return the next tetromino in queue.
func fetch():
	var tetromino = peek()
	index += 1
	if index >= configurations.size():
		refresh()
	return tetromino


# Returns the most current tetromino in queue.
func peek():
	var config = configurations[index]
	var tetromino = resource.instance()
	tetromino.load_configuration(
			config["top"], config["bottom"], config["color"])
	return tetromino


# Re-generate the queue with a new set of tetrominos in a randomized order.
func refresh():
	randomize()
	configurations.shuffle()
	index = 0
