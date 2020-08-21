extends Node
# This is where scripting events in Level 03 will happen.
# TODO: Rushed for #mizjam1, please refactor in future. It's ugly.


export (NodePath) var world_path
export (NodePath) var player_path
export (NodePath) var boss_path
export (NodePath) var ingame_menu_path
var game_world
var player
var boss
var ingame_menu


# Cutscene event.
var walking_time = 2
var is_cutscene_walking = false
var is_cutscene_talking1 = false
var is_cutscene_talking2 = false
var is_cutscene_talking3 = false

# Gunner spawn event.
onready var gunner = preload("res://assets/objects/gunner.tscn")
var spawn_points = []
var is_spawn_time = false
var has_spawned = false

# Flame wheel event.
onready var flame_wheel = preload("res://assets/objects/flame_wheel.tscn")
var is_flame_starting = false
var has_flamed = false
var flame_countdown = 3

var is_boss_hp_low = false



func _ready():
	game_world = get_node(world_path)
	player = get_node(player_path)
	boss = get_node(boss_path)
	ingame_menu = get_node(ingame_menu_path)
	
	for node in $SpawnPoints.get_children():
		spawn_points.append(node.get_global_position())
	boss.teleport_points = spawn_points + [$MidPoint.get_global_position()]

	toggle_gates(false)
	
	# testing
#	yield(boss, "ready")
#	boss.hp = 200


func _physics_process(delta):
	if boss:
		# TODO: Create a signal for Boss when damaged so don't have to poll
		is_spawn_time = boss.get_hp() <= 0.6 * boss.get_maximum_hp()
		is_boss_hp_low = boss.get_hp() <= 0.4 * boss.get_maximum_hp()
		
		# it's yandev time baby
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
			$AnimationCutscene.play_backwards("Border")
			
			# Raise gates.
			toggle_gates(true)
		
		elif is_spawn_time and not has_spawned:
			# Spawn gunners to make the fight harder.
			for _i in range(0, 4):
				randomize()
				var gunman = gunner.instance()
				game_world.add_child(gunman)
				gunman.set_global_position(
					spawn_points[randi() % spawn_points.size()])
				gunman.is_aggro = true
			has_spawned = true
		
		elif is_boss_hp_low and not has_flamed:
			if not is_flame_starting:
				# Teleport to midpoint.
				boss.is_casting = true
				boss.is_invulnerable = true
				boss.get_node("AnimationPlayer").play("Casting")
				boss.teleport(8)
				$FlameIncoming.set_visible(true)
				is_flame_starting = true
			else:
				flame_countdown -= delta
				if flame_countdown <= 0:
					# Begin flamewheel!
					boss.is_casting = false
					boss.is_invulnerable = false
					boss.get_node("AnimationPlayer").stop()
					var flames = flame_wheel.instance()
					game_world.add_child(flames)
					flames.set_global_position($MidPoint.get_global_position())
					$FlameIncoming.set_visible(false)
					is_flame_starting = false
					has_flamed = true
	else:
		toggle_gates(false)


func toggle_gates(boolean : bool):
	$Gates.set_visible(boolean)
	for gate in $Gates.get_children():
		gate.get_node("CollisionShape2D").set_disabled(!boolean)
	


func _on_DialogHallway_body_entered(body):
	if body == player:
		player.hud.say([
			"Who designed this long hallway? Feels like a boss is ahead.",
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
		$AnimationCutscene.play("Border")
		ingame_menu.pause_mode = PAUSE_MODE_STOP
		$DialogCutscene.queue_free()


func _on_Exit_body_entered(body):
	if body == player:
		player.hud.bubble = null
		if not player.hud.crown.visible:
			player.hud.say(["I don't feel like winning without my crown."])
		else:
			# win game
			player.hud.say(["This is the end. I won!"])
