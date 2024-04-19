@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("SnailInput", "res://addons/snail_input/snail_input.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("SnailInput")
