extends WAT.Test
# Tests the functionalities of enemies in the game.


# Navmesh coverage which acts as the radius of the navmesh rectangle.
const NC = Constants.GRID_SIZE * 5

var block_resource = preload("res://assets/objects/tetris/tetromino_block.tscn")
var duck_resource = preload("res://assets/objects/actors/duck.tscn")
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
	navmesh.enabled = false
	navmesh.enabled = true


func pre():
	player = player_resource.instance()
	add_child(player)
	player.global_position = Vector2(NC / 2.0, 0)


func test_duck():
	var duck = duck_resource.instance()
	duck.is_aggro = true
	add_child(duck)
	
	yield(until_timeout(0.5), YIELD)
	asserts.is_greater_than(duck.get_global_position(), 
			Vector2.ZERO, "chased player")
	var args = yield(until_signal(player, "damage_taken", 3), YIELD)
	asserts.is_true(player.hp != player.max_hp, 
			"%s %s for %d damage" % args.slice(1, 3) if args[0] else 
			"attack the player")
	duck.queue_free()


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
	
	gunner.queue_free()


func post():
	player.queue_free()
	yield(until_signal(player, "tree_exited", 0.5), YIELD)


func end():
	navigation.queue_free()
