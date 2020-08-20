class_name DuckHouse
extends Enemy
# Duck spawner. Can only be destroyed by pushing a duck into it. Usually
# unlocks something when destroyed.


# Spawn ability.
onready var spawner = $Spawn
# List of linked entities that will be destroyed too when DuckHouse is gone.
export var linked = []


# Called when the node enters the scene tree for the first time.
func _ready():
	is_invulnerable = true


func _physics_process(_delta):
	if player and is_aggro:
		spawner.point = get_global_position() + \
			to_player_vector().normalized() * (Constants.GRID_ONE_HALF)
		spawner.cast()


func _on_DuckHouse_tree_exiting():
	# When this DuckHouse disappears from existence, destroy all linked objects.
	for entity in linked:
		var link = get_node(entity)
		if link:
			link.queue_free()
