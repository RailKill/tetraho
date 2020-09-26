extends Node
# Configuration singleton to apply game settings.


const DEFAULT_FULLSCREEN = false
const DEFAULT_WIDTH = 1280
const DEFAULT_HEIGHT = 720
const DEFAULT_MASTER_VOLUME = 100
const DEFAULT_MUSIC_VOLUME = 60
const DEFAULT_SFX_VOLUME = 100

# File path to store game configuration.
const FILEPATH = "user://settings.cfg"


# On ready, load and apply game configuration.
func _ready():
	var config = retrieve()
	OS.window_size = Vector2(
			config.get_value("display", "width", DEFAULT_WIDTH),
			config.get_value("display", "height", DEFAULT_HEIGHT))
	OS.window_fullscreen = \
			config.get_value("display", "fullscreen", DEFAULT_FULLSCREEN)
	adjust_volume(0, config.get_value("sound", "master_volume", 
			DEFAULT_MASTER_VOLUME))
	adjust_volume(1, config.get_value("sound", "sfx_volume", 
			DEFAULT_SFX_VOLUME))
	adjust_volume(2, config.get_value("sound", "music_volume", 
			DEFAULT_MUSIC_VOLUME))


# Adjust volume of the given bus index according to the given value (0 to 100).
func adjust_volume(bus_index: int, value: float):
	AudioServer.set_bus_mute(bus_index, value == 0)
	AudioServer.set_bus_volume_db(bus_index, value / 2 - 50)


# Loads the configuration file. If error occurs, return defaults instead.
func retrieve():
	var config = ConfigFile.new()
	var error = config.load(FILEPATH)
	if error != OK:
		config = reset()
	return config


# Reset configuration to default.
func reset():
	var config = ConfigFile.new()
	
	# Default display settings.
	config.set_value("display", "fullscreen", DEFAULT_FULLSCREEN)
	config.set_value("display", "width", DEFAULT_WIDTH)
	config.set_value("display", "height", DEFAULT_HEIGHT)
	
	# Default sound settings.
	config.set_value("sound", "master_volume", DEFAULT_MASTER_VOLUME)
	config.set_value("sound", "music_volume", DEFAULT_MUSIC_VOLUME)
	config.set_value("sound", "sfx_volume", DEFAULT_SFX_VOLUME)

	config.save(FILEPATH)
	return config
