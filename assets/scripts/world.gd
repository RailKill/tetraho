extends Node
# Global world of the game. Auto-loaded on every level.


onready var sound_solve = $SoundSolve

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
	
	var has_marked = false
	var actors = []
	for block in blocks:
		# Solve all marked blocks.
		if is_instance_valid(block) and block.marked:
			for actor in block.trapped:
				if not actors.has(actor):
					actors.append(actor)
			block.disable()
			has_marked = true
	
	if has_marked:
		sound_solve.play()
		
	# All solved actors take damage.
	for actor in actors:
		if is_instance_valid(actor):
			actor.oof(100, true)


# Search for block combinations in a given solver (area to search) and mark
# all satisfied blocks for destruction.
func search(anchor, solver):
	if is_instance_valid(anchor):
		var satisfied = [anchor]
		for vector in solver:
			for search in blocks:
				if is_instance_valid(search) and search.get_global_vector() == \
					anchor.get_global_vector() + vector:
						satisfied.append(search)
		
		if satisfied.size() == solver.size() + 1:
			for solved in satisfied:
				solved.marked = true
			return true
		return false
