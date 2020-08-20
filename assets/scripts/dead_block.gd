class_name DeadBlock
extends Tetromino
# Dead blocks are a kind of tetromino that once summoned, will stay in the game
# forever unless solved.


func _ready():
	can_decay = false
	summon_piece()
