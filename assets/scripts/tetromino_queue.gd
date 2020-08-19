class_name TetrominoQueue
extends Node
# Contains a queue of tetromino blocks, randomized 7-bag.


# List of tetrominos available for random generation.
var generator = [
	preload("res://assets/objects/tetris/i_block.tscn"),
	preload("res://assets/objects/tetris/o_block.tscn"),
	preload("res://assets/objects/tetris/j_block.tscn"),
	preload("res://assets/objects/tetris/l_block.tscn"),
	preload("res://assets/objects/tetris/s_block.tscn"),
	preload("res://assets/objects/tetris/z_block.tscn"),
	preload("res://assets/objects/tetris/t_block.tscn")
]

# List of tetrominos in the current queue.
var queue : Array
# Current index of the queue.
var index : int


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
	generator.shuffle()
	index = 0
	queue = []
	for tetromino in generator:
		queue.append(tetromino.instance())
