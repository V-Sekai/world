extends XROrigin3D

var _ws := 1.0

@onready var _camera = $XRCamera
@onready var _camera_near_scale = _camera.near
@onready var _camera_far_scale = _camera.far


func _ready():
	var vr = XRServer.find_interface("OpenXR")
	if vr and vr.initialize():
		var viewport = get_viewport()
		viewport.use_xr = true
		get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (false) else DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 180
	else:
		printerr("Can't initialize OpenXR, exiting.")
		get_tree().quit()


func _process(_delta):
	var new_ws = XRServer.world_scale
	if _ws != new_ws:
		_ws = new_ws
		_camera.near = _ws * _camera_near_scale
		_camera.far = _ws * _camera_far_scale
		var child_count = get_child_count()
		for i in range(3, child_count):
			get_child(i).scale = Vector3.ONE * _ws
