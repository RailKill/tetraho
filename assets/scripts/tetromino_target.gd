class_name TetrominoTarget
extends Area2D
# A target reticle area that a tetromino block would be summoned.


# Animated sprite to show that the tetromino is being summoned.
onready var summoning = $Summoning


# Shows the summoning animation and play it.
func animate():
	summoning.set_visible(true)
	summoning.play()


# Checks if the currently occupied area contains any physics bodies. If there
# are bodies that are supposed to collide with this area, it will return false.
# This function only returns true if there are no possible colliding bodies.
func is_valid():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.collision_layer == collision_mask:
			return false
	
	var overlap = get_overlapping_bodies()
	for body in overlap:
		print(body.collision_layer)
		if body.collision_layer == collision_mask:
			return false
	return true
