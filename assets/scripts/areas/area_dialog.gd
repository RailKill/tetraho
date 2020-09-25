class_name AreaDialog
extends Area2D
# An area which if any of the given triggered_by Actor enters, it will make
# that Actor say something. It has a Dictionary of Actors and PoolStringArrays
# which will be cycled through until all speeches have been completed.


signal dialog_begins
signal dialog_completed

# List of NodePaths that can start the dialog. If empty, any physics body can.
export(Array, NodePath) var triggered_by = []
# If true, area will persist after dialog is complete and can be re-triggered.
export(bool) var is_permanent = false

# List of Speech nodes to deliver.
var dialog: Array
# Index of the current dialog.
var index: int


func _ready():
	dialog = []
	index = -1
	for node in get_children():
		if node.has_method("deliver"):
			dialog.append(node)
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if is_triggerer(body):
		# warning-ignore:unused_argument
		disconnect("body_entered", self, "_on_body_entered")
		emit_signal("dialog_begins")
		advance_dialog()


# Starts the speech bubble node.
func advance_dialog():
	index += 1
	if index < dialog.size():
		dialog[index].deliver().connect("tree_exited", self, "advance_dialog")
	else:
		emit_signal("dialog_completed")
		if is_permanent:
			_ready()
		else:
			queue_free()


# Check if the given body is a designated triggerer of this area.
func is_triggerer(body):
	return triggered_by.empty() or triggered_by.has(get_path_to(body))
