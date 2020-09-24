extends WAT.Test
# Test dialog between actors.


var dummy_resource = preload("res://assets/scenes/actors/dummy.tscn")
var exit_resource = preload("res://assets/scenes/areas/exit.tscn")

var speaker: Actor
var speech: Speech


func pre():
	speaker = dummy_resource.instance()
	add_child(speaker)
	speech = Speech.new()
	add_child(speech)
	speech.speaker = speech.get_path_to(speaker)


func test_exit_dialog_advance():
	speech.lines = ["ur mom gay"]
	remove_child(speech)
	var another_speech = Speech.new()
	another_speech.lines = ["no u"]
	var another_dude = dummy_resource.instance()
	another_dude.global_position = Vector2(100, 0)
	add_child(another_dude, true)
	
	var exit = exit_resource.instance()
	exit.add_child(speech)
	exit.add_child(another_speech)
	speech.speaker = "../../Dummy"
	another_speech.speaker = "../../Dummy2"
	exit.conditionals = ["false"]
	add_child(exit)
	
	# Test 1st speech by first speaker.
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	var bubble1 = speaker.get_node_or_null("SpeechBubble")
	asserts.is_not_null(bubble1, "first speaker spoke")
	if bubble1 != null:
		asserts.is_equal(bubble1.label.text, speech.lines[0], 
				"successfully delivered first speech")
	
	# Test 2nd speech by second speaker.
	bubble1.queue_free()
	yield(until_signal(bubble1, "tree_exited", 0.5), YIELD)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	var bubble2 = another_dude.get_node_or_null("SpeechBubble")
	asserts.is_not_null(bubble2, "second speaker spoke")
	if bubble2 != null:
		asserts.is_equal(bubble2.label.text, another_speech.lines[0], 
				"successfully delivered second speech")
	
	# Test to make sure exit is still there after dialog is complete.
	bubble2.queue_free()
	yield(until_signal(bubble2, "tree_exited", 0.5), YIELD)
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	asserts.is_true(is_instance_valid(exit), "exit persists after dialog")
	
	another_dude.queue_free()
	exit.queue_free()


func test_speech_bubble_advance():
	speech.lines = ["hi there", "i'm a big boye"]
	var bubble = speech.deliver()
	yield(until_signal(bubble, "ready", 0.5), YIELD)
	asserts.is_true(speaker.is_a_parent_of(bubble) and bubble.visible and not \
			bubble.label.percent_visible, "actor is starting to speak")
	yield(until_signal(bubble.animation, "animation_finished", 2), YIELD)
	asserts.is_true(bubble.index == 0 and bubble.label.percent_visible == 1, 
			"text automatically fully visible after 2 seconds")
	
	Utility.simulate_action("action_interact")
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_interact", false)
	asserts.is_equal(bubble.animation.current_animation, bubble.CLOSE,
			"first line's bubble is closing")
	
	var started = yield(until_signal(
			bubble.animation, "animation_started", 1), YIELD)
	asserts.is_equal(started[0], bubble.OPEN, "second line's bubble starting")
	
	yield(until_timeout(1), YIELD)
	asserts.is_equal(bubble.index, 1, "advanced to next line")
	Utility.simulate_action("action_interact")
	yield(until_signal(get_tree(), "idle_frame", 0.5), YIELD)
	Utility.simulate_action("action_interact", false)
	asserts.is_true(bubble.label.percent_visible == 1, 
			"skipped second line to the end")
	
	bubble.queue_free()


func test_speech_bubble_autoskip():
	speech.lines = ["one", "two", "three", "four"]
	speech.duration = 0.1
	var bubble = speech.deliver()
	yield(until_signal(bubble, "ready", 0.5), YIELD)
	asserts.is_true(speaker.is_a_parent_of(bubble), "bubble started")
	yield(until_signal(bubble, "tree_exited", 5), YIELD)
	asserts.is_false(is_instance_valid(bubble), "bubble destroyed")
	
	if is_instance_valid(bubble):
		bubble.queue_free()


func post():
	speech.queue_free()
	speaker.queue_free()
