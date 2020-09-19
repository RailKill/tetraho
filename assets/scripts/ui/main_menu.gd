class_name MainMenu
extends Control


func _ready():
	$VBoxContainer/ButtonStart.grab_focus()
	if OS.get_name() == "HTML5":
		$VBoxContainer/ButtonQuit.set_disabled(true)


func _on_ButtonStart_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/scenes/levels/level_01.tscn")


func _on_ButtonSecond_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/scenes/levels/level_02.tscn")


func _on_ButtonThird_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/scenes/levels/level_03.tscn")


func _on_ButtonQuit_pressed():
	get_tree().quit()


func _on_ButtonFullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
