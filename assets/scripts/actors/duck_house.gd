class_name DuckHouse
extends Enemy
# Duck spawner. Can only be destroyed by pushing a duck into it. Usually
# unlocks something when destroyed.


# Spawn ability.
onready var spawner = $Spawn


func _init():
	is_invulnerable = true


func _physics_process(_delta):
	if not is_dead() and is_instance_valid(player) and is_aggro:
		spawner.point = get_global_position() + \
			to_player_vector().normalized() * (Constants.GRID_ONE_HALF)
		spawner.cast()
