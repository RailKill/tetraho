class_name GameWorld
extends Node2D


# Array of all TetrominoBlocks global position present in the game world.
var blocks = []

var solver_horizontal = [
	Vector2(14, 0), Vector2(28, 0),
	Vector2(0, 14), Vector2(14, 14), Vector2(28, 14)
]


# Whenever a TetrominoBlock is created, it should be added and tracked.
func add_block(block):
	blocks.append(block)


# Remove the given Tetromino block from the list.
func remove_block(block):
	blocks.erase(block)


# Also, whenever a Tetromino is summoned, attempt to solve.
func solve():
	for block in blocks:
		print(search(block, solver_horizontal))
	
	for block in blocks:
		block.solve()


func search(anchor, solver):
	var satisfied = [anchor]
	for vector in solver:
		for search in blocks:
			if search.get_global_vector() == anchor.get_global_vector() + vector:
				satisfied.append(search)
	
	if satisfied.size() == 6:
		for solved in satisfied:
			solved.marked = true
		return true
	return false
	
	#print($Area2D.get_overlapping_bodies())
#	print(blocks)
