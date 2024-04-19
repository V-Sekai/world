extends RigidBody3D

@export var push_back: float = 2.0
@export var push_forward: float = 2.0
@export var invert := false
@onready var initial_position := global_position

var active := false

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if not active:
		constant_force = push_back * global_basis.z
	else:
		constant_force = push_forward * -global_basis.z
	var target_position := initial_position + (global_position - initial_position).project(global_basis.z)
	apply_central_impulse(target_position - global_position)

func _on_pressure_plate_pressed() -> void:
	if invert:
		active = false
	else:
		active = true

func _on_pressure_plate_released() -> void:
	if invert:
		active = true
	else:
		active = false
