class_name IngameMenu
extends Control


# Title heading node of this in-game menu panel.
onready var title = $Label
# Resume button, a.k.a the first button to grab focus when menu is visible.
onready var button_resume = $VBoxContainer/ButtonResume
var cannot_close = false


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and not cannot_close:
		if visible:
			_on_ButtonResume_pressed()
		else:
			show()


func show():
	.show()
	button_resume.grab_focus()


func _on_ButtonResume_pressed():
	hide()


func _on_ButtonQuit_pressed():
	get_tree().quit()


func _on_ButtonRestart_pressed():
	_on_ButtonResume_pressed()
	var _ignore = get_tree().reload_current_scene()


func _on_IngameMenu_visibility_changed():
	get_tree().set_pause(visible)


func _on_ButtonMainMenu_pressed():
	get_tree().set_pause(false)
	var _ignore = get_tree().change_scene(
		"res://assets/objects/ui/main_menu.tscn")
