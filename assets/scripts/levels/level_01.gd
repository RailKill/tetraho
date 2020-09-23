extends Node
# This is where scripting events in Level 01 will happen.
# TODO: I had to rush for #mizjam1. The dialog areas can be made into a scene.
# This is full of copy-and-paste bullshit, but it will have to do for now.


onready var player = get_parent().get_node("Player")


func _on_Exit_body_entered(body):
	if body == player:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://assets/scenes/levels/level_02.tscn")
