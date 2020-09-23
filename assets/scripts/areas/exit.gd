class_name Exit
extends AreaDialog
# An area that triggers a dialog if given conditionals are not fulfilled.
# If all conditions are true, change scene to next_scene.


# Change to this scene when entered.
export(PackedScene) var next_scene
# Evaluated GDScript conditions that must be fulfilled to proceed to next scene.
export(PoolStringArray) var conditionals


func _on_body_entered(body):
	# TODO: Think of a better way to do this instead of evaluating script.
	for condition in conditionals:
		var script = GDScript.new()
		script.set_source_code("func evaluate(body):\n\treturn " + condition)
		script.reload()
		var obj = Reference.new()
		obj.set_script(script)
		if not obj.evaluate(body):
			._on_body_entered(body)
			return
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene(next_scene.resource_path)
