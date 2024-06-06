extends Node

# Start by loading a zip that is produced using Godot's export functionality and contains the xr injector files
# May just wind up using local files again once custom global classes are removed from scripts for ease of use, remains to be seen.
func _init() -> void:
	print("loading injector files")
	print("Size of game window found in injector.gd: ", DisplayServer.window_get_size())
	print("Size (resolution) of screen found in injector.gd: ", DisplayServer.screen_get_size())

func _ready() -> void:
	print("Now loading xr_scene.")
	var xr_scene : PackedScene = load("res://xr_injector/xr_scene.tscn")
	get_node("/root").call_deferred("add_child", xr_scene.instantiate())
