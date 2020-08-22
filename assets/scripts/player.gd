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
var current : Tetromino
# The player can hold a tetromino for later use.
var hold : Tetromino
# Queue to generate tetrominos.
var queue = TetrominoQueue.new()
# Node path to the Player's HUD.
export (NodePath) var hud_path
export (NodePath) var ingame_menu_path
var ingame_menu
# PlayerHUD node to update.
onready var hud : PlayerHUD
# Reference to this player's camera.
onready var camera = $Camera2D
# Dash ability.
onready var dash = $Dash
onready var sound_dash = $SoundDash
onready var sound_knockback = $SoundKnockback
onready var sound_low_hp = $SoundLowHP


func _ready():
	hud = get_node(hud_path)
	ingame_menu = get_node(ingame_menu_path)
	next_tetromino()


func _process(_delta):
	if Input.is_action_just_pressed("action_special"):
		if not hold:
			hold = current
			next_tetromino()
		else:
			# The sacred three-way swap.
			var swap = hold
			hold = current
			current = swap
			hud.update_tetromino(self)


func _physics_process(_delta):	
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
				if body.is_in_group("enemy") and not body.is_locked():
					var push = body.move_and_collide(move)
					body.check_collision(push)


func heal(amount):
	.heal(amount)
	hud.update_hp(self)


# Checks if the player is currently controlling the given tetromino.
func is_current(tetromino : Tetromino):
	return current == tetromino


# Generates a random tetromino into 
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
	ingame_menu.button_resume.set_disabled(true)
	ingame_menu.title.set_text("You Died")
	ingame_menu.cannot_close = true
	ingame_menu.show()


# In addition to taking damage, update the PlayerHUD.
func oof(damage, bypass_lock=false):
	.oof(damage, bypass_lock)
	hud.update_hp(self)
	
	if is_dead() and camera.get_parent() == self:
		remove_child(camera)
		get_parent().add_child(camera)
		camera.set_global_position(get_global_position())
	elif get_hp() <= 0.2 * get_maximum_hp():
		sound_low_hp.play()
