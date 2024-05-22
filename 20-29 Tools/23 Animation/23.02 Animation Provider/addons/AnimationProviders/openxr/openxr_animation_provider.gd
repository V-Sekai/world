@tool
class_name OpenXRAnimationProvider
extends AnimationProvider


## OpenXR Hand Tracking Animation Provider
##
## This Animation Provider provides live OpenXR hand-tracking animation data.


## Bone Hierarchy Type
enum BoneHierarchy {
	PALM_WRIST,		## Hand skeleton relationsip is Palm -> Wrist -> Fingers
	WRIST_PALM,		## Hand skeleton relationsip is Wrist -> Palm -> Fingers
	PALM_ONLY,		## Hand skeleton relationsip is Palm -> Fingers
	WRIST_ONLY		## Hand skeleton relationsip is Wrist -> Fingers
}

## Skeleton Rig Type
enum SkeletonRig {
	OpenXR,			## Skeleton is rigged for OpenXR bones and rotation
	Humanoid		## Skeleton is rigged for Godot Humanoid bones and rotation
}

## Bone Update Type
enum BoneUpdate {
	FULL,			## Apply full tracking data (position and rotation)
	ROTATION_ONLY	## Apply only rotational data
}

# Array of bone names by SkeletonRig:HandJoints
const _bone_names = [
	[
		"Palm",					# OpenXRInterface.HAND_JOINT_PALM = 0
		"Wrist",				# OpenXRInterface.HAND_JOINT_WRIST = 1
		"Thumb_Metacarpal",		# OpenXRInterface.HAND_JOINT_THUMB_METACARPAL = 2
		"Thumb_Proximal",		# OpenXRInterface.HAND_JOINT_THUMB_PROXIMAL = 3
		"Thumb_Distal",			# OpenXRInterface.HAND_JOINT_THUMB_DISTAL = 4
		"Thumb_Tip",			# OpenXRInterface.HAND_JOINT_THUMB_TIP = 5
		"Index_Metacarpal",		# OpenXRInterface.HAND_JOINT_INDEX_METACARPAL = 6
		"Index_Proximal",		# OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL = 7
		"Index_Intermediate",	# OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE = 8
		"Index_Distal",			# OpenXRInterface.HAND_JOINT_INDEX_DISTAL = 9
		"Index_Tip",			# OpenXRInterface.HAND_JOINT_INDEX_TIP = 10
		"Middle_Metacarpal",	# OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL = 11
		"Middle_Proximal",		# OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL = 12
		"Middle_Intermediate",	# OpenXRInterface.HAND_JOINT_MIDDLE_INTERMEDIATE = 13
		"Middle_Distal",		# OpenXRInterface.HAND_JOINT_MIDDLE_DISTAL = 14
		"Middle_Tip",			# OpenXRInterface.HAND_JOINT_MIDDLE_TIP = 15
		"Ring_Metacarpal",		# OpenXRInterface.HAND_JOINT_RING_METACARPAL = 16
		"Ring_Proximal",		# OpenXRInterface.HAND_JOINT_RING_PROXIMAL = 17
		"Ring_Intermediate",	# OpenXRInterface.HAND_JOINT_RING_INTERMEDIATE = 18
		"Ring_Distal",			# OpenXRInterface.HAND_JOINT_RING_DISTAL = 19
		"Ring_Tip",				# OpenXRInterface.HAND_JOINT_RING_TIP = 20
		"Little_Metacarpal",	# OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL = 21
		"Little_Proximal",		# OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL = 22
		"Little_Intermediate",	# OpenXRInterface.HAND_JOINT_LITTLE_INTERMEDIATE = 23
		"Little_Distal",		# OpenXRInterface.HAND_JOINT_LITTLE_DISTAL = 24
		"Little_Tip"			# OpenXRInterface.HAND_JOINT_LITTLE_TIP = 25
	],
	[
		"Palm",					# OpenXRInterface.HAND_JOINT_PALM = 0
		"Hand",					# OpenXRInterface.HAND_JOINT_WRIST = 1
		"ThumbMetacarpal",		# OpenXRInterface.HAND_JOINT_THUMB_METACARPA
		"ThumbProximal",		# OpenXRInterface.HAND_JOINT_THUMB_PROXIMAL 
		"ThumbDistal",			# OpenXRInterface.HAND_JOINT_THUMB_DISTAL = 
		"ThumbTip",				# OpenXRInterface.HAND_JOINT_THUMB_TIP = 5
		"IndexMetacarpal",		# OpenXRInterface.HAND_JOINT_INDEX_METACARPA
		"IndexProximal",		# OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL 
		"IndexIntermediate",	# OpenXRInterface.HAND_JOINT_INDEX_INTERMEDI
		"IndexDistal",			# OpenXRInterface.HAND_JOINT_INDEX_DISTAL = 
		"IndexTip",				# OpenXRInterface.HAND_JOINT_INDEX_TIP = 10
		"MiddleMetacarpal",		# OpenXRInterface.HAND_JOINT_MIDDLE_METACARP
		"MiddleProximal",		# OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL
		"MiddleIntermediate",	# OpenXRInterface.HAND_JOINT_MIDDLE_INTERMED
		"MiddleDistal",			# OpenXRInterface.HAND_JOINT_MIDDLE_DISTAL =
		"MiddleTip",			# OpenXRInterface.HAND_JOINT_MIDDLE_TIP = 15
		"RingMetacarpal",		# OpenXRInterface.HAND_JOINT_RING_METACARPAL
		"RingProximal",			# OpenXRInterface.HAND_JOINT_RING_PROXIMAL =
		"RingIntermediate",		# OpenXRInterface.HAND_JOINT_RING_INTERMEDIA
		"RingDistal",			# OpenXRInterface.HAND_JOINT_RING_DISTAL = 1
		"RingTip",				# OpenXRInterface.HAND_JOINT_RING_TIP = 20
		"LittleMetacarpal",		# OpenXRInterface.HAND_JOINT_LITTLE_METACARP
		"LittleProximal",		# OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL
		"LittleIntermediate",	# OpenXRInterface.HAND_JOINT_LITTLE_INTERMED
		"LittleDistal",			# OpenXRInterface.HAND_JOINT_LITTLE_DISTAL =
		"LittleTip"				# OpenXRInterface.HAND_JOINT_LITTLE_TIP = 25
	]
]

# Array of bone names by SkeletonRig:Hand
const _bone_name_format = [
	[ ":<bone>_L", ":<bone>_R" ],
	[ ":Left<bone>", ":Right<bone>" ]
]

# Array of bone rotations by SkeletonRig
const _bone_rotations : Array[Quaternion] = [
	Quaternion.IDENTITY,
	Quaternion(0.0, -0.7071067811, 0.7071067811, 0.0)
]

# Array of parent bones by HandJoints
const _bone_parents : Array[int] = [
	-1,												# Palm -> (bone_hierarchy)
	-1,												# Wrist -> (bone_hierarchy)
	-1,												# Thumb_Metacarpal -> "hand"
	OpenXRInterface.HAND_JOINT_THUMB_METACARPAL, 	# Thumb_Proximal -> Thumb_Metacarpal
	OpenXRInterface.HAND_JOINT_THUMB_PROXIMAL,		# Thumb_Distal -> Thumb_Proximal
	OpenXRInterface.HAND_JOINT_THUMB_DISTAL,		# Thumb_Tip -> Thumb_Distal
	-1,												# Index_Metacarpal -> "hand"
	OpenXRInterface.HAND_JOINT_INDEX_METACARPAL,	# Index_Proximal -> Index_Metacarpal
	OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL,		# Index_Intermediate -> Index_Proximal
	OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE,	# Index_Distal -> Index_Intermediate
	OpenXRInterface.HAND_JOINT_INDEX_DISTAL,		# Index_Tip -> Index_Distal
	-1,												# Middle_Metacarpal -> "hand
	OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL,	# Middle_Proximal -> Middle_Metacarpal
	OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL,		# Middle_Intermediate -> Middle_Proximal
	OpenXRInterface.HAND_JOINT_MIDDLE_INTERMEDIATE,	# Middle_Distal -> Middle_Intermediate
	OpenXRInterface.HAND_JOINT_MIDDLE_DISTAL,		# Middle_Tip -> Middle_Distal
	-1,												# Ring_Metacarpal -> "hand"
	OpenXRInterface.HAND_JOINT_RING_METACARPAL,		# Ring_Proximal -> Ring_Metacarpal
	OpenXRInterface.HAND_JOINT_RING_PROXIMAL,		# Ring_Intermediate -> Ring_Proximal
	OpenXRInterface.HAND_JOINT_RING_INTERMEDIATE,	# Ring_Distal -> Ring_Intermediate
	OpenXRInterface.HAND_JOINT_RING_DISTAL,			# Ring_Tip -> Ring_Distal
	-1,												# Little_Metacarpal -> "hand"
	OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL,	# Little_Proximal -> Little_Metacarpal
	OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL,		# Little_Intermediate -> Little_Proximal
	OpenXRInterface.HAND_JOINT_LITTLE_INTERMEDIATE,	# Little_Distal -> Little_Intermediate
	OpenXRInterface.HAND_JOINT_LITTLE_DISTAL,		# Little_Tip -> Little_Distal
]


## Hand
@export_enum("Left", "Right") var hand : int = OpenXRInterface.HAND_LEFT : set = _set_hand

## Skeleton Rig
@export_enum("OpenXR", "Humanoid") var skeleton_rig : int = SkeletonRig.OpenXR : set = _set_skeleton_rig

## Bone hierarchy
@export var bone_hierarchy : BoneHierarchy = BoneHierarchy.PALM_WRIST : set = _set_bone_hierarchy

## Bone update animation format
@export var bone_update : BoneUpdate = BoneUpdate.FULL : set = _set_bone_update


# OpenXR animation instance
var _openxr_animation : Animation

# Bone names
var _names : Array[String] = []

# Bone parents
var _parents : Array[int] = []

# Bone positions
var _positions : Array[Vector3] = []

# Bone rotations
var _rotations : Array[Quaternion] = []

# Bone inverse rotations
var _rotations_inv : Array[Quaternion] = []

# Rotation tracks
var _rotation_tracks : Array[int] = []

# Position tracks
var _position_tracks : Array[int] = []


func _init() -> void:
	_names.resize(OpenXRInterface.HAND_JOINT_MAX)
	_parents.resize(OpenXRInterface.HAND_JOINT_MAX)
	_positions.resize(OpenXRInterface.HAND_JOINT_MAX)
	_rotations.resize(OpenXRInterface.HAND_JOINT_MAX)
	_rotations_inv.resize(OpenXRInterface.HAND_JOINT_MAX)
	_rotation_tracks.resize(OpenXRInterface.HAND_JOINT_MAX)
	_position_tracks.resize(OpenXRInterface.HAND_JOINT_MAX)


# Handle setting the hand
func _set_hand(p_hand : int) -> void:
	hand = p_hand
	if is_inside_tree() and _openxr_animation:
		_populate_animations()


# Handle setting the skeleton rig
func _set_skeleton_rig(p_skeleton_rig : int) -> void:
	skeleton_rig = p_skeleton_rig
	if is_inside_tree() and _openxr_animation:
		_populate_animations()


# Handle setting the bone hierarchy
func _set_bone_hierarchy(p_bone_hierarchy : BoneHierarchy) -> void:
	bone_hierarchy = p_bone_hierarchy
	if is_inside_tree() and _openxr_animation:
		_populate_animations()


# Handle setting the bone update mode
func _set_bone_update(p_bone_update : BoneUpdate) -> void:
	bone_update = p_bone_update
	if is_inside_tree() and _openxr_animation:
		_populate_animations()


# Initialize the animations
func _initialize_animations() -> void:
	# Get (or create) the animation
	if _library.has_animation("OpenXR"):
		_openxr_animation = _library.get_animation("OpenXR")
	else:
		_openxr_animation = Animation.new()
		_openxr_animation.resource_name = "OpenXR"
		_openxr_animation.resource_local_to_scene = true
		_openxr_animation.loop_mode = Animation.LOOP_LINEAR
		_library.add_animation("OpenXR", _openxr_animation)


# Populate the animations
func _populate_animations() -> void:
	# Populate the arrays
	var format : String = _bone_name_format[skeleton_rig][hand]
	for bone in OpenXRInterface.HAND_JOINT_MAX:
		_names[bone] = format.replace("<bone>", _bone_names[skeleton_rig][bone])
		_parents[bone] = _bone_parents[bone]
		_positions[bone] = Vector3.ZERO
		_rotations[bone] = Quaternion.IDENTITY
		_rotations_inv[bone] = Quaternion.IDENTITY
		_rotation_tracks[bone] = -1
		_position_tracks[bone] = -1

	# Patch parent bones based on bone hierarchy
	match bone_hierarchy:
		BoneHierarchy.PALM_WRIST:
			_parents[OpenXRInterface.HAND_JOINT_WRIST] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_THUMB_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_INDEX_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_RING_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST

		BoneHierarchy.WRIST_PALM:
			_parents[OpenXRInterface.HAND_JOINT_PALM] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_THUMB_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_INDEX_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_RING_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM

		BoneHierarchy.PALM_ONLY:
			_parents[OpenXRInterface.HAND_JOINT_THUMB_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_INDEX_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_RING_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM
			_parents[OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL] = OpenXRInterface.HAND_JOINT_PALM

		BoneHierarchy.WRIST_ONLY:
			_parents[OpenXRInterface.HAND_JOINT_THUMB_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_INDEX_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_RING_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST
			_parents[OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL] = OpenXRInterface.HAND_JOINT_WRIST

	# Construct the tracks
	_openxr_animation.clear()
	for bone in OpenXRInterface.HAND_JOINT_MAX:
		# If a bone has no parent then don't drive it
		if _parents[bone] < 0:
			continue

		# Construct the rotation track and key frame
		var rt := _openxr_animation.add_track(Animation.TYPE_ROTATION_3D)
		_rotation_tracks[bone] = rt
		_openxr_animation.track_set_path(rt, _names[bone])
		_openxr_animation.rotation_track_insert_key(rt, 0, Quaternion.IDENTITY)

		# Construct the position track and key frame
		if bone_update == BoneUpdate.FULL:
			var pt := _openxr_animation.add_track(Animation.TYPE_POSITION_3D)
			_position_tracks[bone] = pt
			_openxr_animation.track_set_path(pt, _names[bone])
			_openxr_animation.position_track_insert_key(pt, 0, Vector3.ZERO)


# Update the animations
func _update_animations() -> void:
	# Find the OpenXR interface and make sure it's initialized
	var xr := XRServer.find_interface("OpenXR") as OpenXRInterface
	if not xr or not xr.is_initialized():
		return

	# Read the hand-joint information
	var adjustment := _bone_rotations[skeleton_rig]
	for bone in OpenXRInterface.HAND_JOINT_MAX:
		var pos := xr.get_hand_joint_position(hand, bone)
		var rot := xr.get_hand_joint_rotation(hand, bone)
		_positions[bone] = pos
		_rotations[bone] = rot * adjustment
		_rotations_inv[bone] = rot.inverse()

	# Apply the animations
	for bone in OpenXRInterface.HAND_JOINT_MAX:
		# Get the parent joint (skip if none)
		var parent : int = _parents[bone]
		if parent < 0:
			continue

		# Set rotation
		var q := _rotations_inv[parent] * _rotations[bone]
		_openxr_animation.track_set_key_value(_rotation_tracks[bone], 0, q)

		# Set position if enabled
		if bone_update == BoneUpdate.FULL:
			var p := _rotations_inv[parent] * (_positions[bone] - _positions[parent])
			_openxr_animation.track_set_key_value(_position_tracks[bone], 0, p)
