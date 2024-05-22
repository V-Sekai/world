extends Node

var first_load := true
var flags: Dictionary = {}

const SAVE_FILE := "user://save.json"

signal new_unlock(flag: String)


func check_flag(flag: String) -> bool:
	return flags.has(flag) and flags[flag]


func set_flag(flag: String, value := true):
	flags[flag] = value
	new_unlock.emit(flag)
	print("set %s=%s" % [flag, value])


func restart():
	if OS.has_feature("editor"):  # restart doesn't work in editor
		print("can't restart in editor, only in exports")
		return

	var args := OS.get_cmdline_args()
	if check_flag("mobile"):
		var mobile := ["--rendering-method", "mobile"]
		if not args.has("--rendering-method"):
			args.append_array(mobile)
		set_flag("mode_changed_for_mobile", true)
	else:
		var idx := args.find("--rendering_method")
		if idx >= 0 and args.size() >= idx + 2:
			args.remove_at(idx + 1)
			args.remove_at(idx)
		set_flag("mode_changed_for_mobile", false)
	OS.set_restart_on_exit(true, args)
	get_tree().quit()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var save_data := FileAccess.get_file_as_string(SAVE_FILE)
	if save_data:
		flags = JSON.parse_string(save_data)
		print("loaded")
	else:
		print("new save data")

	var args := OS.get_cmdline_args()
	print(args)
	if check_flag("mobile") and not args.has("--rendering-method"):
		if not check_flag("mode_changed_for_mobile"):
			await get_tree().process_frame
			restart()


func clear_save():
	print("clearing save data")
	flags.clear()
	save()


func save():
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(flags, "\t"))
	print("saved")


func _exit_tree() -> void:
	save()


var show_fps := false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		show_fps = not show_fps


func _process(_delta: float) -> void:
	if show_fps:
		DD.set_text("FPS %d" % Engine.get_frames_per_second())
