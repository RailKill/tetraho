class_name AreaDamage
extends Area2D
# Basic attack area. When an actor enters this area, 


# Animated sprite node of the damage caused.
onready var animation = $AnimatedSprite
# Amount of damage to deal when an player enters this area.
export var damage = 10


func _on_AreaDamage_body_entered(body):
	if body is PlayerCharacter:
		body.oof(damage)


func _on_AnimatedSprite_animation_finished():
	queue_free()
