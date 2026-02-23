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

var current_3d_scenes: Array[Node]
var current_2d_scenes: Array[Node]
var current_gui_scenes: Array[Node]

func _ready():
	
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

func return_to_main_menu(
						use_default : = true, 
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
	
	if use_default:
		add_new_gui_scene(main_menu)
		
	else:
		# Customize this block for your game's main menu behavior
		return
	
	if get_tree().paused:
		get_tree().paused = false

func isolate_new_3d_scene(new_scene : PackedScene):
	current_gui_scenes.all(queue_free)
	current_gui_scenes.clear()

	current_3d_scenes.all(queue_free)
	current_3d_scenes.clear()

	current_2d_scenes.all(queue_free)
	current_2d_scenes.clear()
	
	var instance_scene = new_scene.instantiate()
	if is_instance_valid(instance_scene):
		world_3d.add_child(instance_scene)

func isolate_new_2d_scene(new_scene : PackedScene):
	current_gui_scenes.all(queue_free)
	current_gui_scenes.clear()

	current_3d_scenes.all(queue_free)
	current_3d_scenes.clear()

	current_2d_scenes.all(queue_free)
	current_2d_scenes.clear()
	
	var instance_scene = new_scene.instantiate()
	if is_instance_valid(instance_scene):
		world_2d.add_child(instance_scene)

func isolate_new_gui_scene(new_scene : PackedScene):
	current_gui_scenes.all(queue_free)
	current_gui_scenes.clear()

	current_3d_scenes.all(queue_free)
	current_3d_scenes.clear()

	current_2d_scenes.all(queue_free)
	current_2d_scenes.clear()
	
	var instance_scene = new_scene.instantiate()
	if is_instance_valid(instance_scene):
		gui.add_child(instance_scene)

func swap_3d_scene(new_scene : PackedScene, old_scene : PackedScene, add_if_missing := false) -> void:
	for scene in current_3d_scenes:
		if scene.scene_file_path == old_scene.resource_path:
			var idx = current_3d_scenes.find(scene)
			scene.queue_free()
			current_3d_scenes[idx] = new_scene.instantiate()
			world_3d.add_child(current_3d_scenes[idx])
			break

func swap_2d_scene(new_scene : PackedScene, old_scene : PackedScene, add_if_missing := false) -> void:
	for scene in current_2d_scenes:
		if scene.scene_file_path == old_scene.resource_path:
			var idx = current_2d_scenes.find(scene)
			scene.queue_free()
			current_2d_scenes[idx] = new_scene.instantiate()
			world_2d.add_child(current_2d_scenes[idx])
			break

func swap_gui_scene(new_scene : PackedScene, old_scene : PackedScene, add_if_missing := false) -> void:
	
	for scene in current_gui_scenes:
		if scene.scene_file_path == old_scene.resource_path:
			var idx = current_gui_scenes.find(scene)
			scene.queue_free()
			current_gui_scenes[idx] = new_scene.instantiate()
			gui.add_child(current_gui_scenes[idx])
			break

func add_new_3d_scene(new_scene : PackedScene) -> void:
	var instance_scene = new_scene.instantiate()
	
	current_3d_scenes.append(instance_scene)
	world_3d.add_child(instance_scene)

func add_new_2d_scene(new_scene : PackedScene) -> void:
	var instance_scene = new_scene.instantiate()
	
	current_2d_scenes.append(instance_scene)
	world_2d.add_child(instance_scene)

func add_new_gui_scene(new_scene : PackedScene) -> void:
	var instance_scene = new_scene.instantiate()
	
	current_gui_scenes.append(instance_scene)
	gui.add_child(instance_scene)
	










#func change_3d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	#if current_3d_scene:
		#if delete:
			#current_3d_scene.queue_free()
		#elif keep_running:
			#current_3d_scene.hide()
		#else:
			#world_3d.remove_child(current_3d_scene)
	#var new = load(new_scene).instantiate()
	#world_3d.add_child(new)
	#current_3d_scene = new
#
#func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	#if current_2d_scene:
		#if delete:
			#current_2d_scene.queue_free()
		#elif keep_running:
			#current_2d_scene.hide()
		#else:
			#world_2d.remove_child(current_2d_scene)
	#var new = load(new_scene).instantiate()
	#world_2d.add_child(new)
	#current_2d_scene = new
#
#func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	#if current_gui_scene:
		#if delete:
			#current_gui_scene.queue_free()
			#print("freeing ", current_gui_scene.name)
		#elif keep_running:
			#current_gui_scene.hide()
		#else:
			#gui.remove_child(current_gui_scene)
	#var new = load(new_scene).instantiate()
	#gui.add_child(new)
	#current_gui_scene = new
