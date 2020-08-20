class_name Flamethrower
extends Node2D
# Flamethrower emits a bunch of flame particles and does raycast every frame
# to its length, destroying any Actor it hits or reducing its length if a
# TetrominoBlock is blocking it.


# Full length of this flamethrower.
export var full_length = 70
# Reference node to the origin of the flames.
onready var origin = $Origin
# Reference node to the particle emitter of the flames.
onready var particles = $Particles2D

# Current length of the flamethrower, as it may be blocked.
var length = full_length


func _physics_process(_delta):
	var space_state = get_world_2d().direct_space_state
	var point = origin.get_global_position()
	var result = space_state.intersect_ray(point, point - Vector2(0, length))
	
	if result:
		var body = result.collider
		print(result.position)
		if body is TetrominoBlock:
			length = (body.get_global_position() - point).length() - \
				Constants.GRID_SIZE
			update_particles()
			return
		elif body is Actor:
			body.oof(Constants.FLAMETHROWER_DAMAGE)
			return

	length = full_length
	update_particles()


# Update the velocity of the particles, which affect how far the fire goes.
func update_particles():
	particles.get_process_material().set("initial_velocity", length)
