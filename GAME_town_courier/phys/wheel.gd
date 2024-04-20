extends VehicleBody3D

signal control(user: Node3D, global_reference: Transform3D, input: Vector3, rot_input: Vector3)
signal use(user: Node3D)
signal reset

# same as on QuadraticDragBody
@export var quadratic_drag := QuadraticDragBody.DEFAULT_DRAG

@export var torque: float = 40
@export var active: float = 0.0

@onready var wheel := %spinny

func _ready() -> void:
	use.connect(_on_use)
	reset.connect(_on_reset)
	control.connect(_on_control)

func _on_reset():
	active = 0.0
	engine_force = 0

func _on_use(_user: Node3D):
	active = 10.0
	engine_force = torque

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = QuadraticDragBody.apply_drag(linear_velocity, state.step, quadratic_drag)

func _on_control(_user: Node3D, global_reference: Transform3D, input: Vector3, _rot_input: Vector3):
	var tick := get_physics_process_delta_time()
	active = tick

	var right := global_basis.x
	var forward := -global_basis.z
	var input_forward := global_reference.basis * Vector3(input.x, input.z, -input.y)
	engine_force = lerpf(engine_force, torque * forward.dot(input_forward), 1.0 - exp(-4.0 * tick))
	steering = lerpf(steering, deg_to_rad(30) * -right.dot(input_forward), 1.0 - exp(-3.0 * tick))

func _physics_process(delta: float) -> void:
	if active <= 0.0:
		engine_force = 0
		return
	#print(engine_force, " ", steering)
	active -= delta
