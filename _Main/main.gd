##############################
#        Premade Asset       #
##############################
class_name SceneController
extends Node

signal show_settings
signal hiding_settings

@export_category("Scene Management")
@export var world_3d: Node3D
@export var world_2d: Node2D
@export var gui: Control

@export_category("Utility")
@export var main_menu: PackedScene

var current_3d_scene: Node
var current_2d_scene: Node
var current_gui_scene: Node

func _ready():
	
	if world_3d.get_child_count() > 0:
		var first_world_3d = world_3d.get_child(0)
		if is_instance_valid(first_world_3d):
			if world_3d.get_child_count() > 1:
				printerr("Multiple GUI scenes found. Using the first child as current GUI scene.")
			current_3d_scene = first_world_3d
	
	if gui.get_child_count() > 0:
		var first_gui = gui.get_child(0)
		if is_instance_valid(first_gui):
			if gui.get_child_count() > 1:
				printerr("Multiple GUI scenes found. Using the first child as current GUI scene.")
			current_gui_scene = first_gui
	
	if world_2d.get_child_count() > 0:
		var first_world_2d = world_2d.get_child(0)
		if is_instance_valid(first_world_2d):
			if world_2d.get_child_count() > 1:
				printerr("Multiple GUI scenes found. Using the first child as current GUI scene.")
			current_2d_scene = first_world_2d
	

func request_settings():
	show_settings.emit()

func closing_settings():
	hiding_settings.emit()

func request_pause():
	get_tree().paused = true

func request_unpause():
	get_tree().paused = false

func return_to_main_menu(use_default: bool = true):
	if use_default:
		change_gui_scene(main_menu.resource_path)
		if current_2d_scene:
			current_2d_scene.queue_free()
		if current_3d_scene:
			current_3d_scene.queue_free()
	else:
		# Customize this block for your game's main menu behavior
		return
	
	if get_tree().paused:
		get_tree().paused = false

func change_3d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_3d_scene:
		if delete:
			current_3d_scene.queue_free()
		elif keep_running:
			current_3d_scene.hide()
		else:
			world_3d.remove_child(current_3d_scene)
	var new = load(new_scene).instantiate()
	world_3d.add_child(new)
	current_3d_scene = new

func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_2d_scene:
		if delete:
			current_2d_scene.queue_free()
		elif keep_running:
			current_2d_scene.hide()
		else:
			world_2d.remove_child(current_2d_scene)
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new

func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene:
		if delete:
			current_gui_scene.queue_free()
			print("freeing ", current_gui_scene.name)
		elif keep_running:
			current_gui_scene.hide()
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
