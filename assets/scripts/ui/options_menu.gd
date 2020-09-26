extends Panel
# Options menu where display, sound and gameplay configurations can be changed.


onready var fullscreen_checkbox = $GridContainer/CheckControl/CheckBox
onready var width_edit = $GridContainer/WindowSizeControl/LineEditWidth
onready var height_edit = $GridContainer/WindowSizeControl/LineEditHeight

onready var master_slider = $GridContainer/SliderMasterVolume/Slider
onready var music_slider = $GridContainer/SliderMusicVolume/Slider
onready var sfx_slider = $GridContainer/SliderSFXVolume/Slider


func _ready():
	$VBoxContainer/ButtonClose.grab_focus()
	# Load and apply configurations.
	apply(Configuration.retrieve())


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		save_and_exit()


func _on_button_focus_entered():
	$Focus.visible = true


func _on_button_focus_exited():
	$Focus.visible = false


func _on_fullscreen_focus_entered():
	fullscreen_checkbox.modulate = Color.aqua


func _on_fullscreen_focus_exited():
	fullscreen_checkbox.modulate = Color.white


func _on_fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	$GridContainer/LabelWindowSize.modulate = \
			Color.dimgray if button_pressed else Color.white
	width_edit.editable = !button_pressed
	height_edit.editable = !button_pressed


func _on_master_volume_changed(value):
	Configuration.adjust_volume(0, value)


func _on_music_volume_changed(value):
	Configuration.adjust_volume(2, value)


func _on_reset_pressed():
	apply(Configuration.reset())


func _on_sfx_volume_changed(value):
	Configuration.adjust_volume(1, value)


# Apply the given configuration to the user interface.
func apply(config: ConfigFile):
	# Update display settings.
	fullscreen_checkbox.pressed = config.get_value("display", "fullscreen", 
			Configuration.DEFAULT_FULLSCREEN)
	width_edit.text = str(config.get_value("display", "width", 
			Configuration.DEFAULT_WIDTH))
	height_edit.text = str(config.get_value("display", "height", 
			Configuration.DEFAULT_HEIGHT))
	
	# Update sound settings.
	master_slider.value = config.get_value("sound", "master_volume", 
			Configuration.DEFAULT_MASTER_VOLUME)
	music_slider.value = config.get_value("sound", "music_volume", 
			Configuration.DEFAULT_MUSIC_VOLUME)
	sfx_slider.value = config.get_value("sound", "sfx_volume", 
			Configuration.DEFAULT_SFX_VOLUME)


# Saves the configuration based on user input, then close this panel.
func save_and_exit():
	var config = ConfigFile.new()
	var width = int(width_edit.text) \
			if width_edit.text.is_valid_integer() else int(OS.window_size.x)
	var height = int(height_edit.text) \
			if height_edit.text.is_valid_integer() else int(OS.window_size.y)
	OS.window_size = Vector2(width, height)
	
	# Get display settings.
	config.set_value("display", "fullscreen", fullscreen_checkbox.pressed)
	config.set_value("display", "width", width)
	config.set_value("display", "height", height)
	
	# Get sound settings.
	config.set_value("sound", "master_volume", master_slider.value)
	config.set_value("sound", "music_volume", music_slider.value)
	config.set_value("sound", "sfx_volume", sfx_slider.value)

	config.save(Configuration.FILEPATH)
	queue_free()
