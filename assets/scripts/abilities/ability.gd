class_name Ability
extends Node
# Reusable generic ability. Abstract class, does not do anything.


# Cooldown of this ability.
export var cooldown : float
# Delay in seconds before ability can be used again.
var delay : float
# Duration of ability in seconds.
export var duration : float
# Countdown since active.
var countdown : float
# Checks if ability is being used.
var is_active : bool
# Checks if ability is on cooldown.
var is_on_cooldown : bool
# Owner of this ability.
onready var caster = get_parent()


func _ready():
	reset()


func _physics_process(delta):
	if is_on_cooldown:
		delay -= delta
		if delay <= 0:
			reset()


# Cast the ability.
func cast():
	if not is_on_cooldown:
		is_active = true


# Complete the cast and start the cooldown timer.
func complete():
	is_active = false
	is_on_cooldown = true


# Reset ability cooldown.
func reset():
	is_active = false
	is_on_cooldown = false
	delay = cooldown
	countdown = duration
