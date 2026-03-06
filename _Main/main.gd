class_name SceneController ## This is a level loader, used to handle heavy Scenes
extends Node
## Premade Asset

signal show_settings
signal hiding_settings
signal scene_resource_ready(path : String)

@export_category("Scene Management")
@export var world_3d : Node3D
@export var world_2d : Node2D
@export var gui : Control

@export_category("Utility")
@export var main_menu : String = Constants.DEFAULT_SCENES.main_menu

var scene_cache : Dictionary[String, PackedScene] = {}
var loading_scene : Dictionary[String, bool] = {}

var active_3d_scenes : Dictionary[String, Node] = {}
var active_2d_scenes : Dictionary[String, Node] = {}
var active_gui_scenes : Dictionary[String, Node] = {}


func _ready():
	prepare_resource(main_menu)
	
	register_existing(world_3d, active_3d_scenes)
	register_existing(world_2d, active_2d_scenes)
	register_existing(gui, active_gui_scenes)
	
	for scenes in Constants.DEFAULT_SCENES.values():
		prepare_resource(scenes)

func _process(_delta):
	if !loading_scene.is_empty():
		
		for path in loading_scene.keys():
			var status = ResourceLoader.load_threaded_get_status(path)
			
			if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				var scene = ResourceLoader.load_threaded_get(path)
				
				scene_cache[path] = scene
				loading_scene.erase(path)
				scene_resource_ready.emit(path)

func request_settings():
	show_settings.emit()


func closing_settings():
	hiding_settings.emit()


func request_pause():
	get_tree().paused = true


func request_unpause():
	get_tree().paused = false


func prepare_resource(resource_path: String):
	if scene_cache.has(resource_path):
		return
	
	if loading_scene.has(resource_path):
		return
	
	ResourceLoader.load_threaded_request(resource_path)
	loading_scene[resource_path] = true


func get_cached_scene(resource_path : String) -> PackedScene:
	if scene_cache.has(resource_path):
		return scene_cache[resource_path]
		
	if !loading_scene.has(resource_path):
		prepare_resource(resource_path)
		
	return null


func register_existing(parent : Node, registry : Dictionary) -> void:
	for child in parent.get_children():
		
		if !registry.has(child) and child.scene_file_path != "":
			registry[child.scene_file_path] = child


func get_active_game_world() -> Node:
	if !world_2d.get_children().is_empty() and world_3d.get_children().is_empty():
		return world_2d
		
	elif !world_3d.get_children().is_empty() and world_2d.get_children().is_empty():
		return world_3d
		
	else: return null


func return_to_main_menu(
	main_menu_path : String = main_menu, 
	delete_all_gui_scenes := true,
	delete_3d_world_scenes := true, 
	delete_2d_world_scenes := true):
	if delete_all_gui_scenes:
		clear_registry(active_gui_scenes)
	#
	if delete_3d_world_scenes:
		clear_registry(active_3d_scenes)
	#
	if delete_2d_world_scenes:
		clear_registry(active_2d_scenes)
	
	add_new_scene(main_menu_path, gui, active_gui_scenes)
	
	if get_tree().paused:
		request_unpause()


func add_new_scene(path : String, parent : Node, registry : Dictionary) -> void:
	var packed_scene : PackedScene = get_cached_scene(path)
	if packed_scene is not PackedScene:
		push_error(path, " did not return a packed scene")
		return
	var instance = packed_scene.instantiate()
	registry[path] = instance
	parent.add_child(instance)


func clear_registry(registry : Dictionary):
	for scene in registry.values():
		scene.queue_free()
	registry.clear()


func remove_scene(scene_path : String, registry : Dictionary):
	if !registry.has(scene_path):
		print(scene_path, " does not exist in ", registry)
		return
	registry[scene_path].queue_free()
	registry.erase(scene_path)


func reload_scene(scene_path : String, parent : Node, registry : Dictionary):
	if !registry[scene_path]:
		return
	
	remove_scene(scene_path, registry)
	add_new_scene(scene_path, parent, registry)


func swap_scene(new : String, old: String, parent : Node,  registry : Dictionary):
	remove_scene(old, registry)
	add_new_scene(new, parent, registry)
