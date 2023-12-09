extends Control

var lasso_db : LassoDB = LassoDB.new()

var points : Array[Node3D] = []

func _ready():
#	DisplayServer.window_set_mouse_passthrough($Path2D.curve.get_baked_points())
	set_process_input(true)
	var hips : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/Hips
	var head : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/Head
	var left_hand : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/LeftLowerArm
	var left_elbow : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/LeftHand
	var right_hand : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/RightLowerArm
	var right_elbow : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/RightHand
	var left_knee : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/LeftLowerLeg
	var left_foot : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/LeftFoot
	var right_knee : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/RightLowerLeg
	var right_foot : Node3D = $SubViewport/Node3D/Frogdude/Frogdude2/RootNode/GeneralSkeleton/ManyBoneIK3D/RightFoot
	points.append_array([hips, head, left_hand, right_hand, left_foot, right_foot, left_elbow, right_elbow, left_knee, right_knee])

	for point in points:
		for child in point.get_children():
			child.visible = false
		var lasso_point : LassoPoint = LassoPoint.new()
		lasso_point.register_point(lasso_db, point)

var dragging = false

func _input(event):	
	var pointer : Node3D = $SubViewport/Pointer
	var pointer_secondary : Node3D = $SubViewport/PointerSecondary
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
		elif event.button_mask == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false

	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT and dragging:
		var motion = event.relative * 0.0008
		pointer.global_transform.origin = pointer.global_transform.origin + Vector3(motion.x, -motion.y, 0.0)
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_RIGHT and dragging:
		var motion = event.relative * 0.0008
		var viewport : Transform3D = $SubViewport/Camera3D.get_camera_transform()
		var snapped_nodes : Array = lasso_db.calc_top_two_snapping_power(pointer.global_transform, pointer, 1, 1, true)
		var pointers = [pointer, pointer_secondary]
		for snapped_point_i in range(snapped_nodes.size()):
			var snapped_node = snapped_nodes[snapped_point_i].get_origin()
			$SubViewport/Label3D.text = snapped_node.get_name()
			var snapped_transform : Transform3D = Transform3D()
			snapped_transform = snapped_node.global_transform
			snapped_transform.origin = snapped_transform.origin + Vector3(motion.x, -motion.y, 0.0)
			snapped_node.global_transform = snapped_transform
			if snapped_point_i == 1:
				pointers[snapped_point_i].global_transform = snapped_node.global_transform
