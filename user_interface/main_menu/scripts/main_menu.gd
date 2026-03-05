extends Panel
## Premade Asset

@export var focus : Button

@export_group("Scenes")
@export var start_scene : String 
@export var pause_menu : String = Constants.DEFAULT_SCENES.pause_menu

var main: SceneController


func _ready():
	main = get_tree().get_first_node_in_group("scene_controller")
	main.connect("hiding_settings", _get_ui_focus)
	
	main.prepare_resource(start_scene)
	
	_get_ui_focus()


func _get_ui_focus():
	if focus:
		focus.grab_focus()


func _on_start_game_pressed():
	main.add_new_2d_scene(start_scene)
	main.swap_gui_scene(pause_menu, self.scene_file_path)


func _on_settings_pressed():
	main.request_settings()


func _on_quit_pressed():
	get_tree().quit()
