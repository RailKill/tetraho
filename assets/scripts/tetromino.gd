class_name Tetromino
extends Node2D


# Number of pixels for grid snapping.
const GRID_SNAP = 14

var origin: Node2D
var reticle : Node2D
var solid : Node2D
var blocks = []
var targets = []
var summoner


func _ready():
	# Ensure solid blocks are not visible.
	origin = $Origin
	reticle = $Origin/Reticle
	solid = $Origin/Solid
	solid.set_visible(false)

	# Disable collision of solid blocks.
	blocks = solid.get_children()
	for block in blocks:
		block.disable_collision()

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


# Summons the tetromino into play.
func summon_piece():
	if is_valid_placement():
		reticle.set_visible(false)
		solid.set_visible(true)
		for block in blocks:
			block.enable_collision()
		summoner.next_tetromino()
	else:
		# Show an error feedback to the player. Invalid placement.
		pass
