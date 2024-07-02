@tool
extends EditorScenePostImport

func _post_import(scene):
	var nodes: Array[Node] = scene.find_children("*", "MeshInstance3D")
	if nodes.size() > 0:
		var node: MeshInstance3D = nodes[0]
		var csg_mesh = CSGMesh3D.new()
		csg_mesh.mesh = node.mesh
		csg_mesh.name = node.name
		node.queue_free()
		node.replace_by(csg_mesh, true)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_texture = preload("res://Planner/Art/Brick/Manifold/bevel-hq-plate-corner_colormap.png")
		csg_mesh.material = material
	return scene
