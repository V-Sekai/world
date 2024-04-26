extends Node3D
class_name TriggerDoor

@export var inverted := false
@onready var door := $door
var _is_open := inverted


func open():
	_is_open = true


func close():
	_is_open = false


func _ready() -> void:
	if inverted:
		open()


func _on_pressure_plate_pressed() -> void:
	if inverted:
		close()
	else:
		open()


func _on_pressure_plate_released() -> void:
	if inverted:
		open()
	else:
		close()


func _physics_process(_delta: float) -> void:
	var force: Vector3 = door.global_basis.y * (15 * door.mass)
	if not _is_open:
		force *= -0.5
	door.apply_central_force(force)
