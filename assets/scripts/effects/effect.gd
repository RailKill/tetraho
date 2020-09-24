class_name Effect
extends AnimatedSprite
# An AnimatedSprite effect that automatically plays its animation.
# On ready, it tries to get a AudioStreamPlayer2D child named "SoundEffect"
# and will destroy itself once both sound and animation are finished.


var animation_completed = false setget set_animation_completed
var sound_completed = false setget set_sound_completed


func _ready():
	var sound = get_node_or_null("SoundEffect")
	if sound:
		sound.connect("finished", self, "set_animation_completed", [true])
	
	# warning-ignore:return_value_discarded
	connect("animation_finished", self, "set_sound_completed", [true])
	play()


func destroy():
	if animation_completed and sound_completed:
		queue_free()


func set_animation_completed(completion: bool):
	animation_completed = completion
	destroy()


func set_sound_completed(completion: bool):
	sound_completed = completion
	destroy()
