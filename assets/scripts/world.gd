extends Node
# Global world of the game. Auto-loaded on every level.


# Dictionary of all blocks as keys, and list of actors trapped as values.
var blocks = {}
# List of vector offsets to check for horizontal 2x3 blocks.
var solver_horizontal = [
	Vector2(Constants.GRID_SIZE, 0),
	Vector2(Constants.GRID_DOUBLE, 0),
	Vector2(0, Constants.GRID_SIZE),
	Vector2(Constants.GRID_SIZE, Constants.GRID_SIZE),
	Vector2(Constants.GRID_DOUBLE, Constants.GRID_SIZE),
]
# List of vector offsets to check for vertical 2x3 blocks.
var solver_vertical = [
	Vector2(Constants.GRID_SIZE, 0),
	Vector2(0, Constants.GRID_SIZE),
	Vector2(Constants.GRID_SIZE, Constants.GRID_SIZE),
	Vector2(0, Constants.GRID_DOUBLE),
	Vector2(Constants.GRID_SIZE, Constants.GRID_DOUBLE),
]

onready var sound_solve = $SoundSolve


func is_actor_locked(actor):
	for trapped_actors in blocks.values():
		if trapped_actors.has(actor):
			return true
	return false


# Whenever a Tetromino is summoned, attempt to solve.
func solve():
	for block in blocks.keys():
		search(block, solver_horizontal)
		search(block, solver_vertical)
	
	var has_marked = false
	for block in blocks.keys():
		# Solve all marked blocks.
		if block.marked:
			for actor in blocks[block]:
				actor.oof(Constants.TETROMINO_DAMAGE, true)
			block.disable()
			has_marked = true
	
	if has_marked:
		sound_solve.play()


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
