extends RigidBody3D
class_name QuadraticDragBody

static var DEFAULT_DRAG: float = 0.0125

@export var quadratic_drag := DEFAULT_DRAG

static func apply_drag(vel: Vector3, step: float, quad_factor: float, const_factor: float = 0.0) -> Vector3:
	vel -= vel * const_factor * step

	var v2 := vel.normalized() * (vel * vel).length()
	vel -= v2 * quad_factor * step

	return vel

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	linear_velocity = QuadraticDragBody.apply_drag(linear_velocity, state.step, quadratic_drag)
