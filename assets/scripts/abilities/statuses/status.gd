class_name Status
extends Node2D
# Status effect or buff.


# Description of what this status effect does.
export(String) var description = ""
# Duration this effect lasts in seconds. If 0, lasts forever.
export(float, 0, 3600) var duration = 0
# Perform a tick every X seconds. If 0, tick does not happen.
export(float, 0, 3600) var interval = 0

# The node who gave/caused this status effect.
var caster: Node2D
# Timer which will destroy self.
var timer_lifetime = Timer.new()
# Timer which fires at every interval.
var timer_tick = Timer.new()


func _ready():
	if duration > 0:
		timer_lifetime.wait_time = duration
		timer_lifetime.autostart = true
		timer_lifetime.connect("timeout", self, "expire")
	timer_lifetime.one_shot = true
	timer_lifetime.process_mode = Timer.TIMER_PROCESS_PHYSICS
	add_child(timer_lifetime)
	
	if interval > 0:
		timer_tick.wait_time = interval
		timer_tick.autostart = true
		timer_tick.connect("timeout", self, "tick")
	timer_tick.process_mode = Timer.TIMER_PROCESS_PHYSICS
	add_child(timer_tick)


func _to_string():
	return name


# Executes when this effect expires.
func expire():
	queue_free()


# Perform tick effects. Does nothing by default.
func tick():
	pass
