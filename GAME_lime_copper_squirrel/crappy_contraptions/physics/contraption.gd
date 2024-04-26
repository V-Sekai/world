class_name Contraption
extends Node3D

var _connections: Dictionary = {}
var _constraints: Array[Joint3D] = []

static func save_contraption(item: RigidBody3D, path: String = "") -> SavedContraption:
	var save := SavedContraption.new()
	var parent := item.get_parent()
	for part in Contraption.get_all_bodies(item):
		save.parts[part.name] = part.scene_file_path
		save.positions[part.name] = item.to_local(part.global_position)
		save.rotations[part.name] = (item.global_basis.inverse() * part.global_basis).get_euler()
		for joint in Contraption.get_joints_for(part):
			var a := item.get_node_or_null(joint.node_a)
			var b := item.get_node_or_null(joint.node_b)
			if not a or not b:
				print("missing node")
				continue
			var rel_a := parent.get_path_to(a, true)
			var rel_b := parent.get_path_to(b, true)
			print("%s <-> %s" %[ rel_a, rel_b])
			save.connections.append(BuildConnection.new(rel_a, rel_b))
	if path:
		var ok := ResourceSaver.save(save, path)
		if ok != OK:
			print_debug(ok)
		print("saved %s" % ProjectSettings.globalize_path(path))
	return save

static func load_contraption(res: SavedContraption) -> Node3D:
	var base := Autobuild.new()
	base.build_list = res.connections
	for part_name in res.parts:
		var path: String = res.parts[part_name]
		var part_scene: PackedScene = load(path)
		var part := part_scene.instantiate()
		part.name = part_name
		part.position = res.positions[part_name]
		part.rotation = res.rotations[part_name]
		base.add_child(part)
	return base

static func _find_contraption_for(item: RigidBody3D) -> Contraption:
	if not item.is_inside_tree():
		return null
	var node: Node = item.get_parent()
	while node:
		if node is Contraption:
			return node
		node = node.get_parent()
	if not node is Contraption:
		return null
	return node

static func has_any_attachments(item: RigidBody3D) -> bool:
	return not get_joints_for(item).is_empty()

static func get_joints_for(item: RigidBody3D) -> Array[Joint3D]:
	var connector := _find_contraption_for(item)
	var ret: Array[Joint3D] = []
	if connector:
		var path := item.get_path()
		for constraint: Joint3D in connector._constraints:
			if constraint.node_a == path or constraint.node_b == path:
				ret.append(constraint)
	return ret

static func _get_all_internal(item: RigidBody3D, items: Array[NodePath] = [], visited: Dictionary = {}) -> Array[NodePath]:
	if not item:
		return items
	var path := item.get_path()
	if not items.has(path):
		items.append(path)
	for joint in get_joints_for(item):
		if not visited.has(joint.node_a):
			visited[joint.node_a] = true
			_get_all_internal(item.get_node_or_null(joint.node_a), items, visited)
		if not visited.has(joint.node_b):
			visited[joint.node_b] = true
			_get_all_internal(item.get_node_or_null(joint.node_b), items, visited)
	return items

static func get_all_bodies(item: RigidBody3D) -> Array[RigidBody3D]:
	var items := _get_all_internal(item)
	items = items.filter(func(path): return item.get_node_or_null(path)) 
	var ret: Array[RigidBody3D] = []
	for path in items:
		ret.append(item.get_node(path))
	return ret

static func freeze(item: RigidBody3D, force_unfreeze := false):
	var bodies := get_all_bodies(item)
	var new_freeze := not item.freeze
	if force_unfreeze:
		new_freeze = false
	for body in bodies:
		body.freeze = new_freeze
		body.linear_velocity *= 0
		body.angular_velocity *= 0

static func control(item: RigidBody3D, user: Node, reference: Basis, base: Basis, input: Vector3, rot_input: Vector3) -> bool:
	var controlled := false

	var bodies := get_all_bodies(item)
	var body_bound := AABB(item.global_position, Vector3())
	for body in bodies:
		body_bound = body_bound.expand(body.global_position)

	var control_relative := item.global_basis * base.inverse()

	var body_reference := Transform3D(control_relative * reference, body_bound.get_center())
	for body in bodies:
		if not body.is_in_group("control"):
			continue

		if body.has_signal("control"):
			body.emit_signal("control", user, body_reference, input, rot_input)
			controlled = true
		else:
			print("%s is controllable, but doesn't have a control signal defined" % item.name)

	return controlled

static func activate(item: RigidBody3D, user: Node):
	freeze(item, true)

	var bodies := get_all_bodies(item)
	for body in bodies:
		if not body.is_in_group("usable"):
			continue

		if body.has_signal("use"):
			body.emit_signal("use", user)
		else:
			print("%s is usable, but doesn't have a use signal defined" % item.name)

func _is_connected(a: RigidBody3D, b: RigidBody3D) -> bool:
	var path_a := a.get_path()
	var path_b := b.get_path()
	if not _connections.has(path_a):
		_connections[path_a] = []
	if not _connections.has(path_b):
		_connections[path_b] = []
	if _connections[path_a].has(path_b) or _connections[path_b].has(path_a):
		return true
	return false

static func attach_bodies(a: RigidBody3D, bodies: Array[RigidBody3D]) -> bool:
	var con := _find_contraption_for(a)
	var attached := false
	if not con:
		return attached
	var path_a := a.get_path()
	for b in bodies:
		if not b.is_in_group("build"):
			continue

		if not con._is_connected(a, b):
			var old_path := b.get_path()
			#b.reparent(a)
			var path_b := b.get_path()
			if path_b != old_path:
				con._connections[path_b] = con._connections[old_path]
				con._connections.erase(old_path)
			var constraint := WeldJoint.new(a, b)
			con._connections[path_a].append(path_b)
			con._connections[path_b].append(path_a)
			con.add_child(constraint)
			if b.freeze:
				a.freeze = b.freeze
			if a.freeze:
				b.freeze = a.freeze
			con._constraints.append(constraint)
			#print("attached %s and %s" % [a.name, b.name])
			attached = true
	return attached

static func detach_body(body: RigidBody3D):
	var con := _find_contraption_for(body)
	if not con:
		return
	var path := body.get_path()
	if not con._connections.has(path):
		return
	var connections := con._connections[path] as Array
	var erase: Array[Joint3D] = []
	for connection: NodePath in connections:
		if not con._connections.has(connection):
			continue
		con._connections[connection].erase(path)
		for constraint in con._constraints:
			if constraint.node_a == path or constraint.node_b == path:
				erase.append(constraint)
				con._connections[constraint.node_a].erase(constraint.node_b)
				con._connections[constraint.node_b].erase(constraint.node_a)
	for joint in erase:
		con._constraints.erase(joint)
		joint.queue_free()
