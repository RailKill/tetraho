class_name Effect
extends AnimatedSprite
# An AnimatedSprite effect that automatically plays its animation.
# On ready, it tries to get a AudioStreamPlayer2D child named "SoundEffect"
# and will destroy itself once that sound is finished. If there is no
# sound node, it will destroy itself when its animation is finished.


# Called when the node enters the scene tree for the first time.
func _ready():
	var sound_effect = get_node_or_null("SoundEffect")
	if sound_effect:
		sound_effect.connect("finished", self, "queue_free")
	else:
		# warning-ignore:return_value_discarded
		connect("animation_finished", self, "queue_free")
	
	play()
