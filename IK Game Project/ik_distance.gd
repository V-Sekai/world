extends Node

func euclidean_distance(p1, p2):
	return p1.distance_to(p2)

func chamfer_distance(set_A, set_B):
	var total_distance = 0.0
	for point_A in set_A:
		var min_distance = INF
		for point_B in set_B:
			var distance = euclidean_distance(point_A, point_B)
			if distance < min_distance:
				min_distance = distance
		total_distance += min_distance
	return total_distance

func _process(_delta):
	#var set_A = [Vector2(1, 2), Vector2(3, 4), Vector2(5, 6)]
	#var set_B = [Vector2(7, 8), Vector2(9, 10), Vector2(11, 12)]
	#print("Test distance: %s" % chamfer_distance(set_A, set_B))
	var bones: Array = [
		"Root",
		"Hips",
		"Spine",
		#"LeftUpperArm",
		"LeftHand",
		#"RightUpperArm",
		"RightHand",
		"LeftLowerLeg",
		"RightLowerLeg",
		"Head",
	]
	
	var set_a: Array[Vector3] = []
	var set_b: Array[Vector3] = []
	
	var reference_skeleton:Skeleton3D = get_node("vrm_1_vsekai_godot_engine_humanoid_08/Root/Skeleton3D")
	for bone_name in bones:
		if bone_name == "Root":
			bone_name = "root"
		var bone_id = reference_skeleton.find_bone(bone_name)
		if bone_id != -1:
			var bone_position = reference_skeleton.get_bone_pose_position(bone_id)
			set_a.append(bone_position)
		else:
			print("Bone '%s' not found!" % bone_name)
	
	var target_skeleton:Skeleton3D = get_node("VVVV_200502/Armature/GeneralSkeleton")
	for bone_name in bones:
		var bone_id = target_skeleton.find_bone(bone_name)
		if bone_id != -1:
			var bone_position = target_skeleton.get_bone_pose_position(bone_id)
			set_b.append(bone_position)
		else:
			print("Bone '%s' not found!" % bone_name)
	#var distance = chamfer_distance(set_a, set_b)
	#print("Skeleton distance same: %s" % chamfer_distance(set_a, set_a))
	print("Skeleton distance: %s" % chamfer_distance(set_a, set_b))
