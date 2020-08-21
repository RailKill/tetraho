class_name AreaChecker
extends Area2D
# Checks a small area, around the size of Constants.GRID_SIZE for any bodies
# overlapping. Saves the body that overlapped.


# The latest colliding body.
var collided


func reposition(point : Vector2, snap=false):
	if snap:
		set_global_position(Vector2(
			stepify(point.x, Constants.GRID_SIZE), 
			stepify(point.y, Constants.GRID_SIZE)
		))
	else:
		set_global_position(point)


func _on_AreaChecker_area_entered(area):
	collided = area


func _on_AreaChecker_body_entered(body):
	collided = body
