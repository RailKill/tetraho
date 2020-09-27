class_name Link
extends Status
# Status effect which destroys all linked nodes if this node is destroyed.


export(Array, NodePath) var linked = []


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	connect("tree_exiting", self, "_on_tree_exiting")


func _on_tree_exiting():
	for path in linked:
		var node = get_node(path)
		if is_instance_valid(node):
			node.queue_free()
