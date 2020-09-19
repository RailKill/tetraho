class_name Enemy
extends Actor
# Enemy in the game whose purpose is to defeat the PlayerCharacter.


# Enemies can be aggro-ed, which activates hostile behavior towards player.
export(bool) var is_aggro = false

# Enemies need to keep track of the player.
onready var player = get_parent().get_node("Player")


# Returns the difference vector from this enemy to the player.
func to_player_vector():
	return player.get_global_position() - get_global_position()


# Returns the difference vector from player to self.
func to_self_vector():
	return -to_player_vector()
