extends Node3D

var color_material: Material = null
@export var character_mesh_instance: MeshInstance3D = null

func assign_multiplayer_material(p_material: Material) -> void:
	color_material = p_material
	if character_mesh_instance:
		character_mesh_instance.material_override = color_material
