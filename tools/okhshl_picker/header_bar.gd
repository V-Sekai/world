extends PanelContainer

var moving_window : bool = false
var mouse_position : Vector2

func _input(event):
	if moving_window and event is InputEventMouseMotion:
		get_window().position += Vector2i(event.relative)

func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			moving_window = true
			mouse_position = get_global_mouse_position()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			moving_window = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			warp_mouse(mouse_position)
	
