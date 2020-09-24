class_name SpeechBubble
extends Node2D
# An animated, skippable speech bubble box that contains a label.


const OPEN = "DialogOpen"
const CLOSE = "DialogClose"

# Current index of the speech to deliver.
var index = 0
# Elapsed time sinced last skip.
var elapsed_time = 0
# Speech object for this bubble to display.
var speech

# Reference to the AnimationPlayer node.
onready var animation = $AnimationPlayer
# Reference to the Graphics node.
onready var graphics = $Graphics
# Reference to the Label node showing the text.
onready var label = $Graphics/Label
# Reference to the AudioStreamPlayer2D which plays the bubble pop sound.
onready var sound_pop = $SoundPop


func _ready():
	animation.connect("animation_finished", self, "next")
	visible = false


func _process(delta):
	if speech.duration > 0:
		elapsed_time += delta
		if elapsed_time >= speech.duration:
			skip()
			elapsed_time = 0


func _input(_event):
	if visible and Input.is_action_just_pressed("action_interact") and \
			not animation.current_animation == CLOSE:
		skip()


# Start speech bubble animation.
func start():
	visible = true
	label.set_text(speech.lines[index])
	animation.play(OPEN)
	sound_pop.play()


# Skip to the end of the open animation, or close dialog if already at the end.
func skip():
	if animation.current_animation == OPEN:
		var length = animation.get_animation(OPEN).length
		if animation.current_animation_position > 0.5 and \
				animation.current_animation_position < length:
			animation.seek(length)
	else:
		end()


# Go to next line of speech if the close animation is completed.
func next(animation_name=CLOSE):
	if animation_name == CLOSE:
		index += 1
		if index < speech.lines.size():
			start()
		else:
			queue_free()


# End speech bubble animation.
func end():
	animation.play(CLOSE)
