class_name FocusButton
extends Button

# Path to the focus control.
export var focus_path : NodePath
var focus : Control
onready var sound_snap = $SoundSnap


func _ready():
	focus = get_node(focus_path)


func _on_FocusButton_focus_entered():
	focus.set_global_position(get_global_position() + get_rect().size / 2)
	sound_snap.play()


func _on_FocusButton_mouse_entered():
	grab_focus()
