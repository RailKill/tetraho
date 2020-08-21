class_name Constants
extends Node
# Contains global game constants.


# Grid settings.
const GRID_SIZE = 14
const GRID_DOUBLE = GRID_SIZE * 2
const GRID_HALF = GRID_SIZE / 2
const GRID_ONE_HALF = GRID_SIZE + GRID_HALF


# Adjacent cell offset positions in 8 directions.
const DIRECTIONALS = [
	Vector2.RIGHT * GRID_SIZE,
	(Vector2.RIGHT + Vector2.DOWN) * GRID_SIZE,
	Vector2.DOWN * GRID_SIZE,
	(Vector2.DOWN + Vector2.LEFT)  * GRID_SIZE,
	Vector2.LEFT * GRID_SIZE,
	(Vector2.LEFT + Vector2.UP) * GRID_SIZE,
	Vector2.UP * GRID_SIZE,
	(Vector2.UP + Vector2.RIGHT) * GRID_SIZE
]

# Collision layer bit values.
enum Layer {
	ENVIRONMENT = 1,
	FLOOR = 2,
	ACTOR = 4,
	BLOCK = 8
}

# Player settings.
const PLAYER_HP = 100
const PLAYER_MOVE_SPEED = 1

# Loot settings.
const HEART_HEAL = 20

# AI settings.
const AI_PATHING_COOLDOWN = 0.25
const BLOCKMANCER_HP = 10
const BLOCKMANCER_MOVE_SPEED = 2
const BOSS_HP = 500
const BOSS_MOVE_SPEED = 2
const DUCK_HP = 20
const DUCK_MOVE_SPEED = 0.5
const GUNNER_HP = 20
const GUNNER_MOVE_SPEED = 1

# Others.
const BLOCK_HP = 30
const BULLET_DAMAGE = 10
const BULLET_SPEED = 5
const BULLET_LIFETIME = 3
const DEAD_BLOCK_DAMAGE = 50
const FLAMETHROWER_DAMAGE = 20
