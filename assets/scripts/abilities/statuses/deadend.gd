class_name Deadend
extends Status
# Unstucks its parent node by checking for adjacent grid cells and moving
# there if it is empty.


var checker_resource = preload("res://assets/scenes/areas/area_checker.tscn")
var distance = Constants.GRID_SIZE
var directions = Constants.DIRECTIONALS
var index = 0

onready var checkpoint = global_position


func _init():
	name = "Unstuck"


func _ready():
	check()


func _on_checker_return(collided):
	if not collided:
		get_parent().global_position = checkpoint
		expire()
	else:
		advance()
		check()


func advance():
	index += 1
	if index >= directions.size():
		index = 0
		distance += Constants.GRID_SIZE


# Check for an empty space in adjacent grid cells.
func check():
	var checker = checker_resource.instance()
	checker.is_snapped = true
	checker.global_position = global_position + \
			directions[index] * distance
	checker.connect("lifetime_expired", self, "_on_checker_return")
	get_parent().get_parent().add_child(checker)
	checkpoint = checker.collision_shape.global_position
