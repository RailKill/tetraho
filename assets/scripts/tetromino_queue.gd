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

var queue : Array
var index : int


func _init():
	refresh()


# Returns the next tetromino in queue.
func fetch():
	print(index)
	var tetromino = queue[index]
	index += 1
	
	if index >= queue.size():
		refresh()
	
	return tetromino


# Re-generate the queue with a new set of tetrominos in a randomized order.
func refresh():
	randomize()
	generator.shuffle()
	index = 0
	queue = []
	for tetromino in generator:
		queue.append(tetromino.instance())
