extends Panel
## Premade Asset

@export var focus : Button

@export_group("Scenes")
@export var start_scene : String 
@export var pause_menu : String = Constants.DEFAULT_SCENES.pause_menu

var main: SceneController

var main_menu_path = Constants.DEFAULT_SCENES.main_menu

func _ready():
	main = get_tree().get_first_node_in_group("scene_controller")
	main.connect("hiding_settings", _get_ui_focus)
	
	main.prepare_resource(start_scene)
	
	_get_ui_focus()


func _get_ui_focus():
	if focus:
		focus.grab_focus()


func _on_start_game_pressed():
	main.add_new_scene(start_scene, main.world_2d, main.active_2d_scenes)
	main.swap_scene(pause_menu, self.scene_file_path, main.gui, main.active_gui_scenes)


func _on_settings_pressed():
	main.request_settings()


func _on_quit_pressed():
	get_tree().quit()
