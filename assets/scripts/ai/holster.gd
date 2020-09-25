class_name Holster
extends Behavior
# Behavior which hides or shows a weapon.


# The type of holstering behavior. If true, shows weapon. Otherwise, hide.
var show: bool
# Weapon to holster.
var weapon: Handgun


func _init(actor, gun, out=false).(actor):
	weapon = gun
	show = out


func execute(_delta) -> bool:
	weapon.visible = show
	return true
