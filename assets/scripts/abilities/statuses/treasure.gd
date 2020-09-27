class_name Treasure
extends Status


export(Array, PackedScene) var drops = []


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	get_parent().connect("dying", self, "_on_death")


func _on_death():
	for loot in drops:
		var instance = loot.instance()
		var victim = get_parent()
		instance.global_position = victim.global_position
		victim.get_parent().add_child(instance)
