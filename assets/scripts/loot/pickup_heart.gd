class_name PickupHeart
extends Area2D
# A heart pickup that will restore an actor's HP.


var sound_pickup: AudioStreamPlayer2D


func _ready():
	sound_pickup = $SoundPickup
	$AnimationPlayer.play("Wiggle")


func _on_Heart_body_entered(body):
	if body is Actor and not body is Enemy and not sound_pickup.is_playing():
		hide()
		body.heal(Constants.HEART_HEAL)
		sound_pickup.play()
		yield(sound_pickup, "finished")
		queue_free()
