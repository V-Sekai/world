@tool
extends EditorScript

class LimitCone:
	var direction: Vector3
	var angle: float

	func _init(direction: Vector3, angle: float):
		self.direction = direction
		self.angle = angle

class BoneConstraint:
	var forward_axis_twist_from: float
	var forward_axis_twist_range: float
	var swing_limit_cones: Array
	var resistance: float

	func _init(forward_axis_twist_from: float = 0, forward_axis_twist_range : float = TAU, swing_limit_cones: Array = [], resistance: float = 0):
		self.forward_axis_twist_from = forward_axis_twist_from
		self.forward_axis_twist_range = forward_axis_twist_range
		self.swing_limit_cones = swing_limit_cones
		self.resistance = resistance

var bone_names = ["Hips", "Spine", "Chest", "UpperChest", "Neck", "Head", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot", "LeftShoulder", "RightShoulder", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", "LeftThumb", "RightThumb"]
	
func _run():
	var root: Node = get_scene()
	var nodes : Array[Node] = root.find_children("*", "Skeleton3D")
	if nodes.is_empty():
		return
	var skeleton: Skeleton3D = nodes[0]
	var many_bone_ik_nodes : Array[Node] = skeleton.find_children("*", "ManyBoneIK3D")
	for ik_node: ManyBoneIK3D in many_bone_ik_nodes:
		ik_node.queue_free()
	var many_bone_ik: ManyBoneIK3D = ManyBoneIK3D.new()
	skeleton.add_child(many_bone_ik, true)
	many_bone_ik.name = "GeneralSkeletonIK"
	many_bone_ik.owner = skeleton.owner
	
	many_bone_ik.set_process_thread_group(Node.PROCESS_THREAD_GROUP_SUB_THREAD)
	many_bone_ik.set_process_thread_group_order(100)

	skeleton.show_rest_only = true
	skeleton.reset_bone_poses()
	many_bone_ik.set_constraint_count(0)
	var skeleton_profile: SkeletonProfileHumanoid = SkeletonProfileHumanoid.new()
	for bone_name_i in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(bone_name_i)
		var swing_limit_cones = []
		var bone_i = skeleton_profile.find_bone(bone_name)
		if bone_i == -1:
			continue
		var forward_axis_twist_range = PI * 2
		var forward_axis_twist_from = 0
		var resistance = 0

		# The humanoid is T-pose
		#	
		# The humanoid is facing +Z in the Right-Handed Y-UP Coordinate System
		# The humanoid should not have a Transform as Node
		# Directs the +Y axis from the parent joint to the child joint
		# +X rotation bends the joint like a muscle contracting
	
		if bone_name == "Hips":
			forward_axis_twist_from = deg_to_rad(0.0)
			forward_axis_twist_range = deg_to_rad(360)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(3.0)))
		elif bone_name in ["LeftFoot", "RightFoot"]:
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_REAR) / 2.0).normalized(), deg_to_rad(2.5)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0)))
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_REAR) / 2.0).normalized(), deg_to_rad(2.5)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0)))
			#
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_REAR) / 2.0).normalized(), deg_to_rad(23.0)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0)))
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_REAR) / 2.0).normalized(), deg_to_rad(24.0)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0)))
		elif bone_name == "Spine":
			forward_axis_twist_from = deg_to_rad(4.0)
			forward_axis_twist_range = deg_to_rad(360)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(3.0)))
			resistance = 0.5
		elif bone_name == "Chest":
			forward_axis_twist_from = deg_to_rad(5.0)
			forward_axis_twist_range = deg_to_rad(-10.0)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(3.0)))
			resistance = 0.5
		elif bone_name == "UpperChest":
			forward_axis_twist_from = deg_to_rad(10.0)
			forward_axis_twist_range = deg_to_rad(40.0)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0)))
			resistance = 0.6
		elif bone_name == "Neck":
			forward_axis_twist_from = deg_to_rad(15.0)
			forward_axis_twist_range = deg_to_rad(15.0)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0)))
			resistance = 0.6
		elif bone_name == "Head":
			forward_axis_twist_from = deg_to_rad(15.0)
			forward_axis_twist_range = deg_to_rad(15.0)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(15.0)))
			resistance = 0.7
		elif bone_name.find("Eye") != -1:
			continue
		elif bone_name == "LeftUpperLeg":
			forward_axis_twist_from = deg_to_rad(0.0)
			forward_axis_twist_range = deg_to_rad(5.0)
		elif bone_name == "LeftLowerLeg":
			forward_axis_twist_from = deg_to_rad(-90)
			forward_axis_twist_range = deg_to_rad(5.0)
		elif bone_name == "RightUpperLeg":
			forward_axis_twist_from = deg_to_rad(0.0)
			forward_axis_twist_range = deg_to_rad(5.0)
		elif bone_name == "RightLowerLeg":
			forward_axis_twist_from = deg_to_rad(-90)
			forward_axis_twist_range = deg_to_rad(5.0)
		elif bone_name in ["LeftShoulder", "RightShoulder"]:
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(30.0)))
		elif bone_name in ["LeftUpperArm", "RightUpperArm"]:
			forward_axis_twist_from = deg_to_rad(80.0)
			forward_axis_twist_range = deg_to_rad(12.0)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0)))
			resistance = 0.3
		elif bone_name == "LeftLowerArm":
			forward_axis_twist_from = deg_to_rad(-55.0)
			forward_axis_twist_range = deg_to_rad(50.0)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5)))
			resistance = 0.4
		elif bone_name == "RightLowerArm":
			forward_axis_twist_from = deg_to_rad(-145.0)
			forward_axis_twist_range = deg_to_rad(50.0)
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5)))
			resistance = 0.4
		elif bone_name in ["LeftHand", "RightHand"]:
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)))
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)))
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)))
			swing_limit_cones.append(LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)))
			swing_limit_cones.append(LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)))
		elif bone_name in ["LeftThumb", "RightThumb"]:
			pass
		else:
			continue
		set_bone_constraint(many_bone_ik, bone_name, forward_axis_twist_from, forward_axis_twist_range, swing_limit_cones, resistance)

	var bones: Array = [
		"Root",
		"Head",
		"Chest",
		"LeftLowerArm",
		"LeftHand",
		"RightLowerArm",
		"RightHand",
		"Hips",
		"LeftLowerLeg",
		"LeftFoot",
		"RightLowerLeg",
		"RightFoot",
	]

	many_bone_ik.set_pin_count(0)
	many_bone_ik.set_pin_count(bones.size())

	var children: Array[Node] = root.find_children("*", "Marker3D")
	for i in range(children.size()):
		var node: Node = children[i] as Node
		node.queue_free()
	
	for pin_i in range(bones.size()):
		var bone_name: String = bones[pin_i]
		var marker_3d: Marker3D = Marker3D.new()
		marker_3d.name = bone_name
		many_bone_ik.add_child(marker_3d, true)
		marker_3d.owner = root
		var bone_i: int = skeleton.find_bone(bone_name)
		if bone_i == -1:
			printerr("Bone not found: %s" % bone_name)
			continue
		var pose: Transform3D =  skeleton.get_bone_global_rest(bone_i)
		marker_3d.global_transform = pose
		many_bone_ik.set_pin_nodepath(pin_i, many_bone_ik.get_path_to(marker_3d))
		many_bone_ik.set_pin_bone_name(pin_i, bone_name)
		if bone_name in ["Root", "Hips"]:
			continue
		many_bone_ik.set_pin_passthrough_factor(pin_i, 1.0)

	skeleton.show_rest_only = false
var bone_constraints: Dictionary

func get_bone_constraint(p_bone_name: String) -> BoneConstraint:
	if bone_constraints.has(p_bone_name):
		return bone_constraints[p_bone_name]
	else:
		return BoneConstraint.new()

func set_bone_constraint(many_bone_ik: ManyBoneIK3D, p_bone_name: String, p_twist_from: float, p_twist_range: float, p_swing_limit_cones: Array, p_resistance: float = 0.0):
	bone_constraints[p_bone_name] = BoneConstraint.new(p_twist_from, p_twist_range, p_swing_limit_cones, p_resistance)
	var constraint_count = many_bone_ik.get_constraint_count()
	many_bone_ik.set_constraint_count(constraint_count + 1)
	many_bone_ik.set_constraint_name(constraint_count, p_bone_name)
	many_bone_ik.set_kusudama_resistance(constraint_count, p_resistance)
	many_bone_ik.set_kusudama_twist(constraint_count, Vector2(p_twist_from, p_twist_range))
	many_bone_ik.set_kusudama_limit_cone_count(constraint_count, p_swing_limit_cones.size())
	for cone_constraint_i: int in range(p_swing_limit_cones.size()):
		var cone_constraint: LimitCone = p_swing_limit_cones[cone_constraint_i]
		many_bone_ik.set_kusudama_limit_cone_center(constraint_count, cone_constraint_i, cone_constraint.direction)
		many_bone_ik.set_kusudama_limit_cone_radius(constraint_count, cone_constraint_i, cone_constraint.angle)
