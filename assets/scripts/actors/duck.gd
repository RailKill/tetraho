class_name Duck
extends Enemy
# Duck chases the player at slow speeds but will attack when close enough.


onready var animation = $AnimationPlayer
onready var exclamation = $ExclamationPopup


func _ready():
	behaviors.append(Follow.new(
			self, player, get_parent().get_node("Navigation2D")))
	behaviors.append(UseAbility.new(
			self, player, $Spawn, Constants.GRID_SIZE + 2))


# If the given collider is a DuckHouse, kill both.
func check_collision(collision: KinematicCollision2D):
	if collision:
		var collider = collision.collider
		if collider is DuckHouse:
			collider.is_invulnerable = false
			collider.oof(collider.max_hp)
			oof(max_hp)


func play_casting_animation(_ability):
	animation.play("Attack")


func play_casted_animation(_ability):
	exclamation.visible = false
