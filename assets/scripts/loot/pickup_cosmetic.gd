class_name PickupCosmetic
extends Area2D
# Comsetic pickups for the player.


onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var sound_pickup = $SoundPickup


func _on_Hat_body_entered(body):
	if body is PlayerCharacter and not sound_pickup.is_playing():
		body.hud.hat.show()
		remove_child(sprite)
		body.add_child(sprite)
		sprite.set_position(Vector2(0, -8))
		sound_pickup.play()
		yield(sound_pickup, "finished")
		queue_free()


func _on_Crown_body_entered(body):
	if body is PlayerCharacter and not sound_pickup.is_playing():
		body.hud.crown.show()
		remove_child(sprite)
		body.add_child(sprite)
		sprite.set_scale(Vector2(0.5, 0.5))
		sprite.set_rotation_degrees(25)
		sprite.set_position(Vector2(4, -10))
		sound_pickup.play()
		yield(sound_pickup, "finished")
		queue_free()
