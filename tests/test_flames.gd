extends WAT.Test


var boss_resource = preload("res://assets/scenes/actors/boss.tscn")
var dummy_resource = preload("res://assets/scenes/actors/dummy.tscn")
var gate_resource = preload("res://assets/scenes/objects/gate.tscn")
var flame_resource = preload("res://assets/scenes/objects/flamethrower.tscn")
var player_resource = preload("res://assets/scenes/actors/player.tscn")
var wheel_resource = preload("res://assets/scenes/objects/flame_wheel.tscn")

var flames: Flamethrower
var player: PlayerCharacter


func pre():
	flames = flame_resource.instance()
	add_child(flames)
	
	player = player_resource.instance()
	player.global_position = Vector2(0, -flames.length)
	player.get_node("AreaAggro").queue_free()


func test_boss_immune_to_flames():
	add_child(player)
	var navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	add_child(navigation)
	var boss = boss_resource.instance()
	boss.global_position = Vector2(0, -flames.length / 2)
	add_child(boss)
	yield(until_signal(boss, "damage_taken", 1), YIELD)
	asserts.is_equal(boss.hp, boss.max_hp)
	boss.queue_free()
	navigation.queue_free()


func test_flamewheel_unhindered_at_center():
	flames.queue_free()
	add_child(player)
	var seven_axes = [
		Vector2.UP + Vector2.LEFT,
		Vector2.LEFT,
		Vector2.LEFT + Vector2.DOWN,
		Vector2.DOWN,
		Vector2.DOWN + Vector2.RIGHT,
		Vector2.UP + Vector2.RIGHT,
		Vector2.RIGHT,
	]
	var dummies = []
	for axis in seven_axes:
		var dummy = dummy_resource.instance()
		dummy.global_position = axis * 100
		add_child(dummy)
		dummies.append(dummy)
	
	var navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	add_child(navigation)
	var boss = boss_resource.instance()
	add_child(boss)
	var flame_wheel = wheel_resource.instance()
	add_child(flame_wheel)
	yield(until_timeout(3), YIELD)
	for dummy in dummies:
		asserts.is_less_than(dummy.hp, dummy.max_hp, 
				"damaged %s (HP: %d)" % [dummy.name, dummy.hp])
		dummy.queue_free()
	flame_wheel.queue_free()
	boss.queue_free()
	navigation.queue_free()


func test_severity_of_damage():
	add_child(player)
	pause_mode = PAUSE_MODE_PROCESS
	var camera = player.camera
	var canvas = player.canvas
	yield(until_timeout(Constants.FLAMETHROWER_DURATION), YIELD)
	asserts.is_false(player.is_dead(), "player still alive after one tick")
	
	yield(until_signal(player, "tree_exiting", 
			3 - Constants.FLAMETHROWER_DURATION), YIELD)
	asserts.is_true(not is_instance_valid(player) or player.is_dead(), 
			"player died within 3 seconds")
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
	if is_instance_valid(flames):
		flames.queue_free()
	if is_instance_valid(player):
		player.queue_free()
		yield(until_signal(player, "tree_exited", 0.5), YIELD)
