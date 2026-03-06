extends CanvasLayer
## Premade Asset

@export var focus : Control
@export var scene_to_reset : String = Constants.DEFAULT_SCENES.test

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
	main.reload_scene(scene_to_reset, main.world_2d, main.active_2d_scenes)
	
	unpause()
