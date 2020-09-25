class_name AreaAggro
extends Area2D
# Actors that come into contact with this area will be aggro-ed.


# Allow units to be de-aggroed if they leave this area.
export(bool) var can_deaggro = true


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	# warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if "is_aggro" in body:
		body.is_aggro = true


func _on_body_exited(body):
	if can_deaggro and "is_aggro" in body:
		body.is_aggro = false
