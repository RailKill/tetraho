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
var flames_spawned = false
var warning_count = 3

onready var boss = $Boss
onready var teleport = $Boss/Teleport
onready var dialog_boss = $Events/DialogBoss
onready var gates = $Events/Gates
onready var middle = $Events/Middle
onready var flame_incoming = $Events/FlameIncoming
onready var sound_incoming = $Events/SoundIncoming
onready var player = $Player


func _ready():
	for node in $Events/Spawns.get_children():
		gunner_points.append(node.global_position)
	set_gates(false)
	player.get_node("AreaAggro").queue_free()


func _physics_process(_delta):
	if is_cutscene_walking:
		player.move_and_slide(Vector2.DOWN * player.move_speed)


func _on_boss_damaged(_attacker, _verb, _victim, _amount):
	teleport.point = get_random_point(true)
	
	# Spawn gunners at 60% HP to make the fight harder.
	if not gunners_spawned and boss.hp <= 0.6 * boss.max_hp:
		for _i in range(0, 4):
			var gunman = gunner.instance()
			add_child(gunman)
			gunman.global_position = get_random_point()
			gunman.is_aggro = true
		gunners_spawned = true
	# Spawn flame wheel at 40% HP for a change of pace.
	elif not flames_spawned and boss.hp <= 0.4 * boss.max_hp:
		# Teleport to midpoint.
		boss.is_aggro = false
		boss.is_invulnerable = true
		boss.get_node("AnimationPlayer").play("Casting")
		teleport.point = middle.global_position
		flame_incoming.visible = true
		$Events/Timer.start()
		sound_incoming.connect("finished", self, "play_warning_sound")
		play_warning_sound()
	
	if not boss.is_dead():
		teleport.cast()


func _on_cutscene_start(body):
	if body == player:
		# Clear previous speech.
		if not player.speech_queue.empty():
			player.speech_queue[0].end()
		player.is_controllable = false
		
		set_cutscene_walking(true)
		# warning-ignore:return_value_discarded
		dialog_boss.connect("dialog_begins", self, 
				"set_cutscene_walking", [false])
		# warning-ignore:return_value_discarded
		dialog_boss.connect("dialog_completed", self, "_on_cutscene_end")
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
	flames.global_position = middle.global_position
	flame_incoming.visible = false
	flames_spawned = true


# Returns a random designated point.
func get_random_point(for_boss: bool=false):
	randomize()
	var random_points = gunner_points + \
			([middle.global_position] if for_boss else [])
	
	return random_points[randi() % random_points.size()]


# Play the flame wheel incoming warning sound.
func play_warning_sound():
	sound_incoming.play()
	warning_count -= 1
	if warning_count <= 0:
		sound_incoming.disconnect("finished", self, "play_warning_sound")


func set_cutscene_walking(walk: bool):
	is_cutscene_walking = walk


func set_gates(raise: bool):
	gates.visible = raise
	for gate in gates.get_children():
		gate.get_node("CollisionShape2D").disabled = !raise
