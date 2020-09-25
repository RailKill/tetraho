class_name PlayerCharacter
extends Actor
# Controllable player character.


# Input map to vector directionals.
const DIRECTIONS = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}

# Current tetromino being controlled.
var current: Tetromino
# The player can hold a tetromino for later use.
var hold: Tetromino
# Queue to generate tetrominos.
var queue = TetrominoQueue.new()
# Checks if the player is controllable or not.
var is_controllable = true

onready var canvas = $CanvasLayer
onready var hud = $CanvasLayer/PlayerHUD setget ,get_hud
onready var menu = $CanvasLayer/IngameMenu
onready var camera = $Camera2D
onready var dash = $Dash
onready var sound_dash = $SoundDash
onready var sound_knockback = $SoundKnockback
onready var sound_low_hp = $SoundLowHP


func _ready():
	add_child(queue)
	next_tetromino()


func _physics_process(delta):
	if not is_controllable:
		return
	
	if Input.is_action_just_pressed("action_special"):
		hold_tetromino()
	
	if not is_dead() and not is_locked():
		var move_vector = Vector2.ZERO
		for vector in DIRECTIONS:
			if Input.is_action_pressed(vector):
				move_vector += DIRECTIONS[vector]
		
		# Trigger dash if a direction is held, and the dash button is pressed.
		if Input.is_action_just_pressed("action_dash") and move_vector:
			dash.direction = move_vector
			dash.cast()
		
		# If not dashing, move normally.
		if not dash.is_active:
			# warning-ignore:return_value_discarded
			move(move_vector * move_speed, delta)


func get_hud():
	return hud


func heal(amount):
	.heal(amount)
	hud.update_hp(self)


# Activate hold tetromino functionality.
func hold_tetromino():
	# If hold is empty, store current and call next tetromino.
	if not hold:
		hold = current
		next_tetromino()
	# Otherwise, swap hold with current.
	else:
		var swap = hold
		hold = current
		current = swap
		hud.update_tetromino(self)


# Checks if the player is currently controlling the given tetromino.
func is_current(tetromino: Tetromino):
	return current == tetromino


# Sets the next tetromino in the queue to current.
func next_tetromino():
	current = queue.fetch()
	current.summoner = self
	get_parent().call_deferred("add_child", current)
	yield(current, "ready")
	hud.update_tetromino(self)


func play_death_animation():
	.play_death_animation()
	yield(self, "tree_exited")
	menu.button_resume.set_disabled(true)
	menu.title.set_text("You Died")
	menu.cannot_close = true
	menu.show()


# In addition to taking damage, update the PlayerHUD.
func oof(damage, bypass_lock=false, attacker=null, message=""):
	.oof(damage, bypass_lock, attacker, message)
	hud.update_hp(self)
	
	if is_dead() and camera.get_parent() == self:
		# Reparent camera.
		remove_child(camera)
		get_parent().add_child(camera)
		camera.set_global_position(get_global_position())
		
		# Reparent canvas.
		remove_child(canvas)
		get_parent().add_child(canvas)
		
		# Destroy current and hold tetrominos.
		current.queue_free()
		if is_instance_valid(hold):
			hold.queue_free()
		
	elif get_hp() <= 0.2 * get_maximum_hp():
		sound_low_hp.play()
