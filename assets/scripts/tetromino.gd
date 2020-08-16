class_name Tetromino
extends Node2D


# Number of pixels for grid snapping.
const GRID_SNAP = 14

var reticle : Node2D
var solid : Node2D
var blocks = []
var targets = []
var is_controlled = true


func _ready():
	# Ensure solid blocks are not visible.
	reticle = $Reticle
	solid = $Solid
	solid.set_visible(false)

	# Disable collision of solid blocks.
	blocks = solid.get_children()
	for block in blocks:
		block.disable_collision()

	targets = reticle.get_children()


func _process(_delta):
	if is_controlled:
		# Summon tetromino.
		if Input.is_action_just_pressed("action_primary"):
			summon_piece()
		# Rotate tetromino.
		if Input.is_action_just_pressed("action_secondary"):
			rotate_piece()


func _input(event):
	if event is InputEventMouseMotion and is_controlled:
		# Get mouse position relative to the canvas.
		var mouse_position = get_global_mouse_position()
		
		# Only move tetromino in increments of GRID_SNAP.
		position.x = snap_to_grid(mouse_position.x)
		position.y = snap_to_grid(mouse_position.y)


# Checks if the target placement is valid or not.
func is_valid_placement():
	for target in targets:
		if not target.is_valid():
			return false
	return true


# Rotates the tetromino clockwise by 90 degrees.
func rotate_piece():
	rotation_degrees += 90


# Function to calculate grid snapping based on mouse position.
func snap_to_grid(position):
# warning-ignore:integer_division
	var snap = GRID_SNAP * (int(position) / GRID_SNAP)
# warning-ignore:integer_division
	if int(position) % GRID_SNAP > GRID_SNAP / 2:
		snap += GRID_SNAP
	return snap


# Summons the tetromino into play.
func summon_piece():
	if is_valid_placement():
		solid.set_visible(true)
		for block in blocks:
			block.enable_collision()
		is_controlled = false
	else:
		# Show an error feedback to the player. Invalid placement.
		pass
