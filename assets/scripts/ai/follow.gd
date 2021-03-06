class_name Follow
extends Target
# Moves executor towards a given target node using the given navigation node.


var navigation: Navigation2D
var paths: PoolVector2Array = []
var pathing_timer: Timer
var path_index = 0


func _init(actor, goal, nav, extent=0).(actor, goal, extent):
	navigation = nav
	pathing_timer = Timer.new()
	pathing_timer.autostart = true
	pathing_timer.wait_time = Constants.AI_PATHING_COOLDOWN
	# warning-ignore:return_value_discarded
	pathing_timer.connect("timeout", self, "reset_pathing")
	executor.add_child(pathing_timer)


func execute() -> bool:
	var result = true
	# If the distance is too far to follow, just continue to next behavior.
	if is_close_enough():
		# Result is set to false here once the target is actually within range.
		# This will prevent execution of next behavior and focus only on follow.
		result = false
		
		# Move executor towards target.
		if path_index < paths.size():
			var to_path = (paths[path_index] - executor.global_position)
			if to_path.length() < Constants.GRID_HALF:
				path_index += 1
			
			# Turn executor to face path.
			if executor.has_method("get_sprite"):
				executor.get_sprite().flip_h = \
						int(to_target_vector().normalized().x <= 0)
			
			# If target is close enough, continue to next behavior process.
			if to_target_vector().length() < Constants.GRID_ONE_HALF:
				result = true
			else:
				# warning-ignore:return_value_discarded
				executor.move_and_slide(
					executor.move_speed * to_path.normalized())
	
	return result


# Resets the pathing and issue a new move command towards the target.
func reset_pathing():
	var to_target = target.global_position + \
		to_self_vector().normalized() * Constants.GRID_SIZE
	paths = navigation.get_simple_path(executor.global_position, to_target)
	path_index = 0
