class_name AreaAggro
extends Area2D
# Actors that come into contact with this area will be aggro-ed.


# Allow units to be de-aggroed if they leave this area.
export var can_deaggro = true


func _on_AggroArea_body_entered(body):
	if body is Enemy:
		body.is_aggro = true


func _on_AggroArea_body_exited(body):
	if can_deaggro and body is Enemy:
		body.is_aggro = false
