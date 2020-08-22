class_name Boss
extends Enemy
# Code here is mostly copied and pasted from Duck and Gunner.
# TODO: Running out of time for #mizjam1, refactor next time.


onready var crown = preload("res://assets/objects/loot/crown.tscn")
onready var teleport_animation = $AnimatedSprite
onready var sound_teleport = $SoundTeleport
var teleport_points : Array
var is_gunner_time = false
var is_casting = false

# ===============
# DUCK VARIABLES
# ===============
onready var navigation = get_parent().get_node("Navigation2D")
onready var area_damage = preload("res://assets/objects/area_damage.tscn")
onready var sprite = $Sprite
var paths : PoolVector2Array = []
var path_index = 0
var attack_delay_startup : float
var attack_delay_cooldown : float
var is_attacking : bool
var is_on_cooldown : bool
var pathing_cooldown : float

# ================
# GUNNER VARIABLES
# ================
onready var gun = $Gun
onready var gun_sprite = gun.get_node("Sprite")
onready var muzzle = gun.get_node("Muzzle")
onready var shoot = $Shoot
onready var sound_shoot = $SoundShoot


# Called when the node enters the scene tree for the first time.
func _ready():
	move_speed = Constants.BOSS_MOVE_SPEED
	max_hp = Constants.BOSS_HP
	hp = Constants.BOSS_HP
	reset_attack()
	reset_pathing()
	gun.set_visible(false)


func _physics_process(delta):
	if is_dead():
		return
	
	if is_locked():
		gun.set_visible(false)
	
	if is_casting:
		gun.set_visible(false)
		return
	
	if player and is_aggro and not is_locked():
		if to_player_vector().length() < 96:
			do_duck_logic(delta)
		else:
			do_gunner_logic()


# After attack_delay Spawns an AreaDamage at the direction.
func commence_attack(direction : Vector2):
	is_attacking = false
	is_on_cooldown = true
	var scratch = area_damage.instance()
	scratch.translate(direction * 16)
	add_child(scratch)
	scratch.animation.play()


# If the given collider is a DuckHouse, kill both.
func check_collision(collision : KinematicCollision2D):
	if collision:
		var collider = collision.get_collider()
		if collider is DuckHouse:
			collider.is_invulnerable = false
			collider.oof(collider.max_hp)
			oof(max_hp)


# Perform duck behavior.
func do_duck_logic(delta):
	gun.set_visible(false)
	
	var difference = player.get_position() - get_position()
	pathing_cooldown -= delta
	if pathing_cooldown <= 0:
		reset_pathing()

	if not is_attacking:
		# If duck is not attacking, move towards player.	
		if path_index < paths.size():
			var to_path = (paths[path_index] - get_position())
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


func do_gunner_logic():
	gun.set_visible(true)
	# Point gun at player.
	gun_sprite.flip_v = int(to_player_vector().normalized().x <= 0)
	gun.look_at(player.get_global_position())
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(
		muzzle.get_global_position(), player.get_global_position(), 
		[], Constants.Layer.ENVIRONMENT + Constants.Layer.ACTOR)
	
	# Fire weapon if there's an actor, don't care who, trigger happy dudes.
	if result and result.collider is Actor:
		shoot.aim = to_player_vector().normalized()
		shoot.point = muzzle.get_global_position()
		shoot.cast()


func is_half_hp():
	return hp <= max_hp / 2


func oof(damage, bypass_lock=false):
	.oof(damage, bypass_lock)
	
	if is_dead():
		var loot = crown.instance()
		get_parent().add_child(loot)
		loot.set_global_position(get_global_position())
	else:
		teleport()


# Resets the attack.
func reset_attack():
	attack_delay_cooldown = 0.5
	attack_delay_startup = 0.5
	is_attacking = false
	is_on_cooldown = false


# Resets the pathing and issue a new move command towards the player.
func reset_pathing():
	var to_player = player.get_position() + (get_position() - \
		player.get_position()).normalized() * Constants.GRID_SIZE
	paths = navigation.get_simple_path(get_position(), to_player)
	path_index = 0
	pathing_cooldown = Constants.AI_PATHING_COOLDOWN


func teleport(index=-1):
	if teleport_points:
		var selected
		if index != -1:
			selected = index
		else:
			randomize()
			selected = randi() % teleport_points.size()
			
		set_global_position(teleport_points[selected])
		teleport_animation.play()
		sound_teleport.play()
		

func play_casted_animation(ability):
	if ability is Shoot:
		sound_shoot.play()
