class_name Gunner
extends Enemy


# Handgun node.
onready var handgun = $Handgun
# Shoot ability node.
onready var shoot = $Shoot


func _ready():
	shoot.gun = handgun
	behaviors.append(Aim.new(self, player, handgun))
	behaviors.append(UseAbility.new(self, player, shoot))
