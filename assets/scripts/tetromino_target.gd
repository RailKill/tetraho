class_name TetrominoTarget
extends Area2D
# A target reticle area that a tetromino block would be summoned.


# Checks if the currently occupied area contains any physics bodies. If there
# are bodies that are supposed to collide with this area, it will return false.
# This function only returns true if there are no possible colliding bodies.
func is_valid():
	var overlap = get_overlapping_bodies()
	for body in overlap:
		if body.collision_layer == collision_mask:
			return false
	return true
