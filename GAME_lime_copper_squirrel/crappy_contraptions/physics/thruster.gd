extends QuadraticDragBody

signal use(user: Node3D)
signal reset
signal control(user: Node3D, global_reference: Transform3D, input: Vector3, rot_input: Vector3)

@export var thrust_force := 75
@export var active := 0.0
var _target_control_force := 0.0
var _control_force := 0.0

func _ready() -> void:
	use.connect(_on_use)
	reset.connect(_on_reset)
	control.connect(_on_control)

func _on_reset():
	active = 0.0
	_target_control_force = 0
	_control_force = 0

func _on_use(_user: Node3D):
	active = 10.0

func _on_control(_user: Node3D, global_reference: Transform3D, input: Vector3, _rot_input: Vector3):
	var forward := -global_basis.z
	var iv := Vector3(input.x, input.z, -input.y)
	if iv:
		iv = iv.normalized() * pow(iv.abs().length(), 2.0)
	var input_forward := global_reference.basis * iv
	_target_control_force = maxf(0.0, forward.dot(input_forward))
	if _target_control_force > 0:
		active = get_physics_process_delta_time() * input.limit_length().length()
	DD.draw_ray_3d(global_position, global_basis.z, 0.5 + _control_force * 2, Color.RED)
	#DD.draw_axes(global_reference, 4)

func _physics_process(delta: float) -> void:
	super(delta)

	_control_force = lerpf(_control_force, _target_control_force, 1.0 - exp(-2.0 * delta))
	if _control_force <= 0.0:
		return
	apply_central_force(-global_basis.z * _control_force * thrust_force)
