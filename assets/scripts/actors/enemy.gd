class_name Enemy
extends Actor
# Enemy in the game whose purpose is to defeat the PlayerCharacter.


# Enemies can be aggro-ed, which activates hostile behavior towards player.
export(bool) var is_aggro = false

# List of AI Behaviors to be executed.
var behaviors = []

# Enemies need to keep track of the player.
onready var player = get_parent().get_node("Player")


func _physics_process(_delta):
	if not is_dead() and is_aggro and not is_locked():
		for behavior in behaviors:
			if not behavior.execute():
				return
