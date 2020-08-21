extends Node
# This is where scripting events in Level 01 will happen.
# TODO: I had to rush for #mizjam1. The dialog areas can be made into a scene.
# This is full of copy-and-paste bullshit, but it will have to do for now.

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


func _on_Exit_body_entered(body):
	if body == player:
		var _win = get_tree().change_scene("res://assets/level_02.tscn")


func _on_DialogGunner_body_entered(body):
	if body == player:
		player.hud.say([
			"Gunners. I can use my blocks for cover but it's ineffective.",
			"When moving, I can dash with 'Space' to evade their bullets."
		])
		$DialogGunner.queue_free()


func _on_DialogFlamethrower_body_entered(body):
	if body == player:
		player.hud.say([
			"Flames will kill me almost immediately.",
			"Luckily, my blocks are fire-resistant."
		])
		$DialogFlamethrower.queue_free()


func _on_DialogBlockmancer_body_entered(body):
	if body == player:
		player.hud.say([
			"These dead blocks are summoned by Blockmancers, my rivals.",
			"Unlike mine, they don't trap but they deal heavy damage.",
			"Also, they last forever until solved."
		])
		$DialogBlockmancer.queue_free()


func _on_DialogHouse_body_entered(body):
	if body == player:
		player.hud.say([
			"That coop keeps producing ducks! I can't destroy it normally.",
			"If I return a duck to its coop, it will be destroyed.",
			"I can push ducks by moving or dashing into them."
		])
		$DialogHouse.queue_free()
