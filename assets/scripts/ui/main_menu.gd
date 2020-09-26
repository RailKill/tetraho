class_name MainMenu
extends Control


func _ready():
	if OS.has_feature("web"):
		$VBoxContainer/ButtonQuit.disabled = true


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


func _on_ButtonOptions_pressed():
	$VBoxContainer.hide()
	var options = load("res://assets/scenes/ui/options_menu.tscn").instance()
	add_child(options)
	options.connect("tree_exiting", $VBoxContainer, "show")


func _on_VBoxContainer_visibility_changed():
	$VBoxContainer/ButtonStart.grab_focus()
