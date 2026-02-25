extends CanvasLayer
## Premade Asset

@export var centre_window_on_change : bool = true

@export_category("References")
@export var focus : Control = null
@export var fullscreen_checkbox : CheckBox
@export var current_screen_option : OptionButton
@export var mute_checkbox : CheckBox
@export var audio_output_option : OptionButton

var main: SceneController


func _ready():
	main = get_tree().get_first_node_in_group("scene_controller")
	
	var screen_count: int = DisplayServer.get_screen_count()
	if screen_count > 1:
		_populate_screen_option(screen_count)
	else:
		current_screen_option.get_parent().hide()
	
	var output_count: int = AudioServer.get_output_device_list().size()
	if output_count > 1:
		_populate_audio_output_option(output_count)
	else:
		audio_output_option.hide()
	
	hide()
	_update_visuals()
	
	main.connect("show_settings", _on_show)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("Pause") or event.is_action_released("ui_cancel"):
		_on_hide()


func _populate_screen_option(screen_count: int):
	for screen in range(screen_count):
		current_screen_option.add_item(" Monitor %d " % (screen + 1), screen)


func _populate_audio_output_option(output_count: int):
	for device in range(output_count):
		audio_output_option.add_item(AudioServer.get_output_device_list()[device])


func _update_visuals():
	var video_settings = ConfigManager.load_video_settings()
	var audio_settings = ConfigManager.load_audio_settings()
	
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = video_settings.fullscreen
	else:
		printerr("Fullscreen Checkbox not defined in: ", get_path())
	
	if current_screen_option:
		var selected_screen = video_settings.current_screen
		if current_screen_option.selected != selected_screen:
			current_screen_option.selected = selected_screen
	
	if audio_output_option:
		var ouput_device_index = audio_settings.audio_output
		if audio_output_option.selected != ouput_device_index:
			audio_output_option.selected = ouput_device_index
			_on_audio_ouput_selected(ouput_device_index)
		
	if mute_checkbox:
		mute_checkbox.button_pressed = audio_settings.mute
		if mute_checkbox.button_pressed:
			_on_mute_check_box_toggled(true)
	else:
		printerr("Mute Checkbox not defined in: ", get_path())


func _on_show():
	focus.grab_focus()
	show()


func _on_hide():
	hide()
	main.closing_settings()


func _centre_window(screen: int):
	if (!centre_window_on_change 
		or DisplayServer.window_get_mode() 
		!= DisplayServer.WINDOW_MODE_WINDOWED):
		return
	
	var screen_rect : Rect2 = DisplayServer.screen_get_usable_rect(screen)
	var window_size : Vector2 = DisplayServer.window_get_size()
	
	var screen_centre : Vector2 = screen_rect.position + (screen_rect.size - window_size) / 2.0
	var screen_centre_int := Vector2i(roundi(screen_centre.x), roundi(screen_centre.y))
	DisplayServer.window_set_position(screen_centre_int)


func _on_fullscreen_check_box_toggled(toggled_on):
	var screen = DisplayServer.window_get_current_screen()
	ConfigManager.save_video_setting("fullscreen", toggled_on)
	ConfigManager.toggle_fullscreen(toggled_on)
	_centre_window(screen)


func _on_mute_check_box_toggled(toggled_on):
	ConfigManager.save_audio_setting("mute", toggled_on)
	ConfigManager.toggle_mute(toggled_on)


func _on_back_pressed():
	_on_hide()


func _on_reset_to_default_pressed():
	ConfigManager.reset_to_default()
	_update_visuals()


func _on_current_screen_options_item_selected(index: int) -> void:
	ConfigManager.save_video_setting("current_scene", index)
	ConfigManager.set_screen(index)
	_centre_window(index)


func _on_audio_ouput_selected(index: int) -> void:
	ConfigManager.save_audio_setting("audio_output", index)
	ConfigManager.set_audio_output(index)
