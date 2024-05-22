extends StaticBody3D

@onready var _trigger := %trigger
@onready var _switch := %switch

@export var target_path: NodePath

signal changed(pressed: bool)
signal pressed
signal released


func _ready() -> void:
	_trigger.body_entered.connect(_on_press)
	_trigger.body_exited.connect(_on_release)

	var target := get_node_or_null(target_path)
	if target:
		if target.has_method("_on_pressure_plate_pressed"):
			pressed.connect(target._on_pressure_plate_pressed)
		if target.has_method("_on_pressure_plate_released"):
			released.connect(target._on_pressure_plate_released)

	_switch.add_collision_exception_with(self)


func _on_press(node: Node3D):
	if node != _switch:
		return
	changed.emit(true)
	pressed.emit()


func _on_release(node: Node3D):
	if node != _switch:
		return
	changed.emit(false)
	released.emit()
