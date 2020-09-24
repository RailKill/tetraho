class_name Holster
extends Behavior
# Behavior which hides or shows a weapon.


var show: bool
var weapon: Handgun


func _init(actor, gun, out=false).(actor):
	weapon = gun
	show = out


func execute(_delta) -> bool:
	weapon.visible = show
	return true
