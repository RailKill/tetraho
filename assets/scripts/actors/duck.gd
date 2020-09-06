class_name Duck
extends Enemy


# Get navigation.
onready var navigation = get_parent().get_node("Navigation2D")
# Reference to the area damage resource.
onready var area_damage = preload("res://assets/objects/areas/area_damage.tscn")
# Duck sprite.
onready var sprite = $Sprite
onready var sound_warning = $SoundWarning
onready var animation = $AnimationPlayer
# Paths to navigate to the player.
var paths : PoolVector2Array = []
# Current path index.
var path_index = 0
# Delay in seconds before an attack begins.
var attack_delay_startup : float
# Delay in seconds before another attack can be attempted again.
var attack_delay_cooldown : float
# Checks if duck is attacking.
var is_attacking : bool
# Checks if duck attack is on cooldown.
var is_on_cooldown : bool
# Issue a new move command after every X seconds.
var pathing_cooldown : float


# Called when the node enters the scene tree for the first time.
func _ready():
	move_speed = Constants.DUCK_MOVE_SPEED
	max_hp = Constants.DUCK_HP
	hp = Constants.DUCK_HP
	reset_attack()
	reset_pathing()


# Behavior of duck is to chase the player. Attacks when close.
func _physics_process(delta):
	if not is_dead() and is_instance_valid(player) and is_aggro and not is_locked():
		var difference = to_player_vector()
	
		pathing_cooldown -= delta
		if pathing_cooldown <= 0:
			reset_pathing()
	
		if not is_attacking:
			# If duck is not attacking, move towards player.	
			if path_index < paths.size():
				var to_path = (paths[path_index] - get_global_position())
				if to_path.length() < Constants.GRID_HALF:
					path_index += 1
	
				# Turn duck to face path.
				sprite.flip_h = int(difference.normalized().x <= 0)
				var _collision = move_and_collide(
					move_speed * to_path.normalized())
	
			# If player is close enough, perform an attack!
			if difference.length() < Constants.GRID_ONE_HALF \
				and not is_on_cooldown:
					is_attacking = true
					sound_warning.play()
					animation.play("Attack")
		else:
			attack_delay_startup -= delta
			if attack_delay_startup <= 0:
				commence_attack(difference.normalized())
	
		# Handle cooldown.
		if is_on_cooldown:
			attack_delay_cooldown -= delta
			if attack_delay_cooldown < 0:
				is_on_cooldown = false
				reset_attack()


# After attack_delay Spawns an AreaDamage at the direction.
func commence_attack(direction : Vector2):
	is_attacking = false
	is_on_cooldown = true
	var scratch = area_damage.instance()
	scratch.creator = self
	scratch.translate(direction * 16)
	add_child(scratch)
	scratch.animation.play()
	$exclamation_popup.set_visible(false)


# If the given collider is a DuckHouse, kill both.
func check_collision(collision : KinematicCollision2D):
	if collision:
		var collider = collision.get_collider()
		if collider is DuckHouse:
			collider.is_invulnerable = false
			collider.oof(collider.max_hp)
			oof(max_hp)


# Resets the attack.
func reset_attack():
	attack_delay_cooldown = 2
	attack_delay_startup = 0.5
	is_attacking = false
	is_on_cooldown = false


# Resets the pathing and issue a new move command towards the player.
func reset_pathing():
	var to_player = player.get_global_position() + \
		to_self_vector().normalized() * Constants.GRID_SIZE
	paths = navigation.get_simple_path(get_global_position(), to_player)
	path_index = 0
	pathing_cooldown = Constants.AI_PATHING_COOLDOWN
