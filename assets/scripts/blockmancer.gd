class_name Blockmancer
extends Enemy
# A type of enemy that can summon blocks. The blocks that a Blockmancer summon
# does not go away until solved.


# Spawn ability.
onready var spawner = $Spawn
# Sprite for animation.
onready var sprite = $AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	move_speed = Constants.BLOCKMANCER_MOVE_SPEED
	max_hp = Constants.BLOCKMANCER_HP
	hp = Constants.BLOCKMANCER_HP


func _physics_process(_delta):
	# Blockmancer behavior is to summon blocks.
	if player and is_aggro and not is_locked():
		# Behavior #1: Summon block on player's position.
		var pos = player.get_global_position()
		var snap = Vector2(stepify(pos.x, Constants.GRID_SIZE), 
			stepify(pos.y, Constants.GRID_SIZE))
		
		spawner.point = snap
		spawner.cast()


func play_casting_animation(_ability):
	sprite.play()


func play_casted_animation(_ability):
	sprite.stop()
	sprite.set_frame(0)
