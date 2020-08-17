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
# PlayerHUD node to update.
onready var hud : PlayerHUD

# Cooldown of dash ability.
var dash_cooldown = 3
# Delay before dash can be used again in seconds.
var dash_delay : float
# Duration of dash in seconds.
var dash_duration : float
# Direction of dash.
var dash_direction : Vector2
# Speed of dash.
var dash_speed = 200
# Checks if player is dashing.
var is_dashing = false
# Checks if dash is on cooldown.
var is_on_cooldown = false


func _ready():
	hud = get_node(hud_path)
	reset_dash()
	next_tetromino()


func _process(_delta):
	if Input.is_action_just_pressed("action_special"):
		pass


func _physics_process(delta):	
	var move_vector = Vector2.ZERO
	for vector in DIRECTIONS:
		if Input.is_action_pressed(vector):
			move_vector += DIRECTIONS[vector]
	
	# Trigger dash if a direction is held, and the dash button is pressed.
	if Input.is_action_just_pressed("action_dash") and move_vector:
		if not is_on_cooldown:
			is_dashing = true
			dash_direction = move_vector
	
	if not is_dashing:
		# If not dashing, move normally.
		var _collision = move_and_collide(move_vector * move_speed)
		
		# Handle dash cooldown.
		if is_on_cooldown:
			dash_delay -= delta
			if dash_delay <= 0:
				is_on_cooldown = false
				reset_dash()
				hud.update_dash(self)
	else:
		# Otherwise, move towards dash direction until dash duration is gone.
		dash_duration -= delta
		if dash_duration > 0:
			var _collision = move_and_slide(dash_direction * dash_speed)
		else:
			is_dashing = false
			is_on_cooldown = true
			hud.update_dash(self)


# Checks if the player is currently controlling the given tetromino.
func is_current(tetromino : Tetromino):
	return current == tetromino


# Generates a random tetromino into 
func next_tetromino():
	current = queue.fetch()
	current.summoner = self
	get_parent().call_deferred("add_child", current)


# In addition to taking damage, update the PlayerHUD.
func oof(damage):
	.oof(damage)
	hud.update_hp(self)


# Reset the dash cooldown.
func reset_dash():
	dash_delay = dash_cooldown
	dash_duration = 0.3
	dash_direction = Vector2.ZERO
