# Godot Quick Start Kit
This is a premade Godot kit intended as a base for time-sensitive projects where the use of existing code is allowed. It’s designed to reduce setup overhead without becoming a major gameplay shortcut — streamlining development while keeping the player experience in focus.

Actively being developed and improved

## Project Structure

```
├── \_Main/
│   ├── main.gd                    
│   └── main.tscn  
├── \_Test/       
│   └── test.tscn
├── Assets/                     
│   ├── Art/
│   └── UIThemes/
│       ├── KenneyUI/~
│       └── MinimalistUI/~
├── Autoload/
│   └── ConfigManager.gd 
├── Entities/
│   └── Player/
│       ├── Scenes/            
│       └── Scripts/ 
├── UserInterface/
│   ├── Components/
│   │   ├── Audio
│   │        ├── audio_slider_component.gd
│   │        └── audio_slider_component.tscn
│   ├── MainMenu/
│   │   ├── Scenes/
│   │        └── main_menu.tscn
│   │   └── Scripts/
│   │        └── main_menu.gd
│   ├── PauseMenu/
│   │   ├── Scenes/
│   │        └── pause_menu.tscn
│   │   └── Scripts/
│   │        └── pause_menu.gd
│   └── SettingsMenu/
│   │   ├── Scenes/
│   │        └── settings_menu.tscn
│   │   └── Scripts/
│   │        └── settings_menu.gd
├── default_bus_layut.tres
├── icon.svg
└── README.md
```
## Features
### Main 
the `Main` scene acts as the central hub for runtime scene management and game state transitions. Functions are isolated to allow for custom functionality to be added without needing to refactor existing code

The scene management system is based on [this tutorial by StayAtHomeDev on YouTube](https://youtu.be/32h8BR0FqdI?si=kLkGPVvZM4OmlhrU), adapted for this kit's structure.

**Node Structure**:
- `World_3D` (`Node3D`) — parent for active 3D scenes
- `World_2D` (`Node2D`) — parent for active 2D scenes
- `GUI` (`Control`) — parent for active UI scenes

**Scene Management API**:
* The Main scene provides three key functions for dynamic scene loading, scoped by type:
	* `change_3d_scene(new_scene: String, delete: bool = true, keep_running: bool = false)`
	* `change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false)`
	* `change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false)`
	
* Parameter behaviour:
	* `new_scene`: Path to the `PackedScene` as a String
	* `delete`: if `true`, the existing scene is freed from memory. Default: `true`
	* `keep_running`: if `true`, the old scene is hidden and continues to process. Default: `false`
	* If both `delete` and `keep_running` are false, the scene is unparented, ceasing processing but preserving it in memory for reference
	
**Settings Requesting**:
* `request_settings()` emits the `show_settings` signal for registered listeners. By default:
	* `MainMenu`'s `Settings` button calls `request_settings()`
	* `PauseMenu`'s `Settings` button calls `request_settings()`
	* `show_settings` is connected to `SettingMenu`'s `_on_show()` function
	
* `closing_settings()` emits the `hiding_settings` signal for registered listeners. by default:
	* Settings Menu's Back button calls `closing_settings`
	* `hiding_settings` is connected to Main Menu's `_get_ui_focus()` function
	* `hiding_settings` is connected to Settings Menu's `_get_ui_focus()` function

Pause Management:
* `request_pause()` and `request_unpause()` handle all pause state logic centrally..
* Since `Main` scene is the root of the gameplay tree, centralising pause logic ensures consistent behaviour across scenes.
* Avoids fragmented or conflicting pause states in nested systems
## Config Manager
The `Config Manager` is an autoload scene that manages the config files, for settings by default but can easily be expanded on. 

**Settings**:
a settings.ini file is automatically generated on ready. located in `user://settings.ini`

* Adding New Settings:
	* To add custom settings to be saved and loaded, add it in `get_settings()` 
	* Use this format: `Default_settings.set_value("section", "option", value)`
	* Then in the inspector for the `ConfigManager` scene, toggle the "Update Settings Config" or start the game in any scene. 
	* console will show success or error logs
	
* Load Settings:
	* Calling `load_setting_type_settings()` (By default audio and video settings types are available), you can return a dictionary from the setting you're calling. e.g. `load_video_settings().fullscreen` would return a bool by default
	
* Save Settings:
	* Calling `save_setting_type_settings(key: String, value)` (By default audio and video settings types are available), allows you to save a setting's value to config. e.g. `save_video_settings("fullscreen", true)`
	
* Available Methods:
	* `toggle_fullscreen(state: bool)` 
	* `toggle_mute(state: bool)` 
		* Emits `muted_audio` signal, by default is used by `audio_slider_component` to to reflect change
	* `set_screen(screen: int)`
	* `get_default_settings()` - returns a ConfigFile and contains the default settings
	* `update_missing_settings()` adds and deletes `config` to include
	* `reset_to_default()` applies `get_default_settings()` to the saved `config` file
## Main Menu
A basic main menu with Start, Settings and Quit buttons
