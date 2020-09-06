class_name AreaDamage
extends Area2D
# Basic attack area. When an actor enters this area, 


# Amount of damage to deal when an actor enters this area.
export var damage = 10
# Message to display the type of attack. Use past tense.
export var verb = "scratched"

# Actor who created this damage area, possible to be null.
var creator: Actor

# Animated sprite node of the damage caused.
onready var animation = $AnimatedSprite


func _on_AreaDamage_body_entered(body):
	if body.has_method("oof") and (not creator or creator.team != body.team):
		body.call_deferred("oof", damage, false, creator, verb)


func _on_AnimatedSprite_animation_finished():
	queue_free()
