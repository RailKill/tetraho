class_name Follow
extends Target
# Moves executor towards a given target node using the given navigation node.


var navigation: Navigation2D
var paths: PoolVector2Array = []
var pathing_cooldown = Constants.AI_PATHING_COOLDOWN
var path_index = 0


func _init(actor, goal, nav, extent=0).(actor, goal, extent):
	navigation = nav


func execute(delta) -> bool:
	var result = true
	# If the distance is too far to follow, just continue to next behavior.
	if is_close_enough():
		# Result is set to false here once the target is actually within range.
		# This will prevent execution of next behavior and focus only on follow.
		result = false
		pathing_cooldown -= delta
		if pathing_cooldown <= 0:
			reset_pathing()
		
		# Move executor towards target.
		if path_index < paths.size():
			var to_path = (paths[path_index] - executor.global_position)
			if to_path.length() < Constants.GRID_HALF:
				path_index += 1
			
			# Turn executor to face path.
			if executor.has_method("get_sprite"):
				executor.get_sprite().flip_h = \
						int(to_target_vector().normalized().x <= 0)
			
			# warning-ignore:return_value_discarded
			executor.move_and_collide(
					executor.move_speed * to_path.normalized())
			# If target is close enough, continue to next behavior process.
			result = to_target_vector().length() < Constants.GRID_ONE_HALF
	
	return result


# Resets the pathing and issue a new move command towards the target.
func reset_pathing():
	var to_target = target.global_position + \
		to_self_vector().normalized() * Constants.GRID_SIZE
	paths = navigation.get_simple_path(executor.global_position, to_target)
	pathing_cooldown = Constants.AI_PATHING_COOLDOWN
	path_index = 0
