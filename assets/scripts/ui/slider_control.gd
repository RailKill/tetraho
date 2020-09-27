extends Control
# Slider control that has a label which shows its percentage value.


# String to append at the end of the label value, usually a symbol.
export(String) var suffix = ""

# Reference to the label node.
onready var label = $Label


func _on_slider_value_changed(value):
	label.text = "%d%s" % [value, suffix]
