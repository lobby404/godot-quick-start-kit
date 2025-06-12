##############################
#        Premade Asset       #
##############################
@tool
extends Node

signal muted_audio
signal resetting_settings

const SETTINGS_FILE_PATH = "user://settings.ini"

@export var update_settings_config: bool = false

var config:= ConfigFile.new()

func _ready():
	if OS.has_feature("editor_hint"):
		return
	
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		reset_to_default()
	elif config.load(SETTINGS_FILE_PATH) != OK:
		printerr("Failed to load config file from file path")
	
	if load_video_settings().fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	DisplayServer.window_set_current_screen(load_video_settings().current_screen)
	
	if AudioServer.is_bus_mute(0):
		save_audio_setting("mute", true)
	
	update_missing_settings()

func _process(_delta: float) -> void:
	if update_settings_config && OS.has_feature("editor_hint"):
		update_missing_settings()
		update_settings_config = false

func toggle_fullscreen(state: bool):
	if state:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func toggle_mute(state: bool):
	AudioServer.set_bus_mute(0, state)
	muted_audio.emit()

func set_screen(screen: int):
	DisplayServer.window_set_current_screen(screen)

func get_default_settings() -> ConfigFile:
	var default_settings: ConfigFile = ConfigFile.new()
	
	default_settings.set_value("video", "fullscreen", true)
	default_settings.set_value("video", "current_screen", 0)
	
	default_settings.set_value("audio", "master_volume", 1.0)
	default_settings.set_value("audio", "music_volume", 1.0)
	default_settings.set_value("audio", "sfx_volume", 1.0)
	default_settings.set_value("audio", "mute", false)
	
	return default_settings

func update_missing_settings():
	if config.load(SETTINGS_FILE_PATH) != OK:
		printerr("Error loading config, supplimenting with new ConfigFile")
		config = ConfigFile.new()
	
	var defaults: ConfigFile = get_default_settings()
	
	if config.get_sections() != defaults.get_sections():
		for section in defaults.get_sections():
			for key in defaults.get_section_keys(section):
				if config.get_value(section, key) == null:
					var value = defaults.get_value(section, key)
					config.set_value(section, key, value)
		
		for section in config.get_sections():
			if !defaults.has_section(section):
				config.erase_section(section)
	else:
		return
	
	if config.save(SETTINGS_FILE_PATH) == OK:
		print("Settings Updated and Saved Successfuly")
	else:
		printerr("Settings Update and Saving Failed")

func reset_to_default():
	config = get_default_settings()
	config.save(SETTINGS_FILE_PATH)
	resetting_settings.emit()

func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings():
	var video_settings: Dictionary = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings: Dictionary = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings
