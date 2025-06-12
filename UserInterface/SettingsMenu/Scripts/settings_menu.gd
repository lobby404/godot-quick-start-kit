##############################
#        Premade Asset       #
##############################
extends CanvasLayer

@export var centre_window_on_change: bool = true

@export_category("References")
@export var focus: Control = null
@export var fullscreen_checkbox: CheckBox
@export var current_screen_option: OptionButton
@export var mute_checkbox: CheckBox

var main: SceneController

func _ready():
	main = get_tree().get_first_node_in_group("scene_controller")
	
	if DisplayServer.get_screen_count() > 1:
		_populate_screen_option()
	else:
		pass
	
	hide()
	_update_visuals()
	
	Global.connect("resetting_settings", _update_visuals)
	main.connect("show_settings", _on_show)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("Pause"):
		_on_hide()

func _populate_screen_option():
	var screen_count: int = DisplayServer.get_screen_count()
	for screen in range(screen_count):
		current_screen_option.add_item(" Monitor %d " % (screen + 1), screen)

func _update_visuals():
	var video_settings = Global.load_video_settings()
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = video_settings.fullscreen
		if fullscreen_checkbox.button_pressed:
			_on_fullscreen_check_box_toggled(true)
	else:
		printerr("Fullscreen Checkbox not defined in: ", get_path())
	
	if current_screen_option:
		var selected_screen = video_settings.current_screen
		if current_screen_option.selected != selected_screen:
			_on_current_screen_options_item_selected(selected_screen)
			current_screen_option.selected = selected_screen
	
	var audio_settings = Global.load_audio_settings()
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
	if !centre_window_on_change or DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		return
	
	var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen)
	var window_size: Vector2i = DisplayServer.window_get_size()
	
	var screen_centre: Vector2i = screen_rect.position + (screen_rect.size - window_size) / 2
	DisplayServer.window_set_position(screen_centre)

func _on_fullscreen_check_box_toggled(toggled_on):
	var screen = DisplayServer.window_get_current_screen()
	Global.save_video_setting("fullscreen", toggled_on)
	Global.toggle_fullscreen(toggled_on)
	_centre_window(screen)

func _on_mute_check_box_toggled(toggled_on):
	Global.save_audio_setting("mute", toggled_on)
	Global.toggle_mute(toggled_on)

func _on_back_pressed():
	_on_hide()

func _on_reset_to_default_pressed():
	Global.reset_to_default()
	_update_visuals()

func _on_current_screen_options_item_selected(index: int) -> void:
	Global.save_video_setting("current_scene", index)
	Global.set_screen(index)
	_centre_window(index)
