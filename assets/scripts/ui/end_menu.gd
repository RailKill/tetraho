extends Control


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://assets/scenes/ui/main_menu.tscn")
