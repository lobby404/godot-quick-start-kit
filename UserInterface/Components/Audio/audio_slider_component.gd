##############################
#        Premade Asset       #
##############################
extends HSlider

@export var bus_name: String

var bus_index: int
var set_slider_name: String = ""

func _ready():
	update_sliders()
	
	if !is_connected("drag_ended", _on_drag_ended):
		connect("drag_ended", _on_drag_ended )
	if !is_connected("value_changed", _on_value_changed):
		connect("value_changed", _on_value_changed)
	Global.connect("muted_audio", _on_mute_check)
	Global.connect("resetting_settings", update_sliders)

func update_sliders():
	if bus_name != "":
		bus_index = AudioServer.get_bus_index(bus_name.to_lower().capitalize())
		set_slider_name = bus_name.to_lower() + "_volume"
		var config_value = Global.load_audio_settings()[set_slider_name]
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(config_value))
		
		value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	else:
		printerr("Audio Slider \"", name, "\" has no bus name defined in path: ", get_path())
		
		_on_mute_check()

func _on_mute_check():
	editable = !AudioServer.is_bus_mute(0)

func _on_value_changed(new_value):
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
	else:
		printerr("Audio Slider \"", name, "\" has bus name \"", bus_name, "\" and does not corilate to any audio bus")


func _on_drag_ended():
	Global.save_audio_setting(set_slider_name, value)
