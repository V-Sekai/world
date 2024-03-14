@tool
extends EditorPlugin

var editor_interface: EditorInterface = null


func _init():
	print("Initialising RootMotionExtractor plugin")


func _notification(p_notification: int):
	match p_notification:
		NOTIFICATION_PREDELETE:
			print("Destroying RootMotionExtractor plugin")


func get_name() -> StringName:
	return "RootMotionExtractor"


func _enter_tree() -> void:
	editor_interface = get_editor_interface()

	add_autoload_singleton(
		"RootMotionExtractor", "res://addons/root-motion-extractor/root_motion_extractor.gd"
	)


func _exit_tree() -> void:
	remove_autoload_singleton("RootMotionExtractor")
