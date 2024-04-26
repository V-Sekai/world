extends Control

func _unhandled_input(_event: InputEvent) -> void:
	if visible and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		await get_tree().process_frame
		set_focus_mode(Control.FOCUS_ALL)
		grab_focus()
		grab_click_focus()
