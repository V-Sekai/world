extends MeshInstance3D

signal controller_activated(controller)

var _ws := 1.0

@onready var _controller: XRController3D = get_parent()
@onready var touchpad_cylinder = $Touchpad/Cylinder
@onready var touchpad_selection_dot = $Touchpad/SelectionDot
@onready var touchpad_material = StandardMaterial3D.new()

func _ready():
	_controller.visible = false


func _process(_delta):
	_base_controller_mesh_stuff()

	# Show a hint where the user's finger is on the touchpad.
	var touchpad_input = _controller.get_vector2("primary")
	if touchpad_input == Vector2.ZERO:
		touchpad_selection_dot.position = Vector3.ZERO
	else:
		touchpad_selection_dot.position = Vector3(touchpad_input.x, 0.5, -touchpad_input.y) * 0.018
		return

	touchpad_input = _controller.get_vector2("secondary")
	if touchpad_input == Vector2.ZERO:
		touchpad_selection_dot.position = Vector3.ZERO
	else:
		touchpad_selection_dot.position = Vector3(touchpad_input.x, 0.5, -touchpad_input.y) * 0.018
		return

func _base_controller_mesh_stuff():
	if !_controller.get_is_active():
		_controller.visible = false
		return

	_scale_controller_mesh()

	# Was active before, we don't need to do anything.
	if _controller.visible:
		return

	# Became active, handle it.
	var controller_name: String = _controller.get_pose().name
	print("Controller " + controller_name + " became active")

	touchpad_cylinder.visible = controller_name.find("vive") < 0
	if !touchpad_cylinder.visible:
		material_override = touchpad_material

	_controller.visible = true
	emit_signal("controller_activated", _controller)


func _scale_controller_mesh():
	var new_ws = XRServer.world_scale
	if _ws != new_ws:
		_ws = new_ws
		scale = Vector3.ONE * _ws
