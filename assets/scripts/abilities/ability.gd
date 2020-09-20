class_name Ability
extends Node2D
# Reusable generic ability. Does not do anything by default. Must be a child
# of an Actor.


# Cooldown of this ability.
export(float) var cooldown = 3
# Duration of ability in seconds.
export(float) var duration = 0

export(AudioStream) var cast_audio
export(AudioStream) var complete_audio
export(AudioStream) var ready_audio

# Delay in seconds before ability can be used again.
var delay: float
# Countdown since active.
var countdown: float
# Checks if ability is being used.
var is_active: bool
# Checks if ability is on cooldown.
var is_on_cooldown: bool

var sound_cast = AudioStreamPlayer2D.new()
var sound_complete = AudioStreamPlayer2D.new()
var sound_ready = AudioStreamPlayer2D.new()

onready var caster: Actor = get_parent()


func _ready():
	sound_cast.stream = cast_audio
	sound_cast.bus = AudioServer.get_bus_name(1)
	add_child(sound_cast)
	sound_complete.stream = complete_audio
	sound_complete.bus = AudioServer.get_bus_name(1)
	add_child(sound_complete)
	sound_ready.stream = ready_audio
	sound_ready.bus = AudioServer.get_bus_name(1)
	add_child(sound_ready)
	reset()


func _physics_process(delta):
	if is_active:
		countdown -= delta
		if countdown <= 0:
			complete()
		
	if is_on_cooldown:
		delay -= delta
		if delay <= 0:
			reset()


# Cast the ability.
func cast():
	if not is_on_cooldown and not is_active:
		is_active = true
		caster.play_casting_animation(self)
		sound_cast.play()


# Complete the cast and start the cooldown timer.
func complete():
	is_active = false
	is_on_cooldown = true
	caster.play_casted_animation(self)
	sound_complete.play()
	update()


# Reset ability cooldown.
func reset():
	is_active = false
	is_on_cooldown = false
	delay = cooldown
	countdown = duration
	sound_ready.play()
	update()


func update():
	var hud = caster.get_hud()
	if hud:
		hud.update_ability(self)
