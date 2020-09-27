extends WAT.Test
# Tests the functionalities of enemies in the game.


# Navmesh coverage which acts as the radius of the navmesh rectangle.
const NC = Constants.GRID_SIZE * 5

var block_resource = preload("res://assets/scenes/tetris/tetromino_block.tscn")
var bmancer_resource = preload("res://assets/scenes/actors/blockmancer.tscn")
var boss_resource = preload("res://assets/scenes/actors/boss.tscn")
var duck_resource = preload("res://assets/scenes/actors/duck.tscn")
var gate_resource = preload("res://assets/scenes/objects/gate.tscn")
var gunner_resource = preload("res://assets/scenes/actors/gunner.tscn")
var house_resource = preload("res://assets/scenes/actors/duck_house.tscn")
var player_resource = preload("res://assets/scenes/actors/player.tscn")

var player: PlayerCharacter
var navigation: Navigation2D
var navmesh: NavigationPolygonInstance


func start():
	# Create a Navigation2D object for the enemies to do pathfinding.
	navigation = Navigation2D.new()
	navigation.name = "Navigation2D"
	navmesh = NavigationPolygonInstance.new()
	
	# Draw a square with its center on origin. This forms the navmesh.
	var polygon = NavigationPolygon.new()
	var outline = PoolVector2Array(
		[Vector2(-NC, -NC), Vector2(-NC, NC), Vector2(NC, NC), Vector2(NC, -NC)]
	)
	polygon.add_outline(outline)
	polygon.make_polygons_from_outlines()
	navmesh.navpoly = polygon
	
	add_child(navigation)
	navigation.add_child(navmesh)


func pre():
	player = player_resource.instance()
	add_child(player)
	player.global_position = Vector2(NC, 0)
	player.current.queue_free()


func test_blockmancer_capable_of_damaging_player():
	player.translate(Vector2.UP * 2)
	var bmancer = bmancer_resource.instance()
	add_child(bmancer)
	var args = yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_true(player.hp != player.max_hp, 
			"%s %s for %d damage" % args.slice(1, 3) if args[0] else 
			"attack the player")
	bmancer.queue_free()
	
	var deadmino = $Deadmino
	var position = deadmino.global_position
	asserts.is_true(
			int(round(position.x)) % Constants.GRID_SIZE == 0 and \
			int(round(position.y)) % Constants.GRID_SIZE == 0,
			"the spawned dead block is snapped to grid"
	)
	if is_instance_valid(deadmino):
		$Deadmino.queue_free()


func test_blockmancer_race_condition_damages_player_only_once():
	player.global_position = Vector2.ZERO
	var bmancers = []
	var positions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for position in positions:
		var bmancer = bmancer_resource.instance()
		bmancer.global_position = position * 50
		add_child(bmancer)
		bmancers.append(bmancer)
	
	yield(until_signal(bmancers[0].get_node("Spawn"), 
			"finished_casting", 2), YIELD)
	yield(until_timeout(2), YIELD)
	var deadminos = []
	for node in get_children():
		if node.name.find_last("Deadmino") != -1:
			deadminos.append(node)
	asserts.is_equal(deadminos.size(), 1, "only one dead block was spawned")
	asserts.is_equal(player.hp, player.max_hp - Constants.DEAD_BLOCK_DAMAGE, 
			"player took only one instance of damage")
	
	for bmancer in bmancers:
		bmancer.queue_free()
	for deadmino in deadminos:
		deadmino.queue_free()


func test_boss():
	var boss = boss_resource.instance()
	add_child(boss)
	yield(until_timeout(0.5), YIELD)
	asserts.is_greater_than(boss.global_position, Vector2.ZERO, "chased player")
	var args = yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_less_than(player.hp, player.max_hp, 
			"%s %s for %d damage" % args.slice(1, 3) if args[0] else 
			"melee the player")
	player.global_position = Vector2(-NC * 2, 0)
	var current_hp = player.hp
	args = yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_less_than(player.hp, current_hp, 
			"%s %s for %d damage" % args.slice(1, 3) if args[0] else 
			"shoot the player")
	boss.queue_free()
	yield(until_timeout(0.5), YIELD)


func test_duck():
	player.global_position = Vector2(NC / 2.0, 0)
	var duck = duck_resource.instance()
	add_child(duck)
	
	yield(until_timeout(0.5), YIELD)
	asserts.is_greater_than(duck.global_position, Vector2.ZERO, "chased player")
	var args = yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_true(player.hp != player.max_hp, 
			"%s %s for %d damage" % args.slice(1, 3) if args[0] else 
			"attack the player")
	
	duck.queue_free()


func test_duck_house():
	player.is_invulnerable = true
	var house = house_resource.instance()
	add_child(house)
	
	Engine.time_scale = 10.0
	# Test 1: Duck house is invulnerable by default.
	house.oof(5)
	asserts.is_equal(house.hp, house.max_hp, "is invulnerable by default")
	
	# Test 2: Over the course of 20 seconds, no more than 3 ducks are spawned.
	yield(until_timeout(20), YIELD)
	var ducks = get_ducks()
	asserts.is_equal(ducks.size(), 3, "spawned exactly 3 ducks over 20 seconds")
	
	# Test 3: Remove 1 duck, and check if it spawns 1 more, replenishing to 3.
	if not ducks.empty():
		ducks[0].queue_free()
	yield(until_timeout(10), YIELD)
	ducks = get_ducks()
	asserts.is_equal(ducks.size(), 3, "after removing 1 duck, replenish to 3")
	for duck in ducks:
		duck.queue_free()
	
	# Test 4: No duck spawned if blocked by obstacle.
	var gate = gate_resource.instance()
	add_child(gate)
	gate.global_position = Vector2(Constants.GRID_ONE_HALF, -Constants.GRID_HALF)
	yield(until_timeout(10), YIELD)
	ducks = get_ducks()
	asserts.is_equal(ducks.size(), 0, "no duck spawned if blocked by obstacle")
	gate.queue_free()
	house.is_aggro = false
	for duck in ducks:
		duck.queue_free()
	
	# Test 5: Player can push Duck into house to destroy it.
	Engine.time_scale = 1.0
	var sole_duck = duck_resource.instance()
	add_child(sole_duck)
	sole_duck.global_position = Vector2(NC / 2.0, 0)
	Utility.simulate_action("ui_left")
	yield(until_signal(house, "tree_exited", 3), YIELD)
	Utility.simulate_action("ui_left", false)
	asserts.is_false(is_instance_valid(house), "destroyed by pushing")
	if is_instance_valid(house):
		house.queue_free()
	if is_instance_valid(sole_duck):
		asserts.is_true(sole_duck.is_dead(), "duck died along")
		sole_duck.queue_free()
	
	# Test 6: Player can dash Duck into house and destroy it.
	player.global_position = Vector2(NC, 0)
	player.dash.direction = Vector2.LEFT
	house = house_resource.instance()
	add_child(house)
	house.is_aggro = false
	player.dash.cast()
	yield(until_signal(house, "tree_exited", 3), YIELD)
	asserts.is_false(is_instance_valid(house), "destroyed by dash knockback")
	asserts.is_true(get_ducks().empty(), "no ducks present")
	if is_instance_valid(house):
		house.queue_free()


func test_gunner():
	var gunner = gunner_resource.instance()
	add_child(gunner)
	var args = yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_true(player.hp != player.max_hp, 
			"%s %s for %d damage" % args.slice(1, 3) if args[0] else 
			"attack the player")
	
	# After player moves, gunner should continue to track and gun them down.
	var current_hp = player.hp
	player.global_position = Vector2(-NC, NC)
	yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_true(player.hp != current_hp, "tracked and damaged player")
	
	# Continue to shoot even if a tetromino block is in between.
	var block = block_resource.instance()
	add_child(block)
	block.global_position = Vector2(-NC / 2.0, NC / 2.0)
	block.enable()
	yield(until_signal(block, "damage_taken", 3), YIELD)
	asserts.is_true(block.hp != block.max_hp, "shot blocked by tetromino")
	
	block.queue_free()
	gunner.queue_free()


func test_unstuck():
	var blocks = []
	var block_positions = [
		Vector2(NC - Constants.GRID_SIZE, -Constants.GRID_SIZE),
		Vector2(NC, -Constants.GRID_SIZE),
		Vector2(NC + Constants.GRID_SIZE, -Constants.GRID_SIZE),
		Vector2(NC - Constants.GRID_SIZE, 0),
		Vector2(NC, 0),
		Vector2(NC + Constants.GRID_SIZE, 0),
		Vector2(NC - Constants.GRID_SIZE, Constants.GRID_SIZE),
		Vector2(NC, Constants.GRID_SIZE),
		Vector2(NC + Constants.GRID_SIZE, Constants.GRID_SIZE),
		
		Vector2(NC + Constants.GRID_DOUBLE, -Constants.GRID_SIZE),
		Vector2(NC + Constants.GRID_DOUBLE, 0),
		Vector2(NC + Constants.GRID_DOUBLE, Constants.GRID_SIZE),
		Vector2(NC - Constants.GRID_DOUBLE, Constants.GRID_SIZE),
		Vector2(NC - Constants.GRID_DOUBLE, -Constants.GRID_SIZE),
	]
	for position in block_positions:
		var block = block_resource.instance()
		add_child(block)
		block.global_position = position
		block.enable()
		blocks.append(block)
	
	yield(until_timeout(0.5), YIELD)
	player.unstuck()
	yield(until_timeout(0.5), YIELD)
	asserts.is_equal(player.global_position, 
			Vector2(NC - Constants.GRID_ONE_HALF, Constants.GRID_HALF))
	
	for block in blocks:
		block.queue_free()


func post():
	player.queue_free()
	yield(until_signal(player, "tree_exited", 0.5), YIELD)


func end():
	navigation.queue_free()


func get_ducks():
	var ducks = []
	for node in get_children():
		if node is Duck:
			ducks.append(node)
	return ducks
