extends Node2D
# This is where scripting events in Level 03 will happen.


# Cutscene event.
var is_cutscene_walking = false setget set_cutscene_walking

# Gunner spawn event.
var gunner = preload("res://assets/scenes/actors/gunner.tscn")
var gunner_points = []
var gunners_spawned = false

# Flame wheel event.
var flame_wheel = preload("res://assets/scenes/objects/flame_wheel.tscn")
var flames_spawned

onready var boss = $Boss
onready var player = $Player
onready var sound_incoming = $Events/SoundIncoming


func _ready():
	for node in $Events/Spawns.get_children():
		gunner_points.append(node.global_position)
	boss.teleport_points = gunner_points
	set_gates(false)
	player.get_node("AreaAggro").queue_free()


func _physics_process(_delta):
	if is_cutscene_walking:
		player.move_and_collide(Vector2.DOWN * player.move_speed)


func _on_boss_damaged(_attacker, _verb, _victim, _amount):
	# Spawn gunners at 60% HP to make the fight harder.
	if not gunners_spawned and boss.hp <= 0.6 * boss.max_hp:
		for _i in range(0, 4):
			randomize()
			var gunman = gunner.instance()
			add_child(gunman)
			gunman.global_position = \
					gunner_points[randi() % gunner_points.size()]
			gunman.is_aggro = true
		gunners_spawned = true
	# Spawn flame wheel at 40% HP for a change of pace.
	elif not flames_spawned and boss.hp <= 0.4 * boss.max_hp:
		# Teleport to midpoint.
		yield(get_tree(), "idle_frame")
		boss.is_aggro = false
		boss.is_invulnerable = true
		boss.get_node("AnimationPlayer").play("Casting")
		boss.teleport($Events/Middle.global_position)
		$Events/FlameIncoming.visible = true
		$Events/Timer.start()
		
		# TODO: please change this, I have no time so I had to do this
		sound_incoming.play()
		yield(sound_incoming, "finished")
		sound_incoming.play()
		yield(sound_incoming, "finished")
		sound_incoming.play()


func _on_cutscene_start(body):
	if body == player:
		# Clear previous speech.
		if not player.speech_queue.empty():
			player.speech_queue[0].end()
		player.is_controllable = false
		
		set_cutscene_walking(true)
		# warning-ignore:return_value_discarded
		$Events/DialogBoss.connect("dialog_begins", self, 
				"set_cutscene_walking", [false])
		# warning-ignore:return_value_discarded
		$Events/DialogBoss.connect("dialog_completed", self, "_on_cutscene_end")
		$Events/Cutscene.queue_free()


func _on_cutscene_end():
	$Events/MusicPlayer.play()
	set_gates(true)
	boss.is_aggro = true
	player.is_controllable = true


func _on_timer_end():
	boss.is_aggro = true
	boss.is_invulnerable = false
	boss.get_node("AnimationPlayer").stop()
	boss.modulate = Color.white
	
	# Begin flamewheel!
	var flames = flame_wheel.instance()
	add_child(flames)
	flames.global_position = $Events/Middle.global_position
	$Events/FlameIncoming.visible = false
	flames_spawned = true


func set_cutscene_walking(walk: bool):
	is_cutscene_walking = walk


func set_gates(raise: bool):
	$Events/Gates.visible = raise
	for gate in $Events/Gates.get_children():
		gate.get_node("CollisionShape2D").disabled = !raise
