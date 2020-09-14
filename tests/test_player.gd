extends WAT.Test
# Test for player object.


# Resource path of the player object.
var resource = preload("res://assets/objects/actors/player.tscn")
# Reference to Player node.
var player: PlayerCharacter


# Triggers the actions and checks if the player's position is expected. 
#
# action: input action event name to trigger
# index: the index of the Vector2 to check (0 for x, 1 for y)
# assert_func: assert function to be called to check player's position
func move(action, index, assert_func):
	var original = player.global_position[index]
	Utility.simulate_action(action)
	yield(until_timeout(0.1), YIELD)
	Utility.simulate_action(action, false)
	asserts.call(assert_func, original, player.global_position[index])


func pre():
	player = resource.instance()
	add_child(player)


func test_damage_updates_hud():
	var hearts = player.hud.hearts
	var half_heart_damage = player.max_hp / hearts.size() / 2
	
	# Half heart sprite is frame #1.
	player.oof(half_heart_damage)
	asserts.is_equal(hearts[hearts.size() - 1].frame, 1, 
			"half heart damage shown correctly")
	
	# Full empty heart sprite is frame #2.
	player.oof(half_heart_damage)
	asserts.is_equal(hearts[hearts.size() - 1].frame, 2, 
			"full heart damage shown correctly")
	
	yield(until_timeout(0.01), YIELD)


func test_dash():
	# Dash cooldown should be READY and visible in HUD.
	asserts.is_true(player.hud.dash_ready.visible and not \
			player.hud.recharging.visible, "cooldown ready in HUD")
	
	yield(until_timeout(0.01), YIELD)
	Utility.simulate_action("ui_right")
	Utility.simulate_action("action_dash")
	var time = 0.5
	yield(until_timeout(time), YIELD)
	Utility.simulate_action("ui_right", false)
	Utility.simulate_action("action_dash", false)
	asserts.is_greater_than(player.global_position.x, 
			player.move_speed * time * 100, "moved a significant distance")
	
	# After dash, HUD should show that dash is on cooldown and recharging.
	asserts.is_true(player.hud.recharging.visible and not \
			player.hud.dash_ready.visible, "cooldown updated in HUD")


func test_death_handled_correctly():
	pause_mode = PAUSE_MODE_PROCESS
	var camera = player.camera
	var canvas = player.canvas
	var menu = player.menu
	player.oof(player.max_hp)
	yield(until_signal(player, "tree_exited", 0.5), YIELD)
	yield(until_timeout(0.01), YIELD)
	
	asserts.is_true(menu.visible, "menu visible")
	asserts.is_equal(menu.title.text.to_lower(), "you died", 
			"death message shown")
	asserts.is_true(menu.cannot_close, "menu cannot be closed")
	asserts.is_true(is_instance_valid(camera), 
			"camera transferred to parent node")
	asserts.is_true(is_instance_valid(canvas), 
			"canvas transferred to parent node")
	camera.queue_free()
	canvas.queue_free()
	get_tree().paused = false


func test_hold_tetromino_when_empty():
	var current = player.current
	
	Utility.simulate_action("action_special", false)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_special")
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_special", false)
	yield(until_timeout(0.01), YIELD)
	
	asserts.is_equal(player.hold, current)
	player.hold.queue_free()


func test_hold_tetromino_swapped_correctly():
	var current = player.current
	var fake = Tetromino.new()
	player.hold = fake
	
	Utility.simulate_action("action_special", false)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_special")
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_special", false)
	yield(until_timeout(0.01), YIELD)
	
	asserts.is_equal(player.current, fake)
	asserts.is_equal(player.hold, current)
	player.hold.queue_free()


func test_movement_up():
	move("ui_up", 1, "is_greater_than")


func test_movement_down():
	move("ui_down", 1, "is_less_than")


func test_movement_left():
	move("ui_left", 0, "is_greater_than")


func test_movement_right():
	move("ui_right", 0, "is_less_than")


func post():
	# Player may have died and removed from the game in one of the tests.
	if is_instance_valid(player):
		player.current.queue_free()
		player.queue_free()
