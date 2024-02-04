extends LBFGSBSolver

# The code below is responsible for setting up and solving an optimization problem to minimize the difference
# between a desired pose and the current pose of a skeleton being animated using inverse kinematics.

var bone_name: String
var skeleton: Skeleton3D
var many_bone_ik_node: ManyBoneIK3D

# Constructor for the solver class.
func _init(p_bone_name: String, p_skeleton: Skeleton3D, p_many_bone_ik_node: ManyBoneIK3D):
	bone_name = p_bone_name
	skeleton = p_skeleton
	many_bone_ik_node = p_many_bone_ik_node

# Computes the transform that represents the difference between the current pose of a bone and its rest pose.
func compute_pose_difference() -> Transform3D:
	var bone_idx = skeleton.find_bone(bone_name)
	if bone_idx == -1:
		return Transform3D.IDENTITY
	var current_pose = skeleton.get_bone_global_pose(bone_idx)
	var rest_pose = skeleton.get_bone_rest(bone_idx)
	return rest_pose.affine_inverse() * current_pose

# Evaluates the gradient (numerical differentiation) of the pose difference with respect to small perturbations in the pose.
func compute_pose_difference_gradient(rest_pose: Transform3D, current_pose: Transform3D) -> Array[float]:
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


func _call_operator(x: Array, gradient: Array) -> float:
	# Initialize variables to collect the gradient data and objective values
	var full_gradient: Array
	var accumulated_objective_value: float = 0
	var total_bone_count: int = 0

	for constraint_i in range(total_bone_count):
		var bone_name = many_bone_ik_node.get_constraint_name(constraint_i)
		var bone_idx = skeleton.find_bone(bone_name)
		if bone_idx == -1:
			continue
		var rest_pose: Transform3D = skeleton.get_bone_rest(bone_idx)
		var bone_result: Array = pose_objective_function(x, rest_pose)
		
		if bone_result[1].size() != 4:
			push_error("One of the bone's gradient size does not match the expected size (expected 4, got %d)." % bone_result[1].size())
			return -1
		# Append the gradient for the current bone to the full gradient array
		full_gradient.append_array(bone_result[1])
		# Accumulate objective function values across all bones
		accumulated_objective_value += bone_result[0]
		total_bone_count += 4
	
	if full_gradient.size() != total_bone_count:
		push_error("Resulting gradient size does not match expected dimensions (expected %d, got %d)." % [total_bone_count, full_gradient.size()])
		return -1

	# Copy the full gradient to the provided gradient parameter
	for i in range(total_bone_count):
		gradient[i] = full_gradient[i]

	return accumulated_objective_value
	

func minimize_pose_and_twist():
	print("minimize_pose_and_twist")
	var bone_idx: int = skeleton.find_bone(bone_name)
	if bone_idx == -1:
		print("Bone '%s' not found" % bone_name)
		return

	var rest_pose: Transform3D = skeleton.get_bone_rest(bone_idx)
	var constraint_i = many_bone_ik_node.find_constraint(bone_name)
	if constraint_i == -1:
		print("Constraint for bone '%s' not found" % bone_name)
		return
	var kusudama_twist: Vector2 = many_bone_ik_node.get_kusudama_twist(constraint_i)
	print("Start: %s" % str(kusudama_twist.x))

	var n = 4 *many_bone_ik_node.get_constraint_count()
	
	# Defines lower and upper bounds for each variable in the optimization problem.
	var lower_bounds: Array[float] = []
	var upper_bounds: Array[float] = []
	for i in range(many_bone_ik_node.get_constraint_count()):
		lower_bounds += [-TAU, -INF, -INF, -INF]
		upper_bounds += [TAU, INF, INF, INF]

	# Sets the initial guess for the optimization variables.
	var initial_guess = []
	for i in range(many_bone_ik_node.get_constraint_count()):
		initial_guess.append(0)  # Twist
		initial_guess.append(TAU)  # x
		initial_guess.append(TAU)  # y
		initial_guess.append(TAU)  # z

	# Calls the optimizer with the objective function, initial guess, and bounds.
	var result: Array = minimize(
		initial_guess,
		0,
		lower_bounds,
		upper_bounds
	)

	# Processes the results from the optimizer.
	print("Iterations: %d" % result[0])
	print("Result: %s" % str(result[1]))
	for result_constraint_i in range(many_bone_ik_node.get_constraint_count()):
		var twist = many_bone_ik_node.get_kusudama_twist(result_constraint_i)
		twist.x = result[1][result_constraint_i]
		many_bone_ik_node.set_kusudama_twist(result_constraint_i, twist)


func pose_objective_function(x: Array[float], rest_pose: Transform3D) -> Array:
	# The identity transform is used as a starting point for calculating differences.
	var diff_transform = Transform3D.IDENTITY
	
	# DELTA represents a small change used for numerical approximation of the gradient.
	const DELTA: float = 1 / 144
	# Advance the many bone IK node by a small amount to simulate movement.
	many_bone_ik_node.advance(DELTA)
	# Find the constraint associated with our target bone.
	var constraint_idx = many_bone_ik_node.find_constraint(bone_name)
	if constraint_idx != -1:
		# Retrieve the index of the bone from the skeleton.
		var bone_idx = skeleton.find_bone(bone_name)
		# Get the new global pose of the bone after advancing the IK node.
		var target_pose = skeleton.get_bone_global_pose(bone_idx)
		# Calculate the difference between the rest pose and the current pose.
		diff_transform = rest_pose.affine_inverse() * target_pose

	# Determine the squared distance of the position part of the transform.
	var position_diff = diff_transform.origin.length_squared()
	# Calculate the squared Frobenius norm of the rotation part (basis matrix).
	var rotation_diff = get_frobenius_norm_squared(diff_transform.basis)

	# Loss is defined as a sum of squared differences in position and rotation.
	var loss = position_diff + rotation_diff

	# Compute the gradient of the pose difference.
	var gradients: Array[float] = compute_pose_difference_gradient(rest_pose, diff_transform)

	# Tweak the original pose by some amount to compute numerical gradient for the twist.
	var tweak_amount = DELTA
	var new_basis_tweaked = diff_transform.basis.rotated(Vector3(0, 1, 0), tweak_amount)
	var new_origin = diff_transform.origin # Assuming origin doesn't need tweaking
	var new_pose_tweaked = Transform3D(new_basis_tweaked, new_origin)
	var diff_transform_tweaked = compute_pose_difference_gradient(rest_pose, new_pose_tweaked)
	var position_diff_tweaked = diff_transform_tweaked.origin.length_squared()
	var rotation_diff_tweaked = get_frobenius_norm_squared(diff_transform_tweaked.basis)
	var loss_tweaked = position_diff_tweaked + rotation_diff_tweaked

	# Compute the gradient of the twist as the difference in loss divided by the tweak amount.
	var twist_gradient = (loss_tweaked - loss) / tweak_amount

	# Insert the twist gradient at the beginning of the gradients array.
	gradients.insert(0, twist_gradient)

	# Return the loss accompanied by the array of gradients.
	return [loss, gradients]


func get_frobenius_norm_squared(basis: Basis) -> float:
	var sum: float = 0.0
	for i in range(3):
		for j in range(3):
			sum += pow(basis[i][j], 2)
	return sum
