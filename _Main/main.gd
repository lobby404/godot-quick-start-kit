class_name SceneController
extends Node
## Premade Asset

signal show_settings
signal hiding_settings

@export_category("Scene Management")
@export var world_3d : Node3D
@export var world_2d : Node2D
@export var gui : Control

@export_category("Utility")
@export var main_menu : String = Constants.DEFAULT_SCENES.main_menu

var current_3d_scenes : Array[Node]
var current_2d_scenes : Array[Node]
var current_gui_scenes : Array[Node]


func _ready():
	prepare_resource(main_menu)
	
	if world_3d.get_child_count() > 0:
		for child in world_3d.get_children():
			if is_instance_valid(child):
				current_3d_scenes.append(child)
	
	if world_2d.get_child_count() > 0:
		for child in world_2d.get_children():
			if is_instance_valid(child):
				current_2d_scenes.append(child)
	
	if gui.get_child_count() > 0:
		for child in gui.get_children():
			if is_instance_valid(child):
				current_gui_scenes.append(child)


func request_settings():
	show_settings.emit()


func closing_settings():
	hiding_settings.emit()


func request_pause():
	get_tree().paused = true


func request_unpause():
	get_tree().paused = false


func prepare_resource(resource_path: String):
	ResourceLoader.load_threaded_request(resource_path)


func get_cached_scene(resource_path : String) -> Resource:
	var new_scene
	if ResourceLoader.has_cached(resource_path):
		new_scene = ResourceLoader.load_threaded_get(resource_path)
		return new_scene
	else:
		return null


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
						delete_2d_world_scenes := true,
						):
	if delete_all_gui_scenes:
		for scene in current_gui_scenes:
			scene.queue_free()
		current_gui_scenes.clear()
	
	if delete_3d_world_scenes:
		for scene in current_3d_scenes:
			scene.queue_free()
		current_3d_scenes.clear()
	
	if delete_2d_world_scenes:
		for scene in current_2d_scenes:
			scene.queue_free()
		current_2d_scenes.clear()
	
	add_new_gui_scene(main_menu_path)
	
	if get_tree().paused:
		request_unpause()


func add_new_3d_scene(new_scene_path : String) -> void:
	var new_scene = get_cached_scene(new_scene_path)
	if !new_scene:
		new_scene = load(new_scene_path)
	
	var instance_scene = new_scene.instantiate()
	
	current_3d_scenes.append(instance_scene)
	world_3d.add_child(instance_scene)


func add_new_2d_scene(new_scene_path : String) -> void:
	var new_scene = get_cached_scene(new_scene_path)
	if !new_scene:
		new_scene = load(new_scene_path)
	
	var instance_scene = new_scene.instantiate()
	
	current_2d_scenes.append(instance_scene)
	world_2d.add_child(instance_scene)


func add_new_gui_scene(new_scene_path : String) -> void:
	var new_scene = get_cached_scene(new_scene_path)
	if !new_scene:
		new_scene = load(new_scene_path)
	
	var instance_scene = new_scene.instantiate()
	
	current_gui_scenes.append(instance_scene)
	gui.add_child(instance_scene)


func reload_3d_scene(scene_path : String):
	var scene_missing := true
	for scene in current_3d_scenes:
		if scene.scene_file_path == scene_path:
			scene_missing = false
			var idx = current_3d_scenes.find(scene)
			scene.queue_free()
			var new_scene = load(scene_path)
			current_3d_scenes[idx] = new_scene.instantiate()
			world_3d.add_child(current_3d_scenes[idx])
			break
	if scene_missing:
		push_error(scene_path, " Does not exist in current scope")


func reload_2d_scene(scene_path : String):
	var scene_missing := true
	for scene in current_2d_scenes:
		if scene.scene_file_path == scene_path:
			scene_missing = false
			var idx = current_2d_scenes.find(scene)
			scene.queue_free()
			var new_scene = load(scene_path)
			current_2d_scenes[idx] = new_scene.instantiate()
			world_2d.add_child(current_2d_scenes[idx])
			break
	if scene_missing:
		push_error(scene_path, " Does not exist in current scope")


func reload_gui_scene(scene_path : String):
	var scene_missing := true
	for scene in current_gui_scenes:
		if scene.scene_file_path == scene_path:
			scene_missing = false
			var idx = current_gui_scenes.find(scene)
			scene.queue_free()
			var new_scene = load(scene_path)
			current_gui_scenes[idx] = new_scene.instantiate()
			gui.add_child(current_gui_scenes[idx])
			break
	if scene_missing:
		push_error(scene_path, " Does not exist in current scope")


func swap_3d_scene(new_scene_path : String, 
					old_scene : PackedScene, 
					add_if_missing := false) -> void:
	var scene_missing := true
	for scene in current_3d_scenes:
		if scene.scene_file_path == old_scene.resource_path:
			scene_missing = false
			var idx = current_3d_scenes.find(scene)
			scene.queue_free()
			var new_scene
			if ResourceLoader.has_cached(new_scene_path):
				new_scene = ResourceLoader.load_threaded_get(new_scene_path)
			else:
				new_scene = load(new_scene_path)
			current_3d_scenes[idx] = new_scene.instantiate()
			world_3d.add_child(current_3d_scenes[idx])
			break
	if scene_missing and add_if_missing:
		add_new_3d_scene(new_scene_path)
	else:
		push_error(new_scene_path, " Does not exist in current scope")


func swap_2d_scene(new_scene_path : String, 
					old_scene : PackedScene,
					add_if_missing := false) -> void:
	var scene_missing := true
	for scene in current_2d_scenes:
		if scene.scene_file_path == old_scene.resource_path:
			scene_missing = false
			var idx = current_2d_scenes.find(scene)
			scene.queue_free()
			var new_scene
			if ResourceLoader.has_cached(new_scene_path):
				new_scene = ResourceLoader.load_threaded_get(new_scene_path)
			else:
				new_scene = load(new_scene_path)
			current_2d_scenes[idx] = new_scene.instantiate()
			world_2d.add_child(current_2d_scenes[idx])
			break
	if scene_missing and add_if_missing:
		add_new_2d_scene(new_scene_path)
	else:
		push_error(new_scene_path, " Does not exist in current scope")


func swap_gui_scene(new_scene : String, 
					old_scene : String, 
					add_if_missing := false) -> void:
	var scene_missing := true
	for scene in current_gui_scenes:
		if scene.scene_file_path == old_scene:
			scene_missing = false
			var idx : int = current_gui_scenes.find(scene)
			scene.queue_free()
			current_gui_scenes[idx] = load(new_scene).instantiate()
			gui.add_child(current_gui_scenes[idx])
			break
	if scene_missing and add_if_missing:
		add_new_gui_scene(new_scene)
	else:
		push_error("Attempted to swap %s with %s, but does not exist in current scope" 
					% [new_scene, old_scene])
