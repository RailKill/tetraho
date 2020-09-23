class_name Speech
extends Node
# Speech node which represents a single unit of dialog.
# Used as a child of AreaDialog.


# The NodePath to the Actor speaker who wiil deliver this speech.
export(NodePath) var speaker setget ,get_speaker
# List of lines for this speech to deliver.
export(PoolStringArray) var lines setget ,get_lines
# Number of seconds for each line before auto-skip. 0 means infinite.
export(float, 0, 60) var duration = 0

# Resource of the speech bubble to create.
var resource = preload("res://assets/scenes/ui/speech_bubble.tscn")


# Delivers this speech by creating a speech bubble on the speaker.
func deliver() -> SpeechBubble:
	var bubble = resource.instance()
	bubble.speech = self
	get_speaker().add_speech(bubble)
	return bubble


func get_speaker():
	return get_node(speaker)


func get_lines():
	return lines
