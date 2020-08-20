class_name AreaChecker
extends Area2D
# Checks a small area, around the size of Constants.GRID_SIZE for any bodies
# overlapping. Saves the body that overlapped.


# The latest colliding body.
var collided


func _on_AreaChecker_body_entered(body):
	collided = body
