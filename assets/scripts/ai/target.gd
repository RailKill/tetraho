class_name Target
extends Behavior
# An AI Behavior that keeps track of a target over a given distance.


# Target of the behavior.
var target: Node2D
# The range to target in which this behavior will execute. 0 means unlimited.
var distance: float


func _init(actor, goal, extent).(actor):
	target = goal
	distance = extent


# Checks if the target is close enough for the behavior to execute.
func is_close_enough():
	return distance <= 0 or to_target_vector().length() <= distance


# Returns the difference vector from executor to target.
func to_target_vector():
	return target.global_position - executor.global_position


# Returns the difference vector from target to executor.
func to_self_vector():
	return -to_target_vector()
