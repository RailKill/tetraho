class_name IngameMenu
extends Control


# If true, then this menu cannot be closed.
var cannot_close = false
# Keeps track of whether a submenu is open or not.
var is_submenu_open = false

# Title heading node of this in-game menu panel.
onready var title = $Label
# Resume button, a.k.a the first button to grab focus when menu is visible.
onready var button_resume = $VBoxContainer/ButtonResume


func _ready():
	if OS.has_feature("web"):
		$VBoxContainer/ButtonQuit.disabled = true


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and not cannot_close and \
			not is_submenu_open:
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


func _on_ButtonOptions_pressed():
	$VBoxContainer.hide()
	is_submenu_open = true
	var options = load("res://assets/scenes/ui/options_menu.tscn").instance()
	add_child(options)
	options.connect("tree_exiting", $VBoxContainer, "show")
	options.connect("tree_exiting", self, "set", ["is_submenu_open", false])


func _on_VBoxContainer_visibility_changed():
	button_resume.grab_focus()


func show():
	.show()
	get_tree().paused = true
