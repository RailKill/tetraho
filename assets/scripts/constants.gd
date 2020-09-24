class_name Constants
extends Node
# Contains global game constants.


# Collision layer bit values.
enum Layer {
	ENVIRONMENT = 1,
	FLOOR = 2,
	ACTOR = 4,
	BLOCK = 8,
}

enum Team { ORIGINAL, SUITS, MOBS }


# Grid settings.
const GRID_SIZE = 14
const GRID_DOUBLE = GRID_SIZE * 2
const GRID_HALF = GRID_SIZE / 2
const GRID_ONE_HALF = GRID_SIZE + GRID_HALF

# Adjacent cell offset positions in 8 directions.
const DIRECTIONALS = [
	Vector2.RIGHT,
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN + Vector2.LEFT * 2,
	Vector2.LEFT * 2,
	(Vector2.LEFT + Vector2.UP) * 2,
	Vector2.UP * 2,
	Vector2.UP * 2 + Vector2.RIGHT,
]

# Player settings.
const PLAYER_HP = 100
const PLAYER_MOVE_SPEED = 70

# Loot settings.
const HEART_HEAL = 20

# AI settings.
const AI_PATHING_COOLDOWN = 0.25

# Others.
const ABILITY_FAILURE_RECOVERY_TIME = 0.5
const BLOCK_HP = 30
const BULLET_DAMAGE = 10
const BULLET_LIFETIME = 3
const BULLET_SPEED = 350
const CHECKER_LIFETIME = 0.05
const DEAD_BLOCK_DAMAGE = 40
const FLAMETHROWER_DAMAGE = 20
const FLAMETHROWER_DURATION = 0.5
const TETROMINO_DAMAGE = 100
const TETROMINO_DECAY_TIME = 4
const TETROMINO_SUMMON_TIME = 0.5
