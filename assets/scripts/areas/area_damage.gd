class_name AreaDamage
extends Area2D
# Basic attack area. Deals damage when an Actor enters.
# Automatically destroys itself when its animation finishes.


# Amount of damage to deal when an actor enters this area.
export(int, 0, 1000) var damage = 10
# Message to display the type of attack. Use past tense.
export(String) var verb = "scratched"

# Actor who created this damage area, possible to be null.
var creator: Actor
# List of entities who have been damaged by this area before.
var damaged = []


func _ready():
	var animation = $AnimatedSprite
	# warning-ignore:return_value_discarded
	animation.connect("animation_finished", self, "_on_animation_finished")
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	animation.play()


func _on_animation_finished():
	queue_free()


func _on_body_entered(body):
	if body.has_method("oof") and not damaged.has(body) and \
			(not creator or creator.team != body.team):
		body.call_deferred("oof", damage, false, creator, verb)
		damaged.append(body)
