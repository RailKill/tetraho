class_name LockBlock
extends TetrominoBlock
# Block that needs to be solved in order to be destroyed.


# Lock blocks are usually placed into the world by design. Enable it on load.
func _ready():
	is_invulnerable = true
	enable()
