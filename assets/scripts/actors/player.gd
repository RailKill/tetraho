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

onready var canvas = $CanvasLayer
onready var hud = $CanvasLayer/PlayerHUD
onready var menu = $CanvasLayer/IngameMenu
onready var camera = $Camera2D
onready var dash = $Dash
onready var sound_dash = $SoundDash
onready var sound_knockback = $SoundKnockback
onready var sound_low_hp = $SoundLowHP


func _ready():
	next_tetromino()


func _physics_process(_delta):
	if Input.is_action_just_pressed("action_special"):
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
	
	if not is_dead() and not is_locked():
		var move_vector = Vector2.ZERO
		for vector in DIRECTIONS:
			if Input.is_action_pressed(vector):
				move_vector += DIRECTIONS[vector]
		
		# Trigger dash if a direction is held, and the dash button is pressed.
		if Input.is_action_just_pressed("action_dash") and move_vector:
			dash.direction = move_vector
			dash.cast()
		
		if not dash.is_active:
			# If not dashing, move normally.
			var move = move_vector * move_speed
			var collision = move_and_collide(move)
			# Push other actors to prevent getting stuck.
			if collision:
				var body = collision.get_collider()
				if body.is_in_group("pushable") and not body.is_locked():
					var push = body.move_and_collide(move)
					body.check_collision(push)


func heal(amount):
	.heal(amount)
	hud.update_hp(self)


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


func play_casting_animation(ability):
	if ability is Dash:
		sound_dash.play()


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
