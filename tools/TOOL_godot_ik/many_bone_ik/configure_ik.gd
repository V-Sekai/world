@tool
extends EditorScript

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

	for point_B in set_B:
		var min_distance = INF
		for point_A in set_A:
			var distance = euclidean_distance(point_B, point_A)
			if distance < min_distance:
				min_distance = distance
		total_distance += min_distance

	return total_distance / (set_A.size() + set_B.size())


func test_chamfer_distance():
	var set_A = [Vector2(1, 2), Vector2(3, 4), Vector2(5, 6)]
	var set_B = [Vector2(7, 8), Vector2(9, 10), Vector2(11, 12)]
	print(chamfer_distance(set_A, set_B))

const ik_config = preload("res://many_bone_ik/ik_config.gd")

class BoneConstraint:
	var twist_from: float
	var twist_range: float
	var swing_limit_cones: Array
	var resistance: float

	func _init(twist_from: float = 0, twist_range: float = TAU, swing_limit_cones: Array = [], resistance: float = 0):
		self.twist_from = twist_from
		self.twist_range = twist_range
		self.swing_limit_cones = swing_limit_cones
		self.resistance = resistance

var bone_names = ["Root", "Hips", "Spine", "Chest", "UpperChest", "Neck", "Head", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot", "LeftShoulder", "RightShoulder", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand"]

func _run():
	var root: Node = get_scene()
	var nodes: Array[Node] = root.find_children("*", "ManyBoneIK3D")
	if nodes.is_empty():
		return
	var many_bone_ik: ManyBoneIK3D = nodes[0]
	var markers: Array[Node] = many_bone_ik.find_children("*", "Marker3D")
	for marker in markers:
		marker.free()

	many_bone_ik.set_process_thread_group(Node.PROCESS_THREAD_GROUP_SUB_THREAD)
	many_bone_ik.set_process_thread_group_order(100)

	var skeleton: Skeleton3D = many_bone_ik.get_node("..")

	skeleton.show_rest_only = true
	skeleton.reset_bone_poses()
	## DEBUG VALUES ## 
	many_bone_ik.stabilization_passes = 1
	many_bone_ik.default_damp = TAU
	many_bone_ik.iterations_per_frame = 1
	many_bone_ik.set_constraint_count(0)
	var skeleton_profile: SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var profile: SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	var bone_config = ik_config.new().bone_configurations
	for bone_name in bone_config.keys():
		var kususdama = []
		if bone_name.ends_with("Eye"):
			continue
		var config = bone_config[bone_name]
		if config.has("kususdama"):
			for element in config["kususdama"]:
				kususdama.append(element)
		var twist_from = 0
		if config.has("twist_from"):
			twist_from = config["twist_from"]
		else:
			twist_from = 0
		var twist_range = 0
		if config.has("twist_range"):
			twist_range = config["twist_range"]
		set_bone_constraint(many_bone_ik, bone_name, twist_from, twist_range, kususdama)

	#many_bone_ik.queue_print_skeleton()

	var bones: Array = [
		"Root",
		"Hips",
		#"Hips",
		#"Chest",
		#"LeftLowerArm",
		"LeftHand",
		#"LeftThumbProximal",
		#"LeftIndexProximal",
		#"LeftMiddleProximal",
		#"LeftRingProximal",
		#"LeftLittleProximal",
		#"LeftThumbDistal",
		#"LeftIndexDistal",f
		#"LeftMiddleDistal",
		#"LeftRingDistal",
		#"LeftLittleDistal",
		#"RightLowerArm",
		"RightHand",
		#"RightThumbProximal",
		#"RightIndexProximal",
		#"RightMiddleProximal",
		#"RightRingProximal",
		#"RightLittleProximal",
		#"RightThumbDistal",
		#"RightIndexDistal",
		#"RightMiddleDistal",
		#"RightRingDistal",
		#"RightLittleDistal",
		#"LeftLowerLeg",
		#"RightLowerLeg",
		"LeftFoot",
		"RightFoot",
		"Head",
	]

	many_bone_ik.set_pin_count(0)
	many_bone_ik.set_pin_count(bones.size())

	var children: Array[Node] = root.find_children("*", "Marker3D")
	for i in range(children.size()):
		var node: Node = children[i] as Node
		if node == null:
			continue
		node.free()

	for pin_i in range(bones.size()):
		var bone_name = bones[pin_i]
		var targets_3d: Marker3D = Marker3D.new()
		targets_3d.gizmo_extents = .05
		many_bone_ik.add_child(targets_3d)
		targets_3d.owner = many_bone_ik.owner
		targets_3d.set_name(bone_name + "Marker3D")
		var bone_i: int = skeleton.find_bone(bone_name)
		if bone_i == -1:
			continue
		var pose: Transform3D = skeleton.get_bone_global_rest(bone_i)
		if bone_name in ["LeftFoot", "RightFoot"]:
			pose = pose.rotated(Vector3(1, 0, 0), -deg_to_rad(90))
		targets_3d.global_transform = pose
		many_bone_ik.set_pin_bone_name(pin_i, bone_name)
		if bone_name in ["Root", "LeftHand", "RightHand", "LeftFoot", "RightFoot"]:
			many_bone_ik.set_pin_passthrough_factor(pin_i, 0)
		else:
			many_bone_ik.set_pin_passthrough_factor(pin_i, 1)
		#var label_3d = preload("label_3d.gd").new()
		#label_3d.skeleton = skeleton
		#label_3d.font_size = 4
		#label_3d.no_depth_test = true
		#label_3d.bone_name = bone_name
		#label_3d.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		#targets_3d.add_child(label_3d, true)
		#label_3d.owner = targets_3d.owner


	for pin_i in range(bones.size()):
		var bone_name = bones[pin_i]
		many_bone_ik.set_pin_nodepath(pin_i, NodePath(bone_name + "Marker3D"))

	skeleton.show_rest_only = false

	var set_a: Array[Vector3] = []
	var set_b: Array[Vector3] = []

	#var reference_skeleton = many_bone_ik.owner.get_node("vrm_1_vsekai_godot_engine_humanoid_08/Root/Skeleton3D")
	#for bone_name in bones:
		#var bone_id = reference_skeleton.find_bone(bone_name)
		#if bone_id != -1:
			#var bone_position = reference_skeleton.get_bone_global_pose(bone_id).origin
			#set_a.append(bone_position)
		#else:
			#print("Bone '%s' not found!" % bone_name)
	#
	#var target_skeleton = many_bone_ik.owner.get_node("VVVV_200502/Armature/GeneralSkeleton")
	#for bone_name in bones:
		#var bone_id = target_skeleton.find_bone(bone_name)
		#if bone_id != -1:
			#var bone_position = target_skeleton.get_bone_global_pose(bone_id).origin
			#set_b.append(bone_position)
		#else:
			#print("Bone '%s' not found!" % bone_name)
	#var distance = chamfer_distance(set_a, set_b)
	#print(distance)

var bone_constraints: Dictionary

func get_bone_constraint(p_bone_name: String) -> BoneConstraint:
	if bone_constraints.has(p_bone_name):
		return bone_constraints[p_bone_name]
	else:
		return BoneConstraint.new()

func set_bone_constraint(many_bone_ik: ManyBoneIK3D, p_bone_name: String, p_twist_from: float, p_twist_range: float, p_kususdama: Array):
	bone_constraints[p_bone_name] = BoneConstraint.new(p_twist_from, p_twist_range, p_kususdama)
	var constraint_i = many_bone_ik.get_constraint_count()
	many_bone_ik.set_constraint_count(many_bone_ik.get_constraint_count() + 1)
	many_bone_ik.set_constraint_name(constraint_i, p_bone_name)
	many_bone_ik.set_kusudama_twist(constraint_i, Vector2(p_twist_from, p_twist_range))
	many_bone_ik.set_kusudama_limit_cone_count(constraint_i, 0)
	many_bone_ik.set_kusudama_limit_cone_count(constraint_i, p_kususdama.size())
	for cone_constraint_i: int in range(p_kususdama.size()):
		var cone_constraint = p_kususdama[cone_constraint_i]
		many_bone_ik.set_kusudama_limit_cone_center(constraint_i, cone_constraint_i, cone_constraint.direction)
		many_bone_ik.set_kusudama_limit_cone_radius(constraint_i, cone_constraint_i, cone_constraint.limit_angle)
