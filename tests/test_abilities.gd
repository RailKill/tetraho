extends WAT.Test


var heart_resource = preload("res://assets/scenes/loot/heart.tscn")
var dummy_resource = preload("res://assets/scenes/actors/dummy.tscn")
var dummy


func pre():
	dummy = dummy_resource.instance()
	add_child(dummy)


func test_burn_no_tick():
	var burn = Burn.new()
	dummy.add_child(burn)
	yield(until_timeout(2.5), YIELD)
	asserts.is_equal(dummy.hp, dummy.max_hp - Constants.FLAMETHROWER_DAMAGE)
	dummy.queue_free()


func test_burn_tick():
	var burn = Burn.new()
	burn.interval = 1
	dummy.add_child(burn)
	yield(until_timeout(2.5), YIELD)
	asserts.is_equal(dummy.hp, dummy.max_hp - Constants.FLAMETHROWER_DAMAGE * 3)
	dummy.queue_free()


func test_dash_cooldown_bonus():
	var dummy2 = dummy_resource.instance()
	dummy2.global_position = Vector2(Constants.GRID_SIZE, 0)
	dummy2.add_to_group("pushable")
	add_child(dummy2)
	var dash = Dash.new()
	watch(dash, "finished_casting")
	dash.duration = 2
	dash.speed = 400
	dummy.add_child(dash)
	yield(until_timeout(0.5), YIELD)
	dash.direction = Vector2.RIGHT
	dash.cast()
	yield(until_signal(dash, "finished_casting", 1), YIELD)
	asserts.signal_was_emitted(dash, "finished_casting", "dash ended early")
	asserts.is_equal(dash.timer_cooldown.time_left, 
			dash.cooldown - dash.cooldown_bonus, "cooldown reduced")
	dummy2.queue_free()


func test_dash_no_cooldown_bonus():
	var dash = Dash.new()
	dash.duration = 0.5
	dash.speed = 400
	dummy.add_child(dash)
	dash.direction = Vector2.RIGHT
	dash.cast()
	yield(until_signal(dash, "finished_casting", 1), YIELD)
	asserts.is_greater_than(dash.timer_cooldown.time_left, 
			dash.cooldown - dash.cooldown_bonus)


func test_knockback():
	var knockback = Knockback.new()
	knockback.duration = 1
	knockback.direction = Vector2.DOWN
	knockback.speed = 500
	dummy.add_child(knockback)
	knockback.cast()
	yield(until_signal(knockback, "finished_casting", 1.5), YIELD)
	asserts.is_greater_than(dummy.global_position.y, 480)
	asserts.is_less_than(dummy.global_position.y, 520)


func test_link():
	var link = Link.new()
	var node1 = Node2D.new()
	node1.name = "LinkedNode1"
	var node2 = Node2D.new()
	node2.name = "LinkedNode2"
	add_child(node1)
	add_child(node2)
	link.linked = ["../../" + node1.name, "../../" + node2.name]
	dummy.add_child(link)
	dummy.queue_free()
	yield(until_timeout(0.5), YIELD)
	asserts.is_false(is_instance_valid(node1))
	asserts.is_false(is_instance_valid(node2))
	if is_instance_valid(node1):
		node1.queue_free()
	if is_instance_valid(node2):
		node2.queue_free()


func test_status_expire():
	var status = Status.new()
	status.duration = 1
	add_child(status)
	yield(until_signal(status, "tree_exited", 1.5), YIELD)
	asserts.is_false(is_instance_valid(status))
	
	if is_instance_valid(status):
		status.queue_free()


func test_treasure():
	var treasure = Treasure.new()
	treasure.drops = [heart_resource, heart_resource]
	dummy.add_child(treasure)
	dummy.oof(dummy.max_hp)
	yield(until_signal(dummy, "tree_exited", 0.5), YIELD)
	var hearts = []
	for node in get_children():
		if node is PickupHeart:
			hearts.append(node)
	asserts.is_equal(hearts.size(), 2)
	for heart in hearts:
		heart.queue_free()


func post():
	if is_instance_valid(dummy):
		dummy.queue_free()
		yield(until_signal(dummy, "tree_exited", 0.5), YIELD)
