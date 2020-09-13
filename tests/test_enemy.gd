extends WAT.Test
# Tests the functionalities of enemies in the game.


# Navmesh coverage which acts as the radius of the navmesh rectangle.
const NC = Constants.GRID_SIZE * 5

var block_resource = preload("res://assets/objects/tetris/tetromino_block.tscn")
var bmancer_resource = preload("res://assets/objects/actors/blockmancer.tscn")
var duck_resource = preload("res://assets/objects/actors/duck.tscn")
var house_resource = preload("res://assets/objects/actors/duck_house.tscn")
var gunner_resource = preload("res://assets/objects/actors/gunner.tscn")
var player_resource = preload("res://assets/objects/actors/player.tscn")
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


func test_blockmancer_capable_of_damaging_player():
	var bmancer = bmancer_resource.instance()
	bmancer.is_aggro = true
	add_child(bmancer)
	yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_true(player.hp != player.max_hp)
	bmancer.queue_free()
	$Deadmino.queue_free()


func test_duck():
	player.global_position = Vector2(NC / 2.0, 0)
	var duck = duck_resource.instance()
	duck.is_aggro = true
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
	house.is_aggro = true
	add_child(house)
	
	# Test 1: Over the course of 20 seconds, no more than 3 ducks are spawned.
	Engine.time_scale = 10.0
	yield(until_timeout(20), YIELD)
	Engine.time_scale = 1.0
	var ducks = []
	for node in get_children():
		if node is Duck:
			ducks.append(node)
	asserts.is_equal(ducks.size(), 3, "spawned exactly 3 ducks")
	for duck in ducks:
		duck.queue_free()
	
	# Test 2: Player can push Duck into house to destroy it.
	house.is_aggro = false
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
		sole_duck.queue_free()


func test_gunner():
	var gunner = gunner_resource.instance()
	gunner.is_aggro = true
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


func post():
	player.current.queue_free()
	player.queue_free()
	yield(until_signal(player, "tree_exited", 0.5), YIELD)


func end():
	navigation.queue_free()
