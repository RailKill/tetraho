class_name Flamethrower
extends Node2D
# Flamethrower emits a bunch of flame particles and does raycast every frame
# to its length, destroying any Actor it hits or reducing its length if a
# TetrominoBlock is blocking it.


# Full length of this flamethrower.
export var full_length = 70
# If true, this flamethrower will destroy itself after a set duration.
export var one_off = false
# Duration in seconds this flames will last if one_off is true.
export var duration = 3
# Reference node to the origin of the flames.
onready var origin = $Origin
# Reference node to the particle emitter of the flames.
onready var particles = $Particles2D

# Current length of the flamethrower, as it may be blocked.
var length = full_length


func _physics_process(delta):
	# Destroy if flamethrower is one_off and past its duration.
	if one_off:
		duration -= delta
		if duration <= 0:
			queue_free()
	
	var space_state = get_world_2d().direct_space_state
	var point = origin.get_global_position()
	var towards = (particles.get_global_position() - point).normalized()
	
	var result = space_state.intersect_ray(point, point + towards * length, [], 
		Constants.Layer.ENVIRONMENT + Constants.Layer.ACTOR +
		Constants.Layer.BLOCK)
	
	if result:
		var body = result.collider
		if body is Actor and not body is TetrominoBlock and not body is Boss:
			body.oof(Constants.FLAMETHROWER_DAMAGE)
			return
		
		length = (result.position - point).length()
	else:
		length = full_length
	
	update_particles()


# Update the velocity of the particles, which affect how far the fire goes.
func update_particles():
	particles.get_process_material().set("initial_velocity", length)
