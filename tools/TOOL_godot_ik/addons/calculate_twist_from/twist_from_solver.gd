extends LBFGSBSolver

var bone_name: String
var skeleton: Skeleton3D
var many_bone_ik_node: ManyBoneIK3D

func _init(p_bone_name: String, p_skeleton: Skeleton3D, p_many_bone_ik_node: ManyBoneIK3D):
	bone_name = p_bone_name
	skeleton = p_skeleton
	many_bone_ik_node = p_many_bone_ik_node

func compute_pose_difference() -> Transform3D:
	var bone_idx = skeleton.find_bone(bone_name)
	var current_pose = skeleton.get_bone_global_pose(bone_idx)
	var rest_pose = skeleton.get_bone_rest(bone_idx)
	return rest_pose.affine_inverse() * current_pose

func compute_pose_difference_gradient(rest_pose: Transform3D, current_pose: Transform3D) -> Array[float]:
	# This is a simple numerical differentiation for the pose gradient.
	var epsilon = 0.0001
	var gradients = Vector3.ZERO
	for axis in range(3):
		var delta = Vector3.ZERO
		delta[axis] = epsilon
		var current_basis_rotated = current_pose.basis.rotated(Vector3(1, 0, 0), delta.x).rotated(Vector3(0, 1, 0), delta.y).rotated(Vector3(0, 0, 1), delta.z)
		var pose_plus_epsilon = Transform3D(current_basis_rotated, current_pose.origin + delta)
		var pose_minus_epsilon = Transform3D(current_pose.basis, current_pose.origin - delta)
		var diff_plus = rest_pose.affine_inverse() * pose_plus_epsilon
		var diff_minus = rest_pose.affine_inverse() * pose_minus_epsilon
		
		var gradient = (diff_plus.origin - diff_minus.origin).length() / (2.0 * epsilon)
		gradients[axis] = gradient
	return [gradients.x, gradients.y, gradients.z]

const DELTA: float = 0.00001

func compute_pose_difference_for(new_pose: Transform3D) -> Transform3D:
	many_bone_ik_node.advance(DELTA)
	var bone_idx = skeleton.find_bone(bone_name)
	var target_pose = skeleton.get_bone_global_pose(bone_idx)
	return new_pose.affine_inverse() * target_pose
	

func _call_operator(x: Array[float], gradient: Array[float]) -> float:
	var rest_pose: Transform3D = skeleton.get_bone_rest(skeleton.find_bone(bone_name))
	var result: Array = pose_objective_function(x, rest_pose)

	const EXPECTED_GRADIENT_SIZE := 4  # Updated expected size to include twist
	
	if result[1].size() != EXPECTED_GRADIENT_SIZE:
		push_error("Resulting gradient size does not match expected dimensions (expected %d, got %d)." % [EXPECTED_GRADIENT_SIZE, result[1].size()])
		return -1

	if gradient.size() != EXPECTED_GRADIENT_SIZE:
		push_error("Input gradient size does not match expected dimensions (expected %d, got %d)." % [EXPECTED_GRADIENT_SIZE, gradient.size()])
		return -1
	
	for i in range(EXPECTED_GRADIENT_SIZE):
		gradient[i] = result[1][i]
	return result[0]

func minimize_pose_and_twist():
	print(minimize_pose_and_twist)
	var bone_idx: int = skeleton.find_bone(bone_name)
	if bone_idx == -1:
		print("Bone not found")
		return

	var rest_pose: Transform3D = skeleton.get_bone_rest(bone_idx)
	var constraint_i = many_bone_ik_node.find_constraint(bone_name)
	if constraint_i == -1:
		print("Constraint not found")
		return
	var kusudama_twist: Vector2 = many_bone_ik_node.get_kusudama_twist(constraint_i)
	print("Start: %s" % str(rad_to_deg(kusudama_twist.x)))
	
	var n = 4  # Now optimizing over four variables, including the twist and x, y, z
	var lower_bounds: Array[float] = [-TAU, -INF, -INF, -INF]
	var upper_bounds: Array[float] = [TAU, INF, INF, INF]

	# Initial guess: twists and arbitrary values for other components
	var initial_guess = Array([kusudama_twist.x, 0.0, 0.0, 0.0])
	
	var result: Array = minimize(
		initial_guess,
		0,
		lower_bounds,
		upper_bounds
	)

	print("Iterations: %d" % result[0])
	print("Result: %s" % str(rad_to_deg(result[0])))

	# Set the new twist value from the first optimization variable
	kusudama_twist.x = result[1][0]
	many_bone_ik_node.set_kusudama_twist(constraint_i, kusudama_twist)

func pose_objective_function(x: Array[float], rest_pose: Transform3D) -> Array:
	# Apply the guesses to your bone to get new_pose
	var twist = x[0]
	var pose_gradient_vector = Vector3(x[1], x[2], x[3])

	var new_basis = rest_pose.basis.rotated(Vector3(0, 0, 1), twist)
	var new_origin = rest_pose.origin + pose_gradient_vector
	var new_pose = Transform3D(new_basis, new_origin)

	# Compute the difference between the new_pose and current global pose
	var diff_transform = compute_pose_difference_for(new_pose)

	# Quantify the difference using some metric; in this case, we'll use squared length of the origin vector
	# and a Frobenius norm of the matrix representing rotation.
	var position_diff = diff_transform.origin.length_squared()
	var rotation_diff = get_frobenius_norm_squared(diff_transform.basis)

	# Calculate the loss as the sum of squared differences
	var loss = position_diff + rotation_diff

	# Compute the gradient of the loss with respect to pose (x[1], x[2], x[3])
	var gradients: Array[float] = compute_pose_difference_gradient(rest_pose, new_pose)

	# Assume that computing the twist's direct gradient is challenging or not possible;
	# estimate its effect on the gradient by perturbing it slightly and observing the loss change.
	var tweak_amount = 0.0001
	var tweaked_twist = twist + tweak_amount
	var new_basis_tweaked = rest_pose.basis.rotated(Vector3(0, 0, 1), tweaked_twist)
	var new_pose_tweaked = Transform3D(new_basis_tweaked, new_origin)
	var diff_transform_tweaked = compute_pose_difference_for(new_pose_tweaked)
	var position_diff_tweaked = diff_transform_tweaked.origin.length_squared()
	var rotation_diff_tweaked = get_frobenius_norm_squared(diff_transform_tweaked.basis)
	var loss_tweaked = position_diff_tweaked + rotation_diff_tweaked

	# Estimate the gradient for twist by the rate of change in the loss with respect to the tweak amount
	var twist_gradient = (loss_tweaked - loss) / tweak_amount

	# Concatenate the twist gradient at the beginning of the gradients array
	gradients.insert(0, twist_gradient)

	return [loss, gradients]

func get_frobenius_norm_squared(basis: Basis) -> float:
	var sum: float = 0.0
	for i in range(3):
		for j in range(3):
			sum += pow(basis[i][j], 2)
	return sum
