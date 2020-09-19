class_name Gunner
extends Enemy


# The gun this gunner is holding.
onready var gun = $Gun
# Gun sprite.
onready var gun_sprite = gun.get_node("Sprite")
# Muzzle of the gun where the bullet will spawn.
onready var muzzle = gun.get_node("Muzzle")
# Ability of the gunner to shoot.
onready var shoot = $Shoot
onready var sound_shoot = $SoundShoot


# Called when the node enters the scene tree for the first time.
func _ready():
	move_speed = Constants.GUNNER_MOVE_SPEED
	max_hp = Constants.GUNNER_HP
	hp = Constants.GUNNER_HP


func _physics_process(_delta):
	var ready = not is_dead() and is_aggro and not is_locked()
	gun.set_visible(ready)
	
	if is_instance_valid(player) and ready:
		# Point gun at player.
		gun_sprite.flip_v = int(to_player_vector().normalized().x <= 0)
		gun.look_at(player.get_global_position())
		
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(
			muzzle.get_global_position(), player.get_global_position(), 
			[], Constants.Layer.ENVIRONMENT + Constants.Layer.ACTOR)
		
		# Fire weapon if there's an actor, don't care who, trigger happy dudes.
		if result and result.collider is Actor:
			shoot.direction = to_player_vector().normalized()
			shoot.spawn_point = muzzle.get_global_position()
			shoot.cast()
