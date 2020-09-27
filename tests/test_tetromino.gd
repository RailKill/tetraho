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
	tetromino.reticle = null
	tetromino.timer_decay.start()
	Engine.time_scale = 10
	yield(until_timeout(4.5), YIELD)
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
		# Manual call to snap required for devices without mouse.
		tetromino.snap_to_mouse(Vector2(200, 200))
		yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	
	describe("grid snapping with rotation: %d block wide" % tetromino.width)
	asserts.is_true(violation.empty(), violation)


func test_mouse_snapping():
	tetromino.summoner = null
	add_child(tetromino)
	tetromino.snap_to_mouse(Vector2(200, 200))
	yield(until_timeout(0.5), YIELD)
	# warning-ignore:integer_division
	var x = Constants.GRID_SIZE * (200 / Constants.GRID_SIZE)
	# warning-ignore:integer_division
	var y = Constants.GRID_SIZE * (200 / Constants.GRID_SIZE)
	asserts.is_equal(tetromino.global_position, Vector2(x, y))


func test_no_slowdown_with_100_summoned_tetrominos():
	add_child(tetromino)
	var tetrominos = [tetromino]
	var spread_x = Constants.GRID_SIZE
	var spread_y = Constants.GRID_SIZE
	for _i in range(100):
		var more = resource.instance()
		spread_x += Constants.GRID_SIZE * 3
		if spread_x > 1250:
			spread_x = Constants.GRID_SIZE
			spread_y += Constants.GRID_SIZE * 3
		more.global_position = Vector2(spread_x, spread_y)
		more.load_configuration([1, 1], [1, 1], Color.yellow)
		add_child(more)
		tetrominos.append(more)

	for piece in tetrominos:
		piece.summon_piece()
		
	var time_before = OS.get_ticks_msec()
	yield(until_timeout(1), YIELD)
	asserts.is_less_than(OS.get_ticks_msec() - time_before, 1000)
	for piece in tetrominos:
		piece.queue_free()


func test_rotate_piece():
	add_child(tetromino)
	tetromino.rotate_piece()
	yield(until_timeout(0.1), YIELD)
	asserts.is_equal(tetromino.rotation_degrees, 90)


func test_summoning():
	add_child(tetromino)
	tetromino.summon_piece()
	mock_player.current = null
	yield(until_timeout(1), YIELD)
	asserts.is_false(is_instance_valid(tetromino.reticle), "reticle removed")
	asserts.is_true(tetromino.solid.visible, "solid blocks are visible")


func test_toggle_block_visibility():
	add_child(tetromino)
	tetromino.toggle_blocks(true)
	asserts.is_true(is_instance_valid(tetromino.reticle) and \
			tetromino.solid.visible and not tetromino.reticle.visible, 
			"blocks shown without summoning")
	tetromino.toggle_blocks(false)
	asserts.is_true(is_instance_valid(tetromino.reticle) and \
			tetromino.reticle.visible and not tetromino.solid.visible, 
			"reticle shown without summoning")


func post():
	if is_instance_valid(tetromino):
		tetromino.queue_free()
		yield(until_signal(tetromino, "tree_exited", 0.5), YIELD)


func end():
	mock_player.queue_free()


# Just a dummy node that acts as the player but doesn't do anything.
class MockPlayer extends Node2D:
	var current: Tetromino
	var is_controllable = true
	
	func is_current(tetromino):
		return current == tetromino
	
	func next_tetromino():
		pass
