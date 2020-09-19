class_name Status
extends Node2D
# Status effect or buff.


# Description of what this status effect does.
export(String) var description = ""
# If true, this status effect will never wear off.
export(bool) var lasts_forever = false
# Duration this effect lasts in seconds.
export(float, 0, 3600) var duration = 1
# Perform a tick every X seconds. If 0, tick does not happen.
export(float, 0, 3600) var interval = 0

var caster: Actor
var elapsed_time_since_tick = 0
var is_expiring = false


func _physics_process(delta):
	# Process tick effects.
	if interval > 0:
		elapsed_time_since_tick += delta
		if elapsed_time_since_tick >= interval:
			tick()
			elapsed_time_since_tick = 0
	
	# Check lifetime.
	if not lasts_forever:
		duration -= delta
		if duration <= 0 and not is_expiring:
			is_expiring = true
			expire()


func _to_string():
	return name


# Executes when this effect expires.
func expire():
	queue_free()


# Perform tick effects. Does nothing by default.
func tick():
	pass
