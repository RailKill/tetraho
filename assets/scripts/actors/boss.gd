class_name Boss
extends Gunner


func _ready():
	var melee_range = Constants.GRID_SIZE * 7
	behaviors.push_front(UseAbility.new(
			self, player, $Spawn, Constants.GRID_SIZE + 2, melee_range))
	behaviors.push_front(Follow.new(
			self, player, get_parent().get_node("Navigation2D"), melee_range))
	behaviors.push_front(Holster.new(self, handgun))


# Immune to Burn status effect.
func add_child_unique(node):
	if not node is Burn:
		.add_child_unique(node)
	else:
		node.queue_free()
