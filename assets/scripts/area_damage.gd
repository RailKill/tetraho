class_name AreaDamage
extends Area2D
# Basic attack area. When an actor enters this area, 


onready var animation = $AnimatedSprite


func _on_AreaDamage_body_entered(body):
	if body is PlayerCharacter:
		body.oof(10)
		print(body.name, " now has ", body.hp, "HP")


func _on_AnimatedSprite_animation_finished():
	queue_free()
