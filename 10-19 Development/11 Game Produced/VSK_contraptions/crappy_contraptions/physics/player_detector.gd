extends Area3D

@export var target_path: NodePath

func _ready() -> void:
	var target := get_node_or_null(target_path)
	if not target:
		return
	if target.has_method("_on_pressure_plate_pressed"):
		body_entered.connect(func(node: Node3D):
			if node is CharacterBody3D:
				target._on_pressure_plate_pressed()
		)

	if target.has_method("_on_pressure_plate_released"):
		body_exited.connect(func(node: Node3D):
			if node is CharacterBody3D:
				target._on_pressure_plate_released()
		)
