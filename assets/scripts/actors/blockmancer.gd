class_name Blockmancer
extends Enemy
# A type of enemy that can summon blocks. The blocks that a Blockmancer summon
# does not go away until solved.


# Called when the node enters the scene tree for the first time.
func _ready():
	behaviors.append(UseAbility.new(self, player, $Spawn))


func play_casting_animation(_ability):
	sprite.play()


func play_casted_animation(_ability):
	sprite.stop()
	sprite.set_frame(0)
