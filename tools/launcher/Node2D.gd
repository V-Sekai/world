extends Control

@export_global_dir var godot_project

var pid = []

func _on_Button2_pressed():
	var args = ["--path", godot_project]
	pid = pid + [OS.create_instance(args)]


func _on_Off_pressed():
	_stop_pid()


func _stop_pid():
	for p in pid:
		OS.kill(p)
		pid.erase(p)
