extends QuadraticDragBody

signal reset
signal control(user: Node3D, global_reference: Transform3D, input: Vector3, rot_input: Vector3)

var _target_control_force := Vector3()
var _control_force := Vector3()

func _ready() -> void:
	control.connect(_on_control)
	reset.connect(_on_reset)

func _on_reset():
	_control_force = Vector3()
	_target_control_force = Vector3()

func _on_control(_user: Node3D, _global_reference: Transform3D, _input: Vector3, rot: Vector3):
	var bodies := Contraption.get_all_bodies(self)
	var total_mass := 0.0
	for body in bodies:
		total_mass += body.mass

	_target_control_force = Vector3(-rot.x, rot.y, rot.z) * 0.5
	_control_force.x = minf(absf(_control_force.x), absf(_target_control_force.x)) * signf(_target_control_force.x)
	_control_force.y = minf(absf(_control_force.y), absf(_target_control_force.y)) * signf(_target_control_force.y)
	_control_force.z = minf(absf(_control_force.z), absf(_target_control_force.z)) * signf(_target_control_force.z)
	var av := global_basis * (rotation * -Vector3(1, 0, 1) + _control_force)
	av *= total_mass * 0.25
	apply_torque_impulse(av)

func _closest_vector(b: Basis, v: Vector3) -> Vector3:
	var cmp := Vector3(b.x.dot(v), b.y.dot(v), b.z.dot(v))
	var axis := cmp.abs().max_axis_index()
	return b[axis] * signf(cmp[axis])

func _closest_alignment(from_basis: Basis, to_basis: Basis) -> Basis:
	var cx := _closest_vector(to_basis, from_basis.x)
	var cy := _closest_vector(to_basis, from_basis.y)
	return Basis(cx, cy, cx.cross(cy)).orthonormalized()

func _physics_process(delta: float) -> void:
	_control_force = _control_force.lerp(_target_control_force, 1.0 - exp(-1.0 * delta))
