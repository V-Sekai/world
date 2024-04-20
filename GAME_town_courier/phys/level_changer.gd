extends Node3D

@export_file("*.tscn") var map_path: String

func _ready() -> void:
	assert(map_path)
	%scene_changer.scene_path = map_path
