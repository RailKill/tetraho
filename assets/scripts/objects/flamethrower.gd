class_name Flamethrower
extends Node2D
# Flamethrower emits a bunch of flame particles and does raycast every frame
# to its length, destroying any Actor it hits or reducing its length if a
# TetrominoBlock is blocking it.


# Full length of this flamethrower.
export(int, 1, 1000) var full_length = 70

# Current length of the flamethrower, as it may be blocked.
var length = full_length

# Reference node to the particle emitter of the flames.
onready var particles = $Particles2D


func _ready():
	particles.process_material = particles.process_material.duplicate()


func _physics_process(_delta):
	var space_state = get_world_2d().direct_space_state
	var towards = (particles.global_position - global_position).normalized()
	
	var result = space_state.intersect_ray(
			global_position, global_position + towards * length, [], 
			Constants.Layer.ENVIRONMENT + Constants.Layer.ACTOR + 
			Constants.Layer.BLOCK)
	
	if result:
		burn(result.collider)
		length = clamp((result.position - global_position).length(), 1, 1000)
	else:
		length = full_length
	
	update_particles()


# Adds a Burn status effect to the given target.
func burn(target):
	if target.has_method("add_child_unique"):
		var burn = Burn.new()
		burn.caster = self
		burn.duration = Constants.FLAMETHROWER_DURATION
		burn.name = "Flamethrower Burn"
		target.add_child_unique(burn)


# Update the velocity of the particles, which affect how far the fire goes.
func update_particles():
	particles.process_material.set("initial_velocity", length)
