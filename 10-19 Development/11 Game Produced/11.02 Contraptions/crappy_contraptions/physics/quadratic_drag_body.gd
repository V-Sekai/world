extends RigidBody3D
class_name QuadraticDragBody

static var DEFAULT_DRAG: float = 0.0125
static var SMASH_THRESHOLD: float = 15.0

@export var quadratic_drag := DEFAULT_DRAG


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = QuadraticDragBody.apply_drag(linear_velocity, state.step, quadratic_drag)


static func apply_drag(
	vel: Vector3, step: float, quad_factor: float, const_factor: float = 0.0
) -> Vector3:
	vel -= vel * const_factor * step

	var v2 := vel
	v2 *= v2.length()
	vel -= v2 * quad_factor * step

	return vel


@onready var _last_velocity = linear_velocity


func _physics_process(_delta: float) -> void:
	if _last_velocity.distance_to(linear_velocity) > SMASH_THRESHOLD:
		Contraption.detach_body(self)
	_last_velocity = linear_velocity
