class_name Utility
# Helper functions for automated tests.


# Simulates an action being pressed.
static func simulate_action(action, pressed=true):
	var a = InputEventAction.new()
	a.action = action
	a.pressed = pressed
	Input.parse_input_event(a)
