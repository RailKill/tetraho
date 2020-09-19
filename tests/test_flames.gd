extends WAT.Test


var gate_resource = preload("res://assets/scenes/objects/gate.tscn")
var flame_resource = preload("res://assets/scenes/objects/flamethrower.tscn")
var player_resource = preload("res://assets/scenes/actors/player.tscn")

var flames: Flamethrower
var player: PlayerCharacter


func pre():
	flames = flame_resource.instance()
	add_child(flames)
	
	player = player_resource.instance()
	player.global_position = Vector2(0, -flames.length)


func test_severity_of_damage():
	add_child(player)
	pause_mode = PAUSE_MODE_PROCESS
	var camera = player.camera
	var canvas = player.canvas
	yield(until_timeout(Constants.FLAMETHROWER_DURATION), YIELD)
	asserts.is_false(player.is_dead(), "player still alive after one tick")
	
	yield(until_signal(player, "tree_exiting", 
			3 - Constants.FLAMETHROWER_DURATION), YIELD)
	asserts.is_false(is_instance_valid(player), "player died within 3 seconds")
	camera.queue_free()
	canvas.queue_free()
	get_tree().paused = false


func test_shielded_by_obstacle():
	var gate = gate_resource.instance()
	add_child(gate)
	gate.global_position = Vector2(0, -flames.length / 2.0)
	
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	add_child(player)
	yield(until_timeout(Constants.FLAMETHROWER_DURATION * 2), YIELD)
	asserts.is_less_than(flames.length, abs(gate.global_position.y), 
			"flame shortened")
	asserts.is_equal(player.hp, player.max_hp, "player took no damage")	
	gate.queue_free()


func test_shielded_even_when_rotated():
	flames.rotation_degrees = 225
	var bottom_left = Vector2(-flames.length, flames.length)
	var half_length = flames.length / 2
	
	var gate = gate_resource.instance()
	add_child(gate)
	gate.global_position = \
			(bottom_left - flames.global_position).normalized() * half_length
	
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	add_child(player)
	player.global_position = bottom_left
	yield(until_timeout(Constants.FLAMETHROWER_DURATION * 2), YIELD)
	asserts.is_less_than(flames.length, half_length, "flame shortened")
	asserts.is_equal(player.hp, player.max_hp, "player took no damage")
	gate.queue_free()


func test_shielded_at_point_blank():
	var gate = gate_resource.instance()
	add_child(gate)
	gate.global_position = flames.global_position - Vector2(7, 7)
	
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	add_child(player)
	yield(until_timeout(Constants.FLAMETHROWER_DURATION * 2), YIELD)
	asserts.is_equal_or_less_than(flames.length, 1, "flame at minimum length")
	asserts.is_equal(player.hp, player.max_hp, "player took no damage")
	gate.queue_free()


func post():
	flames.queue_free()
	if is_instance_valid(player):
		player.queue_free()
