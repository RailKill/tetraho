extends Control


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		var _ignore = get_tree().change_scene(
			"res://assets/scenes/ui/main_menu.tscn")
