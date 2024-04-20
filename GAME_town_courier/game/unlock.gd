extends Node
class_name Unlock

@export var save_flag: String

func _ready() -> void:
	if save_flag and not Globals.check_flag(save_flag):
		if OS.has_feature("editor"):
			print("set ", save_flag)
		Globals.flags[save_flag] = true
		Globals.save()
