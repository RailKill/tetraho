class_name DeadBlock
extends TetrominoBlock
# Dead blocks do not trap actors, they push them away.


func trap(actor):
	actor.unstuck()
	actor.oof(Constants.DEAD_BLOCK_DAMAGE)
