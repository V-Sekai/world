extends Node3D

@export var part: PackedScene
@export var part_count := 2

var _spawned: Array[NodePath] = []


func _ready() -> void:
	assert(part and part.can_instantiate())


func _on_spawn():
	var new_part: Node3D = part.instantiate()
	add_child(new_part)
	new_part.global_position = global_position
	_spawned.append(new_part.get_path())
	while _spawned.size() > part_count:
		var kill_part: Node = get_node_or_null(_spawned.pop_front())
		if not kill_part:
			continue
		if kill_part is RigidBody3D:
			Contraption.detach_body(kill_part)
		kill_part.queue_free()


func _on_pressure_plate_pressed():
	_on_spawn()
