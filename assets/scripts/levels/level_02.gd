extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(), "idle_frame")
	randomize_spawn([$Events/Exit, $Events/Hat])


func _on_NarrowHelper_body_entered(body):
	if body is PlayerCharacter:
		body.collision_shape.get_shape().set_extents(Vector2(2, 3))


func _on_NarrowHelper_body_exited(body):
	if body is PlayerCharacter:
		body.collision_shape.get_shape().set_extents(Vector2(4, 6))


# Randomize the objective spawns.
func randomize_spawn(objectives):
	var goals = $Events/Goals.get_children()
	for objective in objectives:
		randomize()
		var selected = goals[randi() % goals.size()]
		objective.global_position = selected.global_position
		goals.erase(selected)
