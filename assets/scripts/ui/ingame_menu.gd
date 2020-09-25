class_name IngameMenu
extends Control


# If true, then this menu cannot be closed.
var cannot_close = false

# Title heading node of this in-game menu panel.
onready var title = $Label
# Resume button, a.k.a the first button to grab focus when menu is visible.
onready var button_resume = $VBoxContainer/ButtonResume


func _ready():
	if OS.get_name() == "HTML5":
		$VBoxContainer/ButtonQuit.set_disabled(true)


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and not cannot_close:
		if visible:
			_on_ButtonResume_pressed()
		else:
			show()


func _on_ButtonResume_pressed():
	hide()
	get_tree().paused = false


func _on_ButtonQuit_pressed():
	get_tree().quit()


func _on_ButtonRestart_pressed():
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func _on_ButtonMainMenu_pressed():
	get_tree().paused = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/scenes/ui/main_menu.tscn")


func show():
	.show()
	button_resume.grab_focus()
	get_tree().paused = true
