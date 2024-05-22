extends CheckButton


func _ready() -> void:
	set_pressed_no_signal(Globals.check_flag("mobile"))
	if OS.has_feature("editor"):  # restart doesn't work in editor
		disabled = true
		focus_mode = Control.FOCUS_NONE


func _on_toggled(toggled_on: bool) -> void:
	Globals.set_flag("mobile", toggled_on)
	Globals.restart()
