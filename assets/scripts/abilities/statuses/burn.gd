class_name Burn
extends Status
# Does damage on ready and on every tick.


export var damage = Constants.FLAMETHROWER_DAMAGE


func _ready():
	tick()


func tick():
	var parent = get_parent()
	if parent.has_method("oof"):
		parent.oof(damage, false, caster, "burned")
