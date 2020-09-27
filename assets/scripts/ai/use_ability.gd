class_name UseAbility
extends Target
# AI Behavior which uses a given ability on a target.


# Ability to use.
var ability: Ability
# Range of the ability.
var reach: float


func _init(actor, goal, skill, length=0, extent=0).(actor, goal, extent):
	ability = skill
	reach = length


func execute() -> bool:
	if is_close_enough() and is_instance_valid(target):
		if ability.has_method("set_point"):
			ability.set_point(executor.global_position + \
					to_target_vector().normalized() * reach \
					if reach else target.global_position)
		ability.cast()
		return false
	return true
