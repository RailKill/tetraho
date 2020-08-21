extends Node
# This is where scripting events in Level 03 will happen.


export (NodePath) var world_path
export (NodePath) var player_path
export (NodePath) var boss_path
export (NodePath) var ingame_menu_path
var game_world
var player
var boss
var ingame_menu

var walking_time = 2
var is_cutscene_walking = false
var is_cutscene_talking1 = false
var is_cutscene_talking2 = false
var is_cutscene_talking3 = false


func _ready():
	game_world = get_node(world_path)
	player = get_node(player_path)
	boss = get_node(boss_path)
	ingame_menu = get_node(ingame_menu_path)


func _physics_process(_delta):
	if is_cutscene_walking:
		player.move_and_collide(Vector2.DOWN * player.move_speed)
		
		if player.get_global_position().y >= boss.get_global_position().y:
			is_cutscene_walking = false
			is_cutscene_talking1 = true
			player.hud.say([
				"You've got a lot of nerve crashing into my room.",
				"What is this, you want to be the queen of this house?"
			], boss.get_global_transform_with_canvas().origin + Vector2(0, -90))
			
		
	elif is_cutscene_talking1 and not player.hud.bubble:
		is_cutscene_talking1 = false
		is_cutscene_talking2 = true
		player.hud.say([
			"You're wearing my crown. I just want it back."
		])
		
	elif is_cutscene_talking2 and not player.hud.bubble:
		is_cutscene_talking2 = false
		is_cutscene_talking3 = true
		player.hud.say([
			"The crown is mine! I was the one who established this house",
			"for our new generation! Nobody invited you, irrelevant buffoon!",
			"Your insolence ends here!"
		], boss.get_global_transform_with_canvas().origin + Vector2(0, -90))
	
	elif is_cutscene_talking3 and not player.hud.bubble:
		is_cutscene_talking3 = false
		get_tree().set_pause(false)
		ingame_menu.pause_mode = PAUSE_MODE_PROCESS


func _on_DialogHallway_body_entered(body):
	if body == player:
		player.hud.say([
			"What's with the long hallway? Is there a boss ahead?",
		])
		$DialogHallway.queue_free()


func _on_DialogCutscene_body_entered(body):
	if body == player:
		if player.hud.bubble:
			player.hud.bubble.queue_free()
		
		for node in game_world.get_children():
			if node is Tetromino:
				if node.can_decay and node.is_summoned:
					node.pause_mode = PAUSE_MODE_PROCESS
		
		get_tree().set_pause(true)
		is_cutscene_walking = true
		ingame_menu.pause_mode = PAUSE_MODE_STOP
		$DialogCutscene.queue_free()
