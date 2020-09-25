class_name Aim
extends Target
# Behavior which aims a weapon at a target.


# Weapon to aim.
var weapon: Handgun


func _init(actor, goal, gun, extent=0).(actor, goal, extent):
	weapon = gun


func execute(_delta) -> bool:
	if is_close_enough():
		weapon.visible = true
		weapon.aim(target.global_position)
		
		var space_state = executor.get_world_2d().direct_space_state
		var result = space_state.intersect_ray(
			weapon.get_muzzle_position(), target.global_position, 
			[], Constants.Layer.ENVIRONMENT + Constants.Layer.ACTOR)
		
		# If actor is not in sights while aiming, return false to stop.
		return result and result.collider is Actor
	else:
		# Aiming didn't take place at all, return true to continue next.
		weapon.visible = false
		return true
