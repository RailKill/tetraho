class_name Teleport
extends Ability
# Teleports the caster to the given point.


export(PackedScene) var effect = \
		preload("res://assets/scenes/effects/teleport.tscn")
export(Vector2) var point setget set_point


func complete():
	.complete()
	var fx = effect.instance()
	fx.global_position = caster.global_position
	caster.get_parent().add_child(fx)
	caster.global_position = point


func set_point(destination: Vector2):
	point = destination
