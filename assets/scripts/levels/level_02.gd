extends Node
# TODO: Shit code, full of duplicates. Rushed for #mizjam1, refactor after!


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
		"I'm looking for my hat. It must be around here somewhere.",
	])
	
	# Randomize goals.
	var goals = $Goals.get_children()
	randomize()
	var selected = goals[randi() % goals.size()]
	$Exit.set_global_position(selected.get_global_position())
	selected.queue_free()
	yield(selected, "tree_exited")
	
	goals = $Goals.get_children()
	randomize()
	selected = goals[randi() % goals.size()]
	$Hat.set_global_position(selected.get_global_position())
	selected.queue_free()
	
	$MusicPlayer.play()


func _on_Exit_body_entered(body):
	if body == player:
		player.hud.bubble = null
		if not player.hud.hat.visible:
			player.hud.say(["I need to find my hat first."])
		else:
			var _win = get_tree().change_scene("res://assets/level_03.tscn")


func _on_NarrowHelper_body_entered(body):
	if body == player:
		player.collision_shape.get_shape().set_extents(Vector2(2, 3))


func _on_NarrowHelper_body_exited(body):
	if body == player:
		player.collision_shape.get_shape().set_extents(Vector2(4, 6))
