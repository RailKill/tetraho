extends WAT.Test


var block_resource = preload("res://assets/scenes/tetris/tetromino_block.tscn")
var test_blocks: Array


func pre():
	test_blocks = []


func test_basic_solve_3x3():
	create_blocks()
	asserts.is_equal(GameWorld.blocks.size(), test_blocks.size(), \
			"%d blocks observed in world" % test_blocks.size())
	GameWorld.solve()
	asserts.is_true(GameWorld.blocks.empty(), "all blocks solved")


func test_is_actor_locked_check():
	var dummy = Actor.new()
	GameWorld.blocks["test"] = [dummy]
	asserts.is_true(GameWorld.is_actor_locked(dummy))
	dummy.queue_free()


func test_kill_trapped_actors_with_solve():
	create_blocks()
	var dummy = Actor.new()
	dummy.sound_death = AudioStreamPlayer2D.new()
	dummy.collision_shape = Node2D.new()
	var dummy2 = Actor.new()
	dummy2.sound_death = AudioStreamPlayer2D.new()
	dummy2.collision_shape = Node2D.new()
	
	GameWorld.blocks[test_blocks[0]] = [dummy]
	GameWorld.blocks[test_blocks[1]] = [dummy2]
	GameWorld.solve()
	asserts.is_true(dummy.is_dead() and dummy2.is_dead())
	dummy.queue_free()
	dummy2.queue_free()


func test_rotated_solve():
	var normal_set = [
		Vector2.ZERO,
		Vector2(Constants.GRID_SIZE, 0),
		Vector2(Constants.GRID_DOUBLE, 0),
	]
	
	var rotated_set = [
		Vector2(0, Constants.GRID_DOUBLE),
		Vector2(Constants.GRID_SIZE, Constants.GRID_DOUBLE),
		Vector2(Constants.GRID_DOUBLE, Constants.GRID_DOUBLE),
	]
	
	for position in normal_set:
		var block = block_resource.instance()
		add_child(block)
		block.global_position = position
		block.enable()
		test_blocks.append(block)
	
	for position in rotated_set:
		var block = block_resource.instance()
		add_child(block)
		block.global_position = position
		block.rotation_degrees = 270
		block.enable()
		test_blocks.append(block)
	
	GameWorld.solve()
	asserts.is_true(GameWorld.blocks.empty())


func test_search():
	var solver = [Vector2(Constants.GRID_DOUBLE, 0)]
	var faker = [Vector2(Constants.GRID_DOUBLE * 2, 0)]
	for position in [Vector2.ZERO] + solver:
		var block = block_resource.instance()
		add_child(block)
		block.global_position = Vector2(200, 200) + position
		block.enable()
		test_blocks.append(block)
	
	asserts.is_false(GameWorld.search(test_blocks[0], faker), \
			"no solution when wrong pattern is used")
	for block in test_blocks:
		asserts.is_false(block.marked, "before search, %s is unmarked" % block)
	
	asserts.is_true(GameWorld.search(test_blocks[0], solver), \
			"solution found when correct pattern is used")	
	for block in test_blocks:
		asserts.is_true(block.marked, "after search, %s is marked" % block)


func test_solve_damages_only_once():
	create_blocks()
	var dummy = Actor.new()
	dummy.sound_death = AudioStreamPlayer2D.new()
	dummy.collision_shape = Node2D.new()
	
	GameWorld.blocks[test_blocks[0]] = [dummy]
	GameWorld.blocks[test_blocks[1]] = [dummy]
	GameWorld.solve()
	asserts.is_equal(dummy.hp, dummy.max_hp - Constants.TETROMINO_DAMAGE)
	dummy.queue_free()


func test_trap():
	var dummy = Actor.new()
	var block = block_resource.instance()
	add_child(block)
	GameWorld.blocks[block] = []
	block.trap(dummy)
	asserts.is_true(dummy.is_locked(), "actor locked by block")
	block.queue_free()
	yield(until_signal(block, "tree_exited", 0.5), YIELD)
	asserts.is_false(dummy.is_locked(), "actor freed when block is destroyed")
	dummy.queue_free()


func test_untrap():
	var dummy = Actor.new()
	var block = block_resource.instance()
	GameWorld.blocks[block] = [dummy]
	block.untrap()
	asserts.is_true(GameWorld.blocks.empty())
	block.queue_free()
	dummy.queue_free()


func post():
	for block in test_blocks:
		if is_instance_valid(block):
			block.queue_free()
	GameWorld.blocks = {}


# Function to create 3x3 test blocks by default.
func create_blocks():
	var triple = Constants.GRID_SIZE * 3
	var three_by_three = [
		Vector2(Constants.GRID_SIZE, Constants.GRID_SIZE),
		Vector2(Constants.GRID_DOUBLE, Constants.GRID_SIZE),
		Vector2(triple, Constants.GRID_SIZE),
		Vector2(Constants.GRID_SIZE, Constants.GRID_DOUBLE),
		Vector2(Constants.GRID_DOUBLE, Constants.GRID_DOUBLE),
		Vector2(triple, Constants.GRID_DOUBLE),
		Vector2(Constants.GRID_SIZE, triple),
		Vector2(Constants.GRID_DOUBLE, triple),
		Vector2(triple, triple),
	]
	
	for placement in three_by_three:
		var instance = block_resource.instance()
		add_child(instance)
		instance.position = placement
		instance.enable()
		test_blocks.append(instance)
