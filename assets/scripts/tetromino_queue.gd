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
# List of tetrominos in the current queue.
var queue: Array


func _init():
	refresh()


# Serve and return the next tetromino in queue.
func fetch():
	var tetromino = queue[index]
	index += 1
	
	if index >= queue.size():
		refresh()
	
	return tetromino


# Returns the most current tetromino in queue.
func peek():
	return queue[index]


# Re-generate the queue with a new set of tetrominos in a randomized order.
func refresh():
	randomize()
	configurations.shuffle()
	index = 0
	queue = []
	for config in configurations:
		var tetromino = resource.instance()
		tetromino.load_configuration(
				config["top"], config["bottom"], config["color"])
		queue.append(tetromino)
