class_name Behavior


# The actor who will execute this behavior.
var executor: Actor


func _init(actor: Actor):
	executor = actor


# Processes the behavior. Behaviors are executed every physics frame by their
# executor. Actors go through a list of behaviors, and returning false here
# prevents continuation and will stop processing after this behavior is done.
func execute(_delta: float) -> bool:
	return false
