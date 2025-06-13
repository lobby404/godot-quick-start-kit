##############################
#        Premade Asset       #
##############################
extends Panel

@export var focus: Button = null
@export var start_scene: PackedScene = null

var main: SceneController

func _ready():
	main = get_tree().get_first_node_in_group("scene_controller")
	main.connect("hiding_settings", _get_ui_focus)
	
	_get_ui_focus()

func _get_ui_focus():
	if focus:
		focus.grab_focus()

func _on_start_game_pressed():
	main.change_2d_scene("res://_Test/test.tscn")
	main.change_gui_scene("res://UserInterface/PauseMenu/Scenes/pause_menu.tscn")

func _on_settings_pressed():
	main.request_settings()

func _on_quit_pressed():
	get_tree().quit()
