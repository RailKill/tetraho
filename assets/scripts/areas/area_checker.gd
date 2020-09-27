class_name AreaChecker
extends Area2D
# Checks a small area, around the size of Constants.GRID_SIZE for any colliding
# areas or bodies. Automatically expires and emits signal based on lifetime.


signal lifetime_expired(collided)

# If true, the checker will automatically snap to grid on ready.
export(bool) var is_snapped = false

# The last colliding area or body.
var collided: Node2D

onready var collision_shape = $CollisionShape2D
onready var lifetime = $Lifetime


func _ready():
	reposition()


func _on_collide(target):
	collided = target


func _on_lifetime_expired():
	emit_signal("lifetime_expired", collided)
	queue_free()


# Centers the area correctly based on its collision shape and grid snapping.
func reposition():
	if is_snapped:
		global_position = Vector2(
				stepify(global_position.x, Constants.GRID_SIZE), 
				stepify(global_position.y, Constants.GRID_SIZE))
	else:
		global_position -= collision_shape.position
