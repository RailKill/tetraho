class_name SpeechBubble
extends Node2D
# A speech bubble box that contains a label.


# Reference to the AnimationPlayer node.
onready var animation = $AnimationPlayer
# Reference to the Label node showing the text.
onready var label = $Label
# List of strings to say.
export var speech : PoolStringArray = []
# Current index of the speech to deliver.
var index = 0
# This will be set to true if the speech bubble is closing.
var is_closing = false


func _ready():
	if speech.empty():
		queue_free()
	else:
		start()


func _input(_event):
	if Input.is_action_just_pressed("action_interact"):
		skip()


# Go to next line of speech.
func next():
	end()
	is_closing = true
	yield(animation, "animation_finished")
	is_closing = false
	
	index += 1
	if index < speech.size():
		start()
	else:
		queue_free()


# Skip to the end of the dialog animation.
func skip():
	if not is_closing:
		var length = animation.get_current_animation_length()
		if animation.get_current_animation_position() != length:
			animation.seek(length)
		else:
			next()


# Start speech bubble animation.
func start():
	label.set_text(speech[index])
	animation.set_speed_scale(1)
	animation.play("Dialog")


# End speech bubble animation.
func end():
	animation.set_speed_scale(4)
	animation.play_backwards("Dialog")
	

