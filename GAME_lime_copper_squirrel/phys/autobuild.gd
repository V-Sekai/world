@tool
extends Node3D
class_name Autobuild

@export var connection_debug := false
@export var build_list: Array[BuildConnection] = []
@onready var debug_mesh: MeshInstance3D
var labels := {}
var colors := {}

func _ready() -> void:
	if Engine.is_editor_hint():
		debug_mesh = MeshInstance3D.new()
		debug_mesh.mesh = ImmediateMesh.new()
		var debug_mat := StandardMaterial3D.new()
		debug_mat.vertex_color_use_as_albedo = true
		debug_mat.no_depth_test = true
		debug_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		debug_mesh.material_override = debug_mat
		add_child(debug_mesh)
		return

	await get_tree().process_frame

	for connection in build_list:
		if not connection:
			continue
		if connection.node_a.is_absolute() or connection.node_b.is_absolute():
			print("warning: connection has absolute paths (%s, %s)" % [connection.node_a, connection.node_b])
			continue
		var a := get_node_or_null(connection.node_a)
		var b := get_node_or_null(connection.node_b)
		if not a is RigidBody3D or not b is RigidBody3D:
			continue
		if not a.is_in_group("build") or not b.is_in_group("build"):
			continue
		if a and b:
			Contraption.attach_bodies(a, [b])

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return

	var im = debug_mesh.mesh as ImmediateMesh
	im.clear_surfaces()

	if not connection_debug:
		return

	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(Vector3()) # it's valid to have no connections, so silence the error
	im.surface_add_vertex(Vector3())

	var i := -1
	for connection in build_list:
		i += 1
		if not connection:
			continue
		var a := get_node_or_null(connection.node_a)
		var b := get_node_or_null(connection.node_b)
		if a and b:
			if not colors.has(connection):
				colors[connection] = Color(randf() / 2, randf() / 2, randf() / 2)
			if not labels.has(connection):
				labels[connection] = Label3D.new()
				add_child(labels[connection])
			im.surface_set_color(colors[connection])
			var label: Label3D = labels[connection]
			var ap: Vector3 = a.global_position
			var bp: Vector3 = b.global_position
			label.text = "%s < %d > %s" % [ a.name, i, b.name ]
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.no_depth_test = true
			label.pixel_size = 0.0025
			label.global_position = (ap + bp) / 2
			im.surface_add_vertex(ap)
			im.surface_add_vertex(bp)

	im.surface_end()
