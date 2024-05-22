extends Area3D

var _spawn_transforms: Dictionary = {}


func _on_body_entered(node: Node3D):
	_spawn_transforms[node.get_path()] = node.global_transform


func _on_body_exited(node: Node3D):
	var path := node.get_path()
	await get_tree().process_frame
	if not node:  # freed before the await completed
		_spawn_transforms.erase(path)
		return
	if _spawn_transforms.has(path):
		node.global_transform = _spawn_transforms[path]
		if node is CharacterBody3D:
			node.velocity *= 0
		elif node is RigidBody3D:
			node.linear_velocity *= 0
			node.angular_velocity *= 0

		if node.has_signal("reset"):
			node.emit_signal("reset")
		_spawn_transforms.erase(path)

	if node is RigidBody3D:
		Contraption.detach_body(node)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
