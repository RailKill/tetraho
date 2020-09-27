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
# Dictionary of last marked blocks for destruction, with empty values.
var marked = {}
# Dictionary of global vectors to blocks for fast position-based lookup.
var vectors = {}

# Reference to the AudioStreamPlayer2D node which plays the solve sound.
onready var sound_solve = $SoundSolve


# Keep track of a block for solving.
func add_block(block):
	blocks[block] = []
	vectors[block.summoned_position] = block


# Remove a block from the world record.
func remove_block(block):
	blocks.erase(block)
	vectors.erase(block.summoned_position)


# Checks the blocks record if a given actor is trapped.
func is_actor_locked(actor):
	for trapped_actors in blocks.values():
		if trapped_actors.has(actor):
			return true
	return false


# Checks if given block is overlapping with an existing one and removes it.
func is_overlapping_block(block):
	if vectors.get(block.get_global_vector()):
		block.queue_free()
		return true
	return false


# Whenever a Tetromino is summoned, attempt to solve.
func solve():
	marked = {}
	for block in blocks.keys():
		search(block, SOLVER_HORIZONTAL)
		search(block, SOLVER_VERTICAL)
	
	var actors = {}
	# Solve all marked blocks.
	for block in marked.keys():
		for actor in blocks[block]:
			actors[actor] = null
		block.disable()
	
	if not marked.empty():
		sound_solve.play()
	
	for actor in actors.keys():
		actor.oof(Constants.TETROMINO_DAMAGE, true)


# Search for block combinations in a given solver (area to search) and mark
# all satisfied blocks for destruction. Returns true if a solution is found.
func search(anchor, solver):
	var satisfied = [anchor]
	for vector in solver:
		var lookup = vectors.get(anchor.summoned_position + vector)
		if lookup:
			satisfied.append(lookup)
		else:
			return false
	
	for solved in satisfied:
		marked[solved] = true
	return true
