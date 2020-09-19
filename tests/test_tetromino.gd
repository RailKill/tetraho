extends WAT.Test
# Test the functionalities and abilities of tetromino summoning.


var resource = preload("res://assets/scenes/tetris/tetromino.tscn")
var tetromino: Tetromino
var mock_player: MockPlayer


func start():
	mock_player = MockPlayer.new()
	add_child(mock_player)


func pre():
	tetromino = resource.instance()
	tetromino.summoner = mock_player
	mock_player.current = tetromino


func test_block_configuration():
	tetromino.load_configuration([1, 0, 1], [1, 1, 1], Color.white)
	add_child(tetromino)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	var expected = [
		Vector2(-Constants.GRID_ONE_HALF, -Constants.GRID_SIZE),
		Vector2(-Constants.GRID_ONE_HALF, 0),
		Vector2(-Constants.GRID_HALF, 0),
		Vector2(Constants.GRID_HALF, -Constants.GRID_SIZE),
		Vector2(Constants.GRID_HALF, 0),
	]
	asserts.is_equal(tetromino.configuration, expected)


func test_decaying():
	mock_player.current = null
	add_child(tetromino)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	tetromino.reticle.queue_free()
	Engine.time_scale = 10
	yield(until_timeout(Constants.TETROMINO_DECAY_TIME + 0.5), YIELD)
	Engine.time_scale = 1
	asserts.is_false(is_instance_valid(tetromino))


func test_grid_snapping():
	parameters([
		["top", "bottom", "color"],
		[[1], [1], Color.white],
		[[1, 1], [0, 0], Color.aliceblue],
		[[1, 0, 0], [1, 1, 1], Color.orange],
		[[0, 0, 0, 0], [1, 1, 1, 1], Color.aqua],
		[[0, 0, 1, 0, 0], [1, 1, 0, 1, 1], Color.tomato],
		[[1, 1, 1, 1, 1, 1], [1, 0, 1, 0, 1, 0], Color.turquoise],
	])
	tetromino.load_configuration(p.top, p.bottom, p.color)
	add_child(tetromino)
	var violation = ""
	
	while violation.empty() and tetromino.rotation_degrees <= 270:
		for block in tetromino.reticle.get_children() + \
				tetromino.solid.get_children():
			var x_violation = block.global_position.x != 0 and \
				int(round(block.global_position.x)) % Constants.GRID_SIZE != 0
			var y_violation = block.global_position.y != 0 and \
				int(round(block.global_position.y)) % Constants.GRID_SIZE != 0
			
			if x_violation or y_violation:
				violation = "grid violation at local %s, global %s" % \
						[block.position, block.global_position]
				break
		tetromino.rotation_degrees += 90
		yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	
	describe("grid snapping with rotation: %d block wide" % tetromino.width)
	asserts.is_true(violation.empty(), violation)


func test_mouse_snapping():
	add_child(tetromino)
	Input.warp_mouse_position(Vector2(200, 200))
	yield(until_timeout(0.5), YIELD)
	# warning-ignore:integer_division
	var x = Constants.GRID_SIZE * (200 / Constants.GRID_SIZE)
	# warning-ignore:integer_division
	var y = Constants.GRID_SIZE * (200 / Constants.GRID_SIZE)
	asserts.is_equal(tetromino.global_position, Vector2(x, y))


func test_rotation_input():
	add_child(tetromino)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_secondary")
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_secondary", false)
	yield(until_timeout(0.1), YIELD)
	asserts.is_equal(tetromino.rotation_degrees, 90)


func test_summoning():
	add_child(tetromino)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_primary")
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_primary", false)
	asserts.is_true(tetromino.is_summoning, "summoning state entered")
	mock_player.current = null
	yield(until_timeout(Constants.TETROMINO_SUMMON_TIME), YIELD)
	asserts.is_false(is_instance_valid(tetromino.reticle), "reticle removed")
	asserts.is_true(tetromino.solid.visible, "solid blocks are visible")


func test_toggle_block_visibility():
	add_child(tetromino)
	tetromino.toggle_blocks(true)
	asserts.is_true(not tetromino.is_summoning and tetromino.solid.visible \
			and not tetromino.reticle.visible, "blocks shown without summoning")
	tetromino.toggle_blocks(false)
	asserts.is_true(not tetromino.is_summoning and tetromino.reticle.visible \
			and not tetromino.solid.visible, "reticle shown without summoning")


func post():
	if is_instance_valid(tetromino):
		tetromino.queue_free()
		yield(until_signal(tetromino, "tree_exited", 0.5), YIELD)


func end():
	mock_player.queue_free()


# Just a dummy node that acts as the player but doesn't do anything.
class MockPlayer extends Node2D:
	var current: Tetromino
	
	func is_current(tetromino):
		return current == tetromino
	
	func next_tetromino():
		pass
