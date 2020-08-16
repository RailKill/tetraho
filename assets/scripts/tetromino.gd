class_name Tetromino
extends Node2D


# Number of pixels for grid snapping.
const GRID_SNAP = 14
# Reference to the rotation origin node.
var origin: Node2D
# Reference to the node containing target reticles.
var reticle : Node2D
# Reference to the node containing solid blocks of the tetromino.
var solid : Node2D
# List of solid blocks.
var blocks = []
# List of target reticles.
var targets = []
# The PlayerCharacter who summons this tetromino.
var summoner
# Time in seconds for this tetromino to disappear after being summoned.
var decay_time = 3
# Time in seconds for this tetromino to appear after being summoned.
var summon_time = 1
var is_summoning = false
var is_decaying = false


func _ready():
	# Ensure solid blocks are not visible.
	origin = $Origin
	reticle = $Origin/Reticle
	solid = $Origin/Solid
	solid.set_visible(false)

	# Disable collision of solid blocks.
	blocks = solid.get_children()
	for block in blocks:
		block.collision_shape.disabled = true

	targets = reticle.get_children()
	snap_to_mouse()


func _process(_delta):
	if summoner.is_current(self):
		# Summon tetromino.
		if Input.is_action_just_pressed("action_primary"):
			summon_piece()
		# Rotate tetromino.
		if Input.is_action_just_pressed("action_secondary"):
			rotate_piece()


func _physics_process(delta):
	# If the tetromino is summoning, start countdown.
	if is_summoning:
		summon_time -= delta
		if summon_time <= 0:
			reticle.set_visible(false)
			solid.set_visible(true)
			for block in blocks:
				block.enable()
			is_summoning = false
	
	# If the solid blocks are visible, that means they are active.
	# Start decaying to be removed from the game.
	if solid.visible:
		decay_time -= delta
		if decay_time <= 0:
			if not is_decaying:
				is_decaying = true
				for block in blocks:
					block.disable()
			
			var null_count = 0
			for block in blocks:
				null_count += int(block == null)
			if null_count == blocks.size():
				queue_free()


func _input(event):
	if event is InputEventMouseMotion:
		snap_to_mouse()


# Checks if the target placement is valid or not.
func is_valid_placement():
	for target in targets:
		if not target.is_valid():
			return false
	return true


# Rotates the tetromino clockwise by 90 degrees.
func rotate_piece():
	origin.rotation_degrees += 90


# Function to calculate grid snapping based on mouse position.
func snap_to_grid(position):
# warning-ignore:integer_division
	var snap = GRID_SNAP * (int(position) / GRID_SNAP)
# warning-ignore:integer_division
	if int(position) % GRID_SNAP > GRID_SNAP / 2:
		snap += GRID_SNAP
	return snap


# Snap tetromino to mouse.
func snap_to_mouse():
	if summoner.is_current(self):
		# Get mouse position relative to the canvas.
		var mouse_position = get_global_mouse_position()
		
		# Only move tetromino in increments of GRID_SNAP.
		position.x = snap_to_grid(mouse_position.x)
		position.y = snap_to_grid(mouse_position.y)
		
		if is_valid_placement():
			reticle.set_modulate(Color.white)
		else:
			reticle.set_modulate(Color(0.8, 0.1, 0.1, 1))


# Summons the tetromino into play.
func summon_piece():
	if is_valid_placement():
		is_summoning = true
		# Play summoning animation on all target reticles.
		for target in targets:
			target.animate()
		summoner.next_tetromino()
	else:
		# Show an error feedback to the player. Invalid placement.
		pass
