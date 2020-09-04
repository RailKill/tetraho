extends Node
# This is where scripting events in Level 01 will happen.
# TODO: I had to rush for #mizjam1. The dialog areas can be made into a scene.
# This is full of copy-and-paste bullshit, but it will have to do for now.


onready var player = get_parent().get_node("Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(player, "ready")
	player.hud.say([
		"Hello! Use the WASD keys to move. Press 'E' to continue.",
		"Mouse to aim, right-click to rotate, left-click to summon."
	])
	
	$MusicPlayer.play()


func _on_DialogLock_body_entered(body):
	if body == player:
		player.hud.say([
			"Blocks are solved whenever a 2x3 rectangle is formed.",
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
			"Gunners. I can use my blocks for cover.",
			"I can also dash with 'Space' to evade their bullets."
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
			"These dead blocks last forever until solved.",
			"If I'm in the way when a dead block is summoned, it'll hurt."
		])
		$DialogBlockmancer.queue_free()


func _on_DialogHouse_body_entered(body):
	if body == player:
		player.hud.say([
			"I can push ducks by moving or dashing into them.",
			"Return a duck to its coop to destroy it."
		])
		$DialogHouse.queue_free()
