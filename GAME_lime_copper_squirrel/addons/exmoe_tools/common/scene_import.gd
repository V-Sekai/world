@tool
extends EditorScenePostImport


func iterate(scene, node: Node3D, animated := false, anim_transform := Transform3D.IDENTITY):
	if not node:
		return

	if node is MeshInstance3D and node.mesh:
		var aabb: AABB = node.mesh.get_aabb()
		var size := aabb.get_longest_axis_size()
		if size < 100:
			node.visibility_range_end = clampf(size * 75, 100, 1000)
		if size < 10:
			if size < 3:
				node.set_layer_mask_value(1, false)
				node.set_layer_mask_value(2, true)
				if size < 1:
					print(
						(
							"%s: tiny object detected (reflection-, range=%d)"
							% [node.name, node.visibility_range_end]
						)
					)
				else:
					print(
						(
							"%s: small object detected (reflection-, range=%d)"
							% [node.name, node.visibility_range_end]
						)
					)
			else:
				print(
					"%s: medium object detected (range=%d)" % [node.name, node.visibility_range_end]
				)
			node.visibility_range_end_margin = 5
			node.visibility_range_fade_mode = node.VISIBILITY_RANGE_FADE_SELF
		elif size > 50:
			print(node.name, ": large object detected, will be visible in far field")
			node.set_layer_mask_value(3, true)  # large objects

	if node is Light3D:
		print("adjusting light power and ranges...")
		var adjust := 0.01
		var falloff := 1.0
		# this comes in too strong, also work around negative bug
		node.light_negative = node.light_energy < 0
		node.light_energy = abs(node.light_energy * adjust)
		node.light_intensity_lumens *= 2.5
		node.distance_fade_enabled = true
		node.distance_fade_begin = node.light_energy * 10
		node.light_cull_mask ^= 0x4  # don't show on layer 3
		if true or node.name.contains("MW_shadow"):
			node.shadow_enabled = true
			node.distance_fade_shadow = node.light_energy
		if node is OmniLight3D:
			node.omni_range = node.light_energy * 0.5
			node.omni_attenuation = falloff
			# doesn't seem to work on m1 or godot 4.1.1
			#node.omni_shadow_mode = OmniLight3D.SHADOW_DUAL_PARABOLOID
		elif node is SpotLight3D:
			node.spot_range = node.light_energy * 0.5
			node.spot_attenuation = falloff

#		for i in range(node.mesh.get_surface_count()):
#			var mat = node.mesh.surface_get_material(i)
#			if mat is StandardMaterial3D:
#				mat.albedo_color.r = 0

	var parts := node.name.split(",")
	for part in parts:
		var vals := part.split("=")
		var key = vals[0].strip_edges()
		match key:
			"MW_spin":
				print("spin")
				var torque := TAU / 60.0
				var spinner = SpinBehavior.new()
				if vals.size() > 1 and vals[1].is_valid_float():
					var factor = vals[1].to_float()
					torque = factor / 60.0 * TAU
					print(factor)
				spinner._spin = torque
				spinner.transform = node.transform
				node.add_sibling(spinner)
				node.get_parent().remove_child(node)
				spinner.add_child(node)
				node.transform = Transform3D.IDENTITY
				spinner.owner = scene
				animated = true

	if animated and node is StaticBody3D:
		print("replacing static body with kinematic body due to animated behavior")
		var anim_body := AnimatableBody3D.new()
		anim_body.transform = node.transform
		node.replace_by(anim_body)
		node.free()
		anim_body.owner = scene
		node = anim_body

#	if animated:
#		anim_transform = anim_transform * node.transform

	for child in node.get_children():
		iterate(scene, child, animated, anim_transform)


func _post_import(scene):
	# use scene.replace_by(other) to replace root
	iterate(scene, scene)
	return scene
