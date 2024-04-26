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

func calc_angular_velocity(from_basis: Basis, to_basis: Basis) -> Vector3:
	return (to_basis * from_basis.inverse()).get_euler()

func _on_control(_user: Node3D, _global_reference: Transform3D, _input: Vector3, rot: Vector3):
	var bodies := Contraption.get_all_bodies(self)
	var total_mass := 0.0
	for body in bodies:
		total_mass += body.mass

	_target_control_force = Vector3(rot.x, rot.y, -rot.z) * 0.5
	_control_force.x = minf(absf(_control_force.x), absf(_target_control_force.x)) * signf(_target_control_force.x)
	_control_force.y = minf(absf(_control_force.y), absf(_target_control_force.y)) * signf(_target_control_force.y)
	_control_force.z = minf(absf(_control_force.z), absf(_target_control_force.z)) * signf(_target_control_force.z)
	#print(_control_force)
	var influence := clampf(global_basis.y.angle_to(Vector3.UP) / PI, 0.25, 1.0)
	var av := Vector3()
	av += global_basis * _control_force
	av += calc_angular_velocity(global_basis, Basis.looking_at(global_basis.z, Vector3.UP, true)) * influence
	av *= total_mass * 0.75
	apply_torque_impulse(av)

func _physics_process(delta: float) -> void:
	super(delta)
	_control_force = _control_force.lerp(_target_control_force, 1.0 - exp(-1.0 * delta))
