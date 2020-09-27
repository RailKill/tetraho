class_name Ability
extends Node2D
# Reusable generic ability. Does not do anything by default. Must be a child
# of an Actor.


signal started_casting
signal finished_casting
signal cooldown_ready

# Cooldown of this ability.
export(float, 0.01, 3600) var cooldown = 3
# Duration of ability in seconds.
export(float, 0.01, 3600) var duration = 0.01

export(AudioStream) var cast_audio
export(AudioStream) var complete_audio
export(AudioStream) var ready_audio

# Checks if ability is being used.
var is_active: bool
# Checks if ability is on cooldown.
var is_on_cooldown: bool

var sound_cast = AudioStreamPlayer2D.new()
var sound_complete = AudioStreamPlayer2D.new()
var sound_ready = AudioStreamPlayer2D.new()
var timer_cooldown = Timer.new()
var timer_duration = Timer.new()

onready var caster: Node2D = get_parent()


func _ready():
	# Setup sounds.
	sound_cast.stream = cast_audio
	sound_cast.bus = AudioServer.get_bus_name(1)
	add_child(sound_cast)
	sound_complete.stream = complete_audio
	sound_complete.bus = AudioServer.get_bus_name(1)
	add_child(sound_complete)
	sound_ready.stream = ready_audio
	sound_ready.bus = AudioServer.get_bus_name(1)
	add_child(sound_ready)

	# Setup timers.
	timer_cooldown.one_shot = true
	timer_cooldown.process_mode = Timer.TIMER_PROCESS_PHYSICS
	timer_cooldown.connect("timeout", self, "reset")
	add_child(timer_cooldown)
	timer_duration.one_shot = true
	timer_duration.process_mode = Timer.TIMER_PROCESS_PHYSICS
	timer_duration.connect("timeout", self, "complete")
	add_child(timer_duration)
	reset()


# Cast the ability.
func cast():
	if not is_on_cooldown and not is_active:
		is_active = true
		timer_duration.start()
		caster.play_casting_animation(self)
		sound_cast.play()
		emit_signal("started_casting")


# Complete the cast and start the cooldown timer.
func complete():
	is_active = false
	is_on_cooldown = true
	timer_cooldown.start()
	caster.play_casted_animation(self)
	sound_complete.play()
	update()
	emit_signal("finished_casting")


# Reset ability cooldown.
func reset():
	is_active = false
	is_on_cooldown = false
	timer_cooldown.wait_time = cooldown
	timer_duration.wait_time = duration
	sound_ready.play()
	update()
	emit_signal("cooldown_ready")


func update():
	if caster.has_method("get_hud") and caster.get_hud():
		caster.get_hud().update_ability(self)
