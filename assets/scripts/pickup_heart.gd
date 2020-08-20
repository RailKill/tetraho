class_name PickupHeart
extends Area2D
# A heart pickup that will restore an actor's HP.


func _on_Heart_body_entered(body):
	if body is Actor:
		body.heal(Constants.HEART_HEAL)
		queue_free()
