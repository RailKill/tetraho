extends Node
# This is where scripting events in Level 01 will happen.


export (NodePath) var world_path
export (NodePath) var player_path
var game_world
var player


# Called when the node enters the scene tree for the first time.
func _ready():
	game_world = get_node(world_path)
	player = get_node(player_path)
	yield(player, "ready")
	player.hud.say([
		"Hello! Use the WASD keys to move. Press 'E' to advance this dialog.",
	])


func _on_DialogLock_body_entered(body):
	if body == player:
		player.hud.say([
			"Hmm... blocks are solved whenever a 2x3 rectangle is formed.",
			"Mouse to aim, right-click to rotate, left-click to summon.",
			"I can hold pieces using the Shift key. Might come in handy."
		])
	$DialogLock.queue_free()


func _on_DialogDuck_body_entered(body):
	if body == player:
		player.hud.say([
			"These ducks will peck me if they get close enough.",
			"I can kill them by trapping and solving them with my blocks."
		])
	$DialogDuck.queue_free()
