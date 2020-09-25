extends Node
# Global world of the game. Auto-loaded on every level.


# List of vector offsets to check for horizontal 2x3 blocks.
const SOLVER_HORIZONTAL = [
	Vector2(Constants.GRID_SIZE, 0),
	Vector2(Constants.GRID_DOUBLE, 0),
	Vector2(0, Constants.GRID_SIZE),
	Vector2(Constants.GRID_SIZE, Constants.GRID_SIZE),
	Vector2(Constants.GRID_DOUBLE, Constants.GRID_SIZE),
]
# List of vector offsets to check for vertical 2x3 blocks.
const SOLVER_VERTICAL = [
	Vector2(Constants.GRID_SIZE, 0),
	Vector2(0, Constants.GRID_SIZE),
	Vector2(Constants.GRID_SIZE, Constants.GRID_SIZE),
	Vector2(0, Constants.GRID_DOUBLE),
	Vector2(Constants.GRID_SIZE, Constants.GRID_DOUBLE),
]

# Dictionary of all blocks as keys, and list of actors trapped as values.
var blocks = {}

onready var sound_solve = $SoundSolve


# Checks the blocks record if a given actor is trapped.
func is_actor_locked(actor):
	for trapped_actors in blocks.values():
		if trapped_actors.has(actor):
			return true
	return false


# Checks if given block is overlapping with an existing one and removes it.
func is_overlapping_block(block):
	for key in blocks.keys():
		if key.global_position == block.global_position:
			block.queue_free()
			return true
	return false


# Whenever a Tetromino is summoned, attempt to solve.
func solve():
	for block in blocks.keys():
		search(block, SOLVER_HORIZONTAL)
		search(block, SOLVER_VERTICAL)
	
	var has_marked = false
	var actors = []
	for block in blocks.keys():
		# Solve all marked blocks.
		if block.marked:
			for actor in blocks[block]:
				if not actors.has(actor):
					actors.append(actor)
			block.disable()
			has_marked = true
	
	if has_marked:
		sound_solve.play()
		for actor in actors:
			actor.oof(Constants.TETROMINO_DAMAGE, true)


# Search for block combinations in a given solver (area to search) and mark
# all satisfied blocks for destruction. Returns true if a solution is found.
func search(anchor, solver):
	var satisfied = [anchor]
	for vector in solver:
		for block in blocks.keys():
			if block.get_global_vector() == anchor.get_global_vector() + vector:
				satisfied.append(block)
	
	if satisfied.size() == solver.size() + 1:
		for solved in satisfied:
			solved.marked = true
		return true
	return false
