extends Node

@export var check_flag: String

func _on_new_unlock(flag: String):
	if flag != check_flag:
		return

	if Globals.check_flag(check_flag):
		queue_free()

func _ready():
	if Globals.check_flag(check_flag):
		_on_new_unlock(check_flag)
	else:
		Globals.new_unlock.connect(_on_new_unlock)
