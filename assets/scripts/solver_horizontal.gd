class_name SolverHorizontal
extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Horizontal2x3_body_entered(body):
	count += 1
	print(body, "| count: ", count)
