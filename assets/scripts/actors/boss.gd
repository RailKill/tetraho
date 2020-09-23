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
func add_child_unique(node):
	if not node is Burn:
		.add_child_unique(node)
	else:
		node.queue_free()


func oof(damage, bypass_lock=false, attacker=null, message=""):
	.oof(damage, bypass_lock, attacker, message)
	
	if is_dead():
		var loot = crown.instance()
		get_parent().add_child(loot)
		loot.global_position = global_position
	else:
		teleport()


func teleport(point=null):
	if point == null:
		randomize()
		point = teleport_points[randi() % teleport_points.size()]

	var effect = telesprite.instance()
	effect.global_position = point
	get_parent().add_child(effect)
	global_position = point

