class_name Boss
extends Gunner


onready var crown = preload("res://assets/scenes/loot/crown.tscn")
onready var telesprite = preload("res://assets/scenes/effects/teleport.tscn")
var teleport_points: Array
var is_casting = false


func _ready():
	var melee_range = Constants.GRID_SIZE * 7
	behaviors.push_front(UseAbility.new(
			self, player, $Spawn, Constants.GRID_SIZE + 2, melee_range))
	behaviors.push_front(Follow.new(
			self, player, get_parent().get_node("Navigation2D"), melee_range))


# Immune to Burn status effect.
func add_status(effect: Status):
	if not effect is Burn:
		.add_status(effect)


func oof(damage, bypass_lock=false, attacker=null, message=""):
	.oof(damage, bypass_lock, attacker, message)
	
	if is_dead():
		var loot = crown.instance()
		get_parent().add_child(loot)
		loot.global_position = global_position
	else:
		teleport()


func teleport(index=-1):
	if teleport_points:
		var selected
		if index != -1:
			selected = index
		else:
			randomize()
			selected = randi() % teleport_points.size()
		
		telesprite.instance()
		telesprite.global_position = global_position
		get_parent().add_child(telesprite)
		global_position = teleport_points[selected]
