class_name GameWorld
extends Node2D
# Root node of the level. Every level must have a GameWorld as the root node.


# Array of all TetrominoBlocks global position present in the game world.
var blocks = []
# List of vector offsets to check for horizontal 2x3 blocks.
var solver_horizontal = [
	Vector2(14, 0), Vector2(28, 0),
	Vector2(0, 14), Vector2(14, 14), Vector2(28, 14)
]
# List of vector offsets to check for vertical 2x3 blocks.
var solver_vertical = [
	Vector2(14, 0),
	Vector2(0, 14), Vector2(14, 14),
	Vector2(0, 28), Vector2(14, 28)
]


# Whenever a TetrominoBlock is created, it should be added and tracked.
func add_block(block):
	blocks.append(block)


# Remove the given Tetromino block from the list.
func remove_block(block):
	blocks.erase(block)


# Whenever a Tetromino is summoned, attempt to solve.
func solve():
	for block in blocks:
		search(block, solver_horizontal)
		search(block, solver_vertical)
	
	var actors = []
	for block in blocks:
		# Solve all marked blocks.
		if block.marked:
			for actor in block.trapped:
				if not actors.has(actor):
					actors.append(actor)
			block.disable()
	
	# All solved actors take damage.
	for actor in actors:
		actor.oof(100, true)


# Search for block combinations in a given solver (area to search) and mark
# all satisfied blocks for destruction.
func search(anchor, solver):
	var satisfied = [anchor]
	for vector in solver:
		for search in blocks:
			if search.get_global_vector() == anchor.get_global_vector() + vector:
				satisfied.append(search)
	
	if satisfied.size() == solver.size() + 1:
		for solved in satisfied:
			solved.marked = true
		return true
	return false
