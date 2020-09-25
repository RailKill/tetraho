class_name AreaChecker
extends Area2D
# Checks a small area, around the size of Constants.GRID_SIZE for any colliding
# areas or bodies. Automatically expires and emits signal based on lifetime.


signal lifetime_expired(collided)

export(float) var lifetime = Constants.CHECKER_LIFETIME
export(bool) var is_snapped = false

var collided: Node2D
var is_expiring = false

onready var collision_shape = $CollisionShape2D


func _ready():
	reposition()
	# warning-ignore:return_value_discarded
	connect("area_entered", self, "_on_collide")
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_collide")


func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0 and not is_expiring:
		is_expiring = true
		emit_signal("lifetime_expired", collided)
		queue_free()


func _on_collide(target):
	collided = target


# Centers the area correctly based on its collision shape and grid snapping.
func reposition():
	if is_snapped:
		global_position = Vector2(
				stepify(global_position.x, Constants.GRID_SIZE), 
				stepify(global_position.y, Constants.GRID_SIZE))
	else:
		global_position -= collision_shape.position
