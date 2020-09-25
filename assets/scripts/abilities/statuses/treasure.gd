class_name Treasure
extends Status


export(Array, PackedScene) var drops = []


# Called when the node enters the scene tree for the first time.
func _ready():
	lasts_forever = true
	# warning-ignore:return_value_discarded
	connect("tree_exiting", self, "_on_tree_exiting")


func _on_tree_exiting():
	for loot in drops:
		var instance = loot.instance()
		var victim = get_parent()
		instance.global_position = victim.global_position
		victim.get_parent().call_deferred("add_child", instance)
