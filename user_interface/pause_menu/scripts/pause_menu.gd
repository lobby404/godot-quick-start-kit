extends CanvasLayer
## Premade Asset

@export var focus : Control

var main : SceneController
var settings_opened := false


func _ready():
	main = get_tree().get_first_node_in_group("scene_controller")
	main.connect("hiding_settings", _get_ui_focus)
	
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_released("Pause") && !settings_opened:
		if get_tree().paused:
			unpause()
		else:
			pause()


func unpause():
	hide()
	main.request_unpause()


func pause():
	show()
	_get_ui_focus()
	main.request_pause()


func _get_ui_focus():
	if focus:
		focus.grab_focus()
	if settings_opened:
		settings_opened = false


func _on_resume_pressed():
	unpause()


func _on_settings_pressed():
	settings_opened = true
	main.request_settings()


func _on_main_menu_pressed():
	main.return_to_main_menu()


func _on_quit_pressed():
	get_tree().quit()


func _on_reset_button_up():
	var active_game := main.get_active_game_world()
	var current_scene : String
	if active_game == main.world_2d:
		current_scene = main.current_2d_scenes[0].scene_file_path
		main.reload_2d_scene(current_scene)
	if active_game == main.world_3d:
		current_scene = main.current_3d_scenes[0].scene_file_path
		main.reload_3d_scene(current_scene)
	
	unpause()
