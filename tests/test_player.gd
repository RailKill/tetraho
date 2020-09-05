extends WAT.Test
# Test for player object.


# Resource path of the player object.
var resource = preload("res://assets/objects/actors/player.tscn")
# Reference to Player node.
var player


# Triggers the actions and checks if the player's position is expected. 
#
# action: input action event name to trigger
# index: the index of the Vector2 to check (0 for x, 1 for y)
# assert_func: assert function to be called to check player's position
func move(action, index, assert_func):
	var original = player.get_global_position()[index]
	Utility.simulate_action(action)
	yield(until_timeout(0.01), YIELD)
	Utility.simulate_action(action, false)
	asserts.call(assert_func, original, player.get_global_position()[index])


func pre():
	player = resource.instance()
	add_child(player)


func test_death_handled_correctly():
	pause_mode = PAUSE_MODE_PROCESS
	var canvas = player.canvas
	var camera = player.camera
	var menu = player.menu
	player.oof(player.get_maximum_hp())
	yield(until_signal(player, "tree_exited", 0.5), YIELD)
	yield(until_timeout(0.01), YIELD)
	
	asserts.is_true(menu.visible)
	asserts.is_equal(menu.title.get_text().to_lower(), "you died")
	asserts.is_true(menu.cannot_close)
	asserts.is_true(is_instance_valid(canvas))
	asserts.is_true(is_instance_valid(camera))


func test_hold_tetromino_when_empty():
	var current = player.current
	
	Utility.simulate_action("action_special", false)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_special")
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_special", false)
	yield(until_timeout(0.01), YIELD)
	
	asserts.is_equal(player.hold, current)


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


func test_movement_up():
	move("ui_up", 1, "is_greater_than")


func test_movement_down():
	move("ui_down", 1, "is_less_than")


func test_movement_left():
	move("ui_left", 0, "is_greater_than")


func test_movement_right():
	move("ui_right", 0, "is_less_than")


func post():
	if player:
		player.queue_free()
