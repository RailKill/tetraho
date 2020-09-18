class_name Tetromino
extends Node2D
# Tetromino block containing a group of target reticles with their
# corresponding blocks. By definition, each Tetromino will have
# 4 blocks, and in each of those block's position, it must have a target
# reticle for the player to see. The target reticle is important because it
# checks if the placement is valid, and also for the lock mechanic.


# If this is false, the block will stay in the world forever until solved.
export(bool) var can_decay = true
# If this is true, automatically summon it when ready.
export(bool) var is_auto = false
# Time in seconds for this tetromino to disappear after being summoned.
export(float) var decay_time = Constants.TETROMINO_DECAY_TIME
# Time in seconds for this tetromino to appear after being summoned.
export(float) var summon_time = Constants.TETROMINO_SUMMON_TIME
# Color of the tetromino blocks.
export(Color) var color = Color.white
# List of Vector2 positions to spawn the blocks.
export(PoolVector2Array) var configuration = [Vector2.ZERO]
# Resource path to the type of block that will be spawned.
export(PackedScene) var block_res = \
		preload("res://assets/objects/tetris/tetromino_block.tscn")
# Resource path to the type of target reticle for the tetromino.
export(PackedScene) var target_res = \
		preload("res://assets/objects/tetris/tetromino_target.tscn")

# If the tetromino is in the process of being summoned, this will be true.
var is_summoning = false
# If the tetromino already passed decay_time and is dying, this will be true.
var is_decaying = false
# The PlayerCharacter who summons this tetromino.
var summoner
# Number of blocks that made up the width of this tetromino.
var width = 0

onready var reticle = $Reticle
onready var solid = $Solid
onready var sound_invalid = $SoundInvalid
onready var sound_confirm = $SoundConfirm
onready var sound_trap = $SoundTrap


func _ready():
	for vector in configuration:
		var target = target_res.instance()
		target.position = vector
		reticle.add_child(target)
		
		var block = block_res.instance()
		block.modulate = color
		block.position = vector
		solid.add_child(block)
	
	toggle_blocks(false)
	if summoner and summoner.is_current(self):
		snap_to_mouse()
	if is_auto:
		summon_piece()


func _physics_process(delta):
	# Handle controls.
	if summoner and summoner.is_current(self):
		if Input.is_action_just_pressed("action_primary"):
			summon_piece()
		elif Input.is_action_just_pressed("action_secondary"):
			rotate_piece()
		snap_to_mouse()
	
	# If the tetromino is summoning, start countdown.
	if is_summoning:
		summon_time -= delta
		if summon_time <= 0:
			# For each target reticle, get the actors who are in there.
			for i in range(reticle.get_child_count()):
				solid.get_child(i).enable()
				for body in reticle.get_child(i).get_overlapping_bodies():
					# Perform a lock for trappable bodies.
					if body.is_in_group("trappable"):
						solid.get_child(i).trap(body)
						sound_trap.play()
			
			is_summoning = false
			reticle.queue_free()
			solid.visible = true
			GameWorld.solve()
	
	# If the solid blocks are visible, that means they are active.
	# Start decaying to be removed from the game.
	elif can_decay and is_summoned():
		decay_time -= delta
		if decay_time <= 0:
			if not is_decaying:
				is_decaying = true
				for block in solid.get_children():
					block.disable()
			
			if solid.get_child_count() == 0:
				queue_free()


# Odd width configurations are centered in a way where it does not adhere to
# grid snapping. Call this function to correct that offset.
func _correct_positioning():
	if width % 2 != 0:
		if rotation_degrees == 0 or int(rotation_degrees) % 180 == 0:
			position.x += Constants.GRID_HALF 
		else:
			position.y += Constants.GRID_HALF


func is_summoned():
	return not is_instance_valid(reticle)


# Checks if the target placement is valid or not.
func is_valid_placement():
	for target in reticle.get_children():
		if not target.is_valid():
			return false
	return true


# Create the given configuration of blocks to form the tetromino.
func load_configuration(top: PoolIntArray, bottom: PoolIntArray, hue: Color):
	configuration = []
	color = hue
	width = min(top.size(), bottom.size())
	var start = -Constants.GRID_SIZE * width / 2
	var index = 0
	
	while index < width:
		if top[index]:
			configuration.append(Vector2(start + index * Constants.GRID_SIZE, 
					-Constants.GRID_SIZE))
		if bottom[index]:
			configuration.append(
					Vector2(start + index * Constants.GRID_SIZE, 0))
		index += 1


# Rotates the tetromino clockwise by 90 degrees.
func rotate_piece():
	rotation_degrees += 90


# Function to calculate grid snapping based on mouse position.
func snap_to_grid(position):
	# warning-ignore:integer_division
	var snap = Constants.GRID_SIZE * \
			(int(round(position)) / Constants.GRID_SIZE)
	return snap


# Snap tetromino to mouse.
func snap_to_mouse():
	# Get mouse position relative to the canvas.
	var mouse_position = get_global_mouse_position()
	
	# Only move tetromino in increments of GRID_SNAP.
	position.x = snap_to_grid(mouse_position.x)
	position.y = snap_to_grid(mouse_position.y)
	_correct_positioning()
	
	if is_valid_placement():
		reticle.modulate = Color.white
	else:
		reticle.modulate = Color(0.8, 0.1, 0.1, 1)


# Summons the tetromino into play.
func summon_piece():
	if is_valid_placement():
		is_summoning = true
		# Play summoning animation on all target reticles.
		for target in reticle.get_children():
			target.animate()
		if summoner:
			summoner.next_tetromino()
		
		sound_confirm.play()
	else:
		# Show an error feedback to the player. Invalid placement.
		sound_invalid.play()


# Show or hide blocks without activating them.
func toggle_blocks(toggle : bool):
	reticle.visible = !toggle
	solid.visible = toggle
	
	# Toggle collision of solid blocks and their completed animation frames.
	for block in solid.get_children():
		block.summon.set_frame(
				block.summon.frames.get_frame_count("default") * int(toggle))
