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
		var mtoon_material: ShaderMaterial = ShaderMaterial.new()
		var mtoon_shader = load("res://addons/Godot-MToon-Shader/mtoon.gdshader")
		mtoon_material.shader = mtoon_shader
		mtoon_material.set_shader_parameter("_ShadeColor", Color(0, 0, 0))
		mtoon_material.set_script(load("res://addons/Godot-MToon-Shader/inspector_mtoon.gd"))
		csg_mesh.material = mtoon_material

	return scene
