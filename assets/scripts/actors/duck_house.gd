class_name DuckHouse
extends Enemy
# Duck spawner. Can only be destroyed by pushing a duck into it. Usually
# unlocks something when destroyed.


func _ready():
	var player = get_parent().get_node("Player")
	behaviors.append(UseAbility.new(
			self, player, $Spawn, Constants.GRID_ONE_HALF))
