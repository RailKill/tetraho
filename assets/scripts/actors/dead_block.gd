class_name DeadBlock
extends TetrominoBlock
# Dead blocks do not trap actors, they damage and push actors away.


func trap(actor):
	actor.unstuck()
	actor.oof(Constants.DEAD_BLOCK_DAMAGE)
