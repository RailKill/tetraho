extends WAT.Test
# Test areas that usually do something upon collision with another entity.


var damage_resource = preload("res://assets/scenes/areas/area_damage.tscn")
var dummy_resource = preload("res://assets/scenes/actors/dummy.tscn")

var dummy: Actor
var area_damage: AreaDamage


func pre():
	dummy = dummy_resource.instance()
	add_child(dummy)
	area_damage = damage_resource.instance()


func test_cannot_damage_the_same_actor_twice():
	add_child(area_damage)
	area_damage._on_body_entered(dummy)
	area_damage._on_body_entered(dummy)
	yield(until_signal(get_tree(), "idle_frame", 0.1), YIELD)
	asserts.is_equal(dummy.hp, dummy.max_hp - area_damage.damage)


func test_cannot_damage_teammates():
	dummy.team = Constants.Team.SUITS
	area_damage.creator = dummy
	add_child(area_damage)
	area_damage._on_body_entered(dummy)
	yield(until_signal(get_tree(), "idle_frame", 0.1), YIELD)
	asserts.is_equal(dummy.hp, dummy.max_hp)


func test_disappears_after_2_seconds():
	add_child(area_damage)
	yield(until_signal(area_damage, "tree_exited", 2), YIELD)
	asserts.is_false(is_instance_valid(area_damage))
	

func post():
	dummy.queue_free()
	if is_instance_valid(area_damage):
		area_damage.queue_free()
