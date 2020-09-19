class_name Flamethrower
extends Node2D
# Flamethrower emits a bunch of flame particles and does raycast every frame
# to its length, destroying any Actor it hits or reducing its length if a
# TetrominoBlock is blocking it.


# If true, this flamethrower will destroy itself after a set duration.
export(bool) var one_off = false
# Duration in seconds this flames will last if one_off is true.
export(float, 0, 60) var duration = 3
# Full length of this flamethrower.
export(int, 1, 1000) var full_length = 70

# Current length of the flamethrower, as it may be blocked.
var length = full_length

# Reference node to the particle emitter of the flames.
onready var particles = $Particles2D


func _ready():
	particles.process_material = particles.process_material.duplicate()


func _physics_process(delta):
	# Destroy if flamethrower is one_off and past its duration.
	if one_off:
		duration -= delta
		if duration <= 0:
			queue_free()
	
	var space_state = get_world_2d().direct_space_state
	var towards = (particles.global_position - global_position).normalized()
	
	var result = space_state.intersect_ray(
			global_position, global_position + towards * length, [], 
			Constants.Layer.ENVIRONMENT + Constants.Layer.ACTOR +
			Constants.Layer.BLOCK
	)
	
	if result:
		var body = result.collider
		if body.has_method("add_child_unique"):
			var burn = Burn.new()
			burn.name = "Flamethrower Burn"
			burn.duration = Constants.FLAMETHROWER_DURATION
			body.add_child_unique(burn)
		
		length = clamp((result.position - global_position).length(), 1, 1000)
	else:
		length = full_length
	
	update_particles()


# Update the velocity of the particles, which affect how far the fire goes.
func update_particles():
	particles.process_material.set("initial_velocity", length)
