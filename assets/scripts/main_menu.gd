class_name MainMenu
extends Control



func _ready():
	$VBoxContainer/ButtonStart.grab_focus()


func _on_ButtonStart_pressed():
	var _ignore = get_tree().change_scene("res://assets/level_01.tscn")


func _on_ButtonSecond_pressed():
	var _ignore = get_tree().change_scene("res://assets/level_02.tscn")


func _on_ButtonThird_pressed():
	var _ignore = get_tree().change_scene("res://assets/level_03.tscn")


func _on_ButtonQuit_pressed():
	get_tree().quit()
