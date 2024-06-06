@tool
class_name AxisStudioAnimationProvider
extends AnimationProvider


## Axis Studio Animation Provider
##
## This Animation Provider provides live mocap data from Axis Studio.[br]
## [br]
## Axis Studio must be configured for BVH Broadcasting with:[br]
## - skeleton: Axis Studio[br]
## - rotation: YXZ[br]
## - displacement: on[br]
## - format: Binary[br]
## - coordinate system: OPT[br]


## Skeleton Rig Type
enum SkeletonRig {
	AxisStudio,		## Skeleton is rigged for Axis Studio bones and rotation
	Humanoid		## Skeleton is rigged for Godot Humanoid bones and rotation
}

## Bone Update Type
enum BoneUpdate {
	FULL,			## Apply full tracking data (position and rotation)
	ROTATION_ONLY	## Apply only rotational data
}

## Axis Studio Bones
enum AxisStudioBone {
	HIPS = 0,
	RIGHT_UP_LEG = 1,
	RIGHT_LEG = 2,
	RIGHT_FOOT = 3,
	LEFT_UP_LEG = 4,
	LEFT_LEG = 5,
	LEFT_FOOT = 6,
	SPINE = 7,
	SPINE_1 = 8,
	SPINE_2 = 9,
	SPINE_3 = 10,
	NECK = 11,
	HEAD = 12,
	RIGHT_SHOULDER = 13,
	RIGHT_ARM = 14,
	RIGHT_FORE_ARM = 15,
	RIGHT_HAND = 16,
	RIGHT_HAND_THUMB_1 = 17,
	RIGHT_HAND_THUMB_2 = 18,
	RIGHT_HAND_THUMB_3 = 19,
	RIGHT_IN_HAND_INDEX = 20,
	RIGHT_HAND_INDEX_1 = 21,
	RIGHT_HAND_INDEX_2 = 22,
	RIGHT_HAND_INDEX_3 = 23,
	RIGHT_IN_HAND_MIDDLE = 24,
	RIGHT_HAND_MIDDLE_1 = 25,
	RIGHT_HAND_MIDDLE_2 = 26,
	RIGHT_HAND_MIDDLE_3 = 27,
	RIGHT_IN_HAND_RING = 28,
	RIGHT_HAND_RING_1 = 29,
	RIGHT_HAND_RING_2 = 30,
	RIGHT_HAND_RING_3 = 31,
	RIGHT_IN_HAND_PINKY = 32,
	RIGHT_HAND_PINKY_1 = 33,
	RIGHT_HAND_PINKY_2 = 34,
	RIGHT_HAND_PINKY_3 = 35,
	LEFT_SHOULDER = 36,
	LEFT_ARM = 37,
	LEFT_FORE_ARM = 38,
	LEFT_HAND = 39,
	LEFT_HAND_THUMB_1 = 40,
	LEFT_HAND_THUMB_2 = 41,
	LEFT_HAND_THUMB_3 = 42,
	LEFT_IN_HAND_INDEX = 43,
	LEFT_HAND_INDEX_1 = 44,
	LEFT_HAND_INDEX_2 = 45,
	LEFT_HAND_INDEX_3 = 46,
	LEFT_IN_HAND_MIDDLE = 47,
	LEFT_HAND_MIDDLE_1 = 48,
	LEFT_HAND_MIDDLE_2 = 49,
	LEFT_HAND_MIDDLE_3 = 50,
	LEFT_IN_HAND_RING = 51,
	LEFT_HAND_RING_1 = 52,
	LEFT_HAND_RING_2 = 53,
	LEFT_HAND_RING_3 = 54,
	LEFT_IN_HAND_PINKY = 55,
	LEFT_HAND_PINKY_1 = 56,
	LEFT_HAND_PINKY_2 = 57,
	LEFT_HAND_PINKY_3 = 58,
	COUNT = 59
}

# Array of bone names by SkeletonRig:AxisStudioBone
const _bone_names = [
	[
		"Hips",						# AxisStudioBone.HIPS
		"RightUpLeg",				# AxisStudioBone.RIGHT_UP_LEG  
		"RightLeg",					# AxisStudioBone.RIGHT_LEG
		"RightFoot",				# AxisStudioBone.RIGHT_FOOT
		"LeftUpLeg",				# AxisStudioBone.LEFT_UP_LEG
		"LeftLeg",					# AxisStudioBone.LEFT_LEG
		"LeftFoot",					# AxisStudioBone.LEFT_FOOT
		"Spine",					# AxisStudioBone.SPINE
		"Chest",					# AxisStudioBone.SPINE_1
		"UpperChest",				# AxisStudioBone.SPINE_2
		"Neck1",					# AxisStudioBone.SPINE_3
		"Neck",						# AxisStudioBone.NECK
		"Head",						# AxisStudioBone.HEAD
		"RightShoulder",			# AxisStudioBone.RIGHT_SHOULDER
		"RightArm",					# AxisStudioBone.RIGHT_ARM
		"RightForeArm",				# AxisStudioBone.RIGHT_FORE_ARM
		"RightHand",				# AxisStudioBone.RIGHT_HAND
		"RightHandThumb1",			# AxisStudioBone.RIGHT_HAND_THUMB_1
		"RightHandThumb2",			# AxisStudioBone.RIGHT_HAND_THUMB_2
		"RightHandThumb3",			# AxisStudioBone.RIGHT_HAND_THUMB_3
		"RightInHandIndex",			# AxisStudioBone.RIGHT_IN_HAND_INDEX
		"RightHandIndex1",			# AxisStudioBone.RIGHT_HAND_INDEX_1
		"RightHandIndex2",			# AxisStudioBone.RIGHT_HAND_INDEX_2
		"RightHandIndex3",			# AxisStudioBone.RIGHT_HAND_INDEX_3
		"RightInHandMiddle",		# AxisStudioBone.RIGHT_IN_HAND_MIDDLE
		"RightHandMiddle1",			# AxisStudioBone.RIGHT_HAND_MIDDLE_1
		"RightHandMiddle2",			# AxisStudioBone.RIGHT_HAND_MIDDLE_2
		"RightHandMiddle3",			# AxisStudioBone.RIGHT_HAND_MIDDLE_3
		"RightInHandRing",			# AxisStudioBone.RIGHT_IN_HAND_RING
		"RightHandRing1",			# AxisStudioBone.RIGHT_HAND_RING_1
		"RightHandRing2",			# AxisStudioBone.RIGHT_HAND_RING_2
		"RightHandRing3",			# AxisStudioBone.RIGHT_HAND_RING_3
		"RightInHandPinky",			# AxisStudioBone.RIGHT_IN_HAND_PINKY
		"RightHandPinky1",			# AxisStudioBone.RIGHT_HAND_PINKY_1
		"RightHandPinky2",			# AxisStudioBone.RIGHT_HAND_PINKY_2
		"RightHandPinky3",			# AxisStudioBone.RIGHT_HAND_PINKY_3
		"LeftShoulder",				# AxisStudioBone.LEFT_SHOULDER
		"LeftArm",					# AxisStudioBone.LEFT_ARM
		"LeftForeArm",				# AxisStudioBone.LEFT_FORE_ARM
		"LeftHand",					# AxisStudioBone.LEFT_HAND
		"LeftHandThumb1",			# AxisStudioBone.LEFT_HAND_THUMB_1
		"LeftHandThumb2",			# AxisStudioBone.LEFT_HAND_THUMB_2
		"LeftHandThumb3",			# AxisStudioBone.LEFT_HAND_THUMB_3
		"LeftInHandIndex",			# AxisStudioBone.LEFT_IN_HAND_INDEX
		"LeftHandIndex1",			# AxisStudioBone.LEFT_HAND_INDEX_1
		"LeftHandIndex2",			# AxisStudioBone.LEFT_HAND_INDEX_2
		"LeftHandIndex3",			# AxisStudioBone.LEFT_HAND_INDEX_3
		"LeftInHandMiddle",			# AxisStudioBone.LEFT_IN_HAND_MIDDLE
		"LeftHandMiddle1",			# AxisStudioBone.LEFT_HAND_MIDDLE_1
		"LeftHandMiddle2",			# AxisStudioBone.LEFT_HAND_MIDDLE_2
		"LeftHandMiddle3",			# AxisStudioBone.LEFT_HAND_MIDDLE_3
		"LeftInHandRing",			# AxisStudioBone.LEFT_IN_HAND_RING
		"LeftHandRing1",			# AxisStudioBone.LEFT_HAND_RING_1
		"LeftHandRing2",			# AxisStudioBone.LEFT_HAND_RING_2
		"LeftHandRing3",			# AxisStudioBone.LEFT_HAND_RING_3
		"LeftInHandPinky",			# AxisStudioBone.LEFT_IN_HAND_PINKY
		"LeftHandPinky1",			# AxisStudioBone.LEFT_HAND_PINKY_1
		"LeftHandPinky2",			# AxisStudioBone.LEFT_HAND_PINKY_2
		"LeftHandPinky3"			# AxisStudioBone.LEFT_HAND_PINKY_3
	],
	[
		"Hips",						# AxisStudioBone.HIPS
		"RightUpperLeg",			# AxisStudioBone.RIGHT_UP_LEG  
		"RightlowerLeg",			# AxisStudioBone.RIGHT_LEG
		"RightFoot",				# AxisStudioBone.RIGHT_FOOT
		"LeftUpperLeg",				# AxisStudioBone.LEFT_UP_LEG
		"LeftLowerLeg",				# AxisStudioBone.LEFT_LEG
		"LeftFoot",					# AxisStudioBone.LEFT_FOOT
		"Spine",					# AxisStudioBone.SPINE
		"Chest",					# AxisStudioBone.SPINE_1
		"UpperChest",				# AxisStudioBone.SPINE_2
		"Spine3",					# AxisStudioBone.SPINE_3
		"Neck",						# AxisStudioBone.NECK
		"Head",						# AxisStudioBone.HEAD
		"RightShoulder",			# AxisStudioBone.RIGHT_SHOULDER
		"RightUpperArm",			# AxisStudioBone.RIGHT_ARM
		"RightLowerArm",			# AxisStudioBone.RIGHT_FORE_ARM
		"RightHand",				# AxisStudioBone.RIGHT_HAND
		"RightThumbMetacarpal",		# AxisStudioBone.RIGHT_HAND_THUMB_1
		"RightThumbProximal",		# AxisStudioBone.RIGHT_HAND_THUMB_2
		"RightThumbDistal",			# AxisStudioBone.RIGHT_HAND_THUMB_3
		"RightIndexMetacarpal",		# AxisStudioBone.RIGHT_IN_HAND_INDEX
		"RightIndexProximal",		# AxisStudioBone.RIGHT_HAND_INDEX_1
		"RightIndexIntermediate",	# AxisStudioBone.RIGHT_HAND_INDEX_2
		"RightIndexDistal",			# AxisStudioBone.RIGHT_HAND_INDEX_3
		"RightMiddleMetacarpal",	# AxisStudioBone.RIGHT_IN_HAND_MIDDLE
		"RightMiddleProximal",		# AxisStudioBone.RIGHT_HAND_MIDDLE_1
		"RightMiddleIntermediate",	# AxisStudioBone.RIGHT_HAND_MIDDLE_2
		"RightMiddleDistal",		# AxisStudioBone.RIGHT_HAND_MIDDLE_3
		"RightRingMetacarpal",		# AxisStudioBone.RIGHT_IN_HAND_RING
		"RightRingProximal",		# AxisStudioBone.RIGHT_HAND_RING_1
		"RightRingIntermediate",	# AxisStudioBone.RIGHT_HAND_RING_2
		"RightRingDistal",			# AxisStudioBone.RIGHT_HAND_RING_3
		"RightLittleMetacarpal",	# AxisStudioBone.RIGHT_IN_HAND_PINKY
		"RightLittleProximal",		# AxisStudioBone.RIGHT_HAND_PINKY_1
		"RightLittleIntermediate",	# AxisStudioBone.RIGHT_HAND_PINKY_2
		"RightLittleDistal",		# AxisStudioBone.RIGHT_HAND_PINKY_3
		"LeftShoulder",				# AxisStudioBone.LEFT_SHOULDER
		"LeftUpperArm",				# AxisStudioBone.LEFT_ARM
		"LeftLowerArm",				# AxisStudioBone.LEFT_FORE_ARM
		"LeftHand",					# AxisStudioBone.LEFT_HAND
		"LeftThumbMetacarpal",		# AxisStudioBone.LEFT_HAND_THUMB_1
		"LeftThumbProximal",		# AxisStudioBone.LEFT_HAND_THUMB_2
		"LeftThumbDistal",			# AxisStudioBone.LEFT_HAND_THUMB_3
		"LeftIndexMetacarpal",		# AxisStudioBone.LEFT_IN_HAND_INDEX
		"LeftIndexProximal",		# AxisStudioBone.LEFT_HAND_INDEX_1
		"LeftIndexIntermediate",	# AxisStudioBone.LEFT_HAND_INDEX_2
		"LeftIndexDistal",			# AxisStudioBone.LEFT_HAND_INDEX_3
		"LeftMiddleMetacarpal",		# AxisStudioBone.LEFT_IN_HAND_MIDDLE
		"LeftMiddleProximal",		# AxisStudioBone.LEFT_HAND_MIDDLE_1
		"LeftMiddleIntermediate",	# AxisStudioBone.LEFT_HAND_MIDDLE_2
		"LeftMiddleDistal",			# AxisStudioBone.LEFT_HAND_MIDDLE_3
		"LeftRingMetacarpal",		# AxisStudioBone.LEFT_IN_HAND_RING
		"LeftRingProximal",			# AxisStudioBone.LEFT_HAND_RING_1
		"LeftRingIntermediate",		# AxisStudioBone.LEFT_HAND_RING_2
		"LeftRingDistal",			# AxisStudioBone.LEFT_HAND_RING_3
		"LeftLittleMetacarpal",		# AxisStudioBone.LEFT_IN_HAND_PINKY
		"LeftLittleProximal",		# AxisStudioBone.LEFT_HAND_PINKY_1
		"LeftLittleIntermediate",	# AxisStudioBone.LEFT_HAND_PINKY_2
		"LeftLittleDistal"			# AxisStudioBone.LEFT_HAND_PINKY_3
	]
]

# Array of parent bones by AxisStudioBone
const _bone_parents : Array[int] = [
	-1,										# HIPS -> nothing
	AxisStudioBone.HIPS,					# RIGHT_UP_LEG -> HIPS
	AxisStudioBone.RIGHT_UP_LEG,			# RIGHT_LEG -> RIGHT_UP_LEG
	AxisStudioBone.RIGHT_LEG,				# RIGHT_FOOT -> RIGHT_LEG
	AxisStudioBone.HIPS,					# LEFT_UP_LEG -> HIPS
	AxisStudioBone.LEFT_UP_LEG,				# LEFT_LEG -> LEFT_UP_LEG
	AxisStudioBone.LEFT_LEG,				# LEFT_FOOT -> LEFT_LEG
	AxisStudioBone.HIPS,					# SPINE -> HIPS
	AxisStudioBone.SPINE,					# SPINE_1 -> SPINE
	AxisStudioBone.SPINE_1,					# SPINE_2 -> SPINE_1
	AxisStudioBone.SPINE_2,					# SPINE_3 -> SPINE_2
	AxisStudioBone.SPINE_3,					# NECK -> SPINE_3
	AxisStudioBone.NECK,					# HEAD -> NECK
	AxisStudioBone.SPINE_2,					# RIGHT_SHOULDER -> SPINE_2
	AxisStudioBone.RIGHT_SHOULDER,			# RIGHT_ARM -> RIGHT_SHOULDER
	AxisStudioBone.RIGHT_ARM,				# RIGHT_FORE_ARM -> RIGHT_ARM
	AxisStudioBone.RIGHT_FORE_ARM,			# RIGHT_HAND -> RIGHT_FORE_ARM
	AxisStudioBone.RIGHT_HAND,				# RIGHT_HAND_THUMB_1 -> RIGHT_HAND
	AxisStudioBone.RIGHT_HAND_THUMB_1,		# RIGHT_HAND_THUMB_2 -> RIGHT_HAND_THUMB_1
	AxisStudioBone.RIGHT_HAND_THUMB_2,		# RIGHT_HAND_THUMB_3 -> RIGHT_HAND_THUMB_2
	AxisStudioBone.RIGHT_HAND,				# RIGHT_IN_HAND_INDEX -> RIGHT_HAND
	AxisStudioBone.RIGHT_IN_HAND_INDEX,		# RIGHT_HAND_INDEX_1 -> RIGHT_IN_HAND_INDEX
	AxisStudioBone.RIGHT_HAND_INDEX_1,		# RIGHT_HAND_INDEX_2 -> RIGHT_HAND_INDEX_1
	AxisStudioBone.RIGHT_HAND_INDEX_2,		# RIGHT_HAND_INDEX_3 -> RIGHT_HAND_INDEX_2
	AxisStudioBone.RIGHT_HAND,				# RIGHT_IN_HAND_MIDDLE -> RIGHT_HAND
	AxisStudioBone.RIGHT_IN_HAND_MIDDLE,	# RIGHT_HAND_MIDDLE_1 -> RIGHT_IN_HAND_MIDDLE
	AxisStudioBone.RIGHT_HAND_MIDDLE_1,		# RIGHT_HAND_MIDDLE_2 -> RIGHT_HAND_MIDDLE_1
	AxisStudioBone.RIGHT_HAND_MIDDLE_2,		# RIGHT_HAND_MIDDLE_3 -> RIGHT_HAND_MIDDLE_2
	AxisStudioBone.RIGHT_HAND,				# RIGHT_IN_HAND_RING -> RIGHT_HAND
	AxisStudioBone.RIGHT_IN_HAND_RING,		# RIGHT_HAND_RING_1 -> RIGHT_IN_HAND_RING
	AxisStudioBone.RIGHT_HAND_RING_1,		# RIGHT_HAND_RING_2 -> RIGHT_HAND_RING_1
	AxisStudioBone.RIGHT_HAND_RING_2,		# RIGHT_HAND_RING_3 -> RIGHT_HAND_RING_2
	AxisStudioBone.RIGHT_HAND,				# RIGHT_IN_HAND_PINKY -> RIGHT_HAND
	AxisStudioBone.RIGHT_IN_HAND_PINKY,		# RIGHT_HAND_PINKY_1 -> RIGHT_IN_HAND_PINKY
	AxisStudioBone.RIGHT_HAND_PINKY_1,		# RIGHT_HAND_PINKY_2 -> RIGHT_HAND_PINKY_1
	AxisStudioBone.RIGHT_HAND_PINKY_2,		# RIGHT_HAND_PINKY_3 -> RIGHT_HAND_PINKY_2
	AxisStudioBone.SPINE_2,					# LEFT_SHOULDER -> SPINE_2
	AxisStudioBone.LEFT_SHOULDER,			# LEFT_ARM -> LEFT_SHOULDER
	AxisStudioBone.LEFT_ARM,				# LEFT_FORE_ARM -> LEFT_ARM
	AxisStudioBone.LEFT_FORE_ARM,			# LEFT_HAND -> LEFT_FORE_ARM
	AxisStudioBone.LEFT_HAND,				# LEFT_HAND_THUMB_1 -> LEFT_HAND
	AxisStudioBone.LEFT_HAND_THUMB_1,		# LEFT_HAND_THUMB_2 -> LEFT_HAND_THUMB_1
	AxisStudioBone.LEFT_HAND_THUMB_2,		# LEFT_HAND_THUMB_3 -> LEFT_HAND_THUMB_2
	AxisStudioBone.LEFT_HAND,				# LEFT_IN_HAND_INDEX -> LEFT_HAND
	AxisStudioBone.LEFT_IN_HAND_INDEX,		# LEFT_HAND_INDEX_1 -> LEFT_IN_HAND_INDEX
	AxisStudioBone.LEFT_HAND_INDEX_1,		# LEFT_HAND_INDEX_2 -> LEFT_HAND_INDEX_1
	AxisStudioBone.LEFT_HAND_INDEX_2,		# LEFT_HAND_INDEX_3 -> LEFT_HAND_INDEX_2
	AxisStudioBone.LEFT_HAND,				# LEFT_IN_HAND_MIDDLE -> LEFT_HAND
	AxisStudioBone.LEFT_IN_HAND_MIDDLE,		# LEFT_HAND_MIDDLE_1 -> LEFT_IN_HAND_MIDDLE
	AxisStudioBone.LEFT_HAND_MIDDLE_1,		# LEFT_HAND_MIDDLE_2 -> LEFT_HAND_MIDDLE_1
	AxisStudioBone.LEFT_HAND_MIDDLE_2,		# LEFT_HAND_MIDDLE_3 -> LEFT_HAND_MIDDLE_2
	AxisStudioBone.LEFT_HAND,				# LEFT_IN_HAND_RING -> LEFT_HAND
	AxisStudioBone.LEFT_IN_HAND_RING,		# LEFT_HAND_RING_1 -> LEFT_IN_HAND_RING
	AxisStudioBone.LEFT_HAND_RING_1,		# LEFT_HAND_RING_2 -> LEFT_HAND_RING_1
	AxisStudioBone.LEFT_HAND_RING_2,		# LEFT_HAND_RING_3 -> LEFT_HAND_RING_2
	AxisStudioBone.LEFT_HAND,				# LEFT_IN_HAND_PINKY -> LEFT_HAND
	AxisStudioBone.LEFT_IN_HAND_PINKY,		# LEFT_HAND_PINKY_1 -> LEFT_IN_HAND_PINKY
	AxisStudioBone.LEFT_HAND_PINKY_1,		# LEFT_HAND_PINKY_2 -> LEFT_HAND_PINKY_1
	AxisStudioBone.LEFT_HAND_PINKY_2		# LEFT_HAND_PINKY_3 -> LEFT_HAND_PINKY_2
]

# Array of bone rotations by SkeletonRig
const _bone_rotations : Array[Quaternion] = [
	Quaternion.IDENTITY,
	Quaternion(0.0, -0.7071067811, 0.7071067811, 0.0)
]


## UDP Receive Port
@export var port : int = 7004 : set = _set_port

## Skeleton Rig
@export_enum("AxisStudio", "Humanoid") var skeleton_rig : int = SkeletonRig.AxisStudio : set = _set_skeleton_rig

## Bone update animation format
@export var bone_update : BoneUpdate = BoneUpdate.FULL : set = _set_bone_update

# UDP Server
var _server := UDPServer.new()

# Current connection
var _connection : PacketPeerUDP

# Axis Studio animation instance
var _animation : Animation

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
	_names.resize(AxisStudioBone.COUNT)
	_parents.resize(AxisStudioBone.COUNT)
	_positions.resize(AxisStudioBone.COUNT)
	_rotations.resize(AxisStudioBone.COUNT)
	_rotations_inv.resize(AxisStudioBone.COUNT)
	_rotation_tracks.resize(AxisStudioBone.COUNT)
	_position_tracks.resize(AxisStudioBone.COUNT)


# Handle node ready
func _ready() -> void:
	super()
	_update_port()


# Handle setting the UDP port
func _set_port(p_port : int) -> void:
	port = p_port
	if is_inside_tree():
		_update_port()


# Update the UDP port
func _update_port() -> void:
	_server.stop()
	_connection = null
	_server.listen(port)


# Handle setting the skeleton rig
func _set_skeleton_rig(p_skeleton_rig : int) -> void:
	skeleton_rig = p_skeleton_rig
	if is_inside_tree() and _animation:
		_populate_animations()


# Handle setting the bone update mode
func _set_bone_update(p_bone_update : BoneUpdate) -> void:
	bone_update = p_bone_update
	if is_inside_tree() and _animation:
		_populate_animations()


# Initialize the animations
func _initialize_animations() -> void:
	# Get (or create) the animation
	if _library.has_animation("AxisStudio"):
		_animation = _library.get_animation("AxisStudio")
	else:
		_animation = Animation.new()
		_animation.resource_name = "AxisStudio"
		_animation.resource_local_to_scene = true
		_animation.loop_mode = Animation.LOOP_LINEAR
		_library.add_animation("AxisStudio", _animation)


# Populate the animations
func _populate_animations() -> void:
	for bone in AxisStudioBone.COUNT:
		_names[bone] = ":" + _bone_names[skeleton_rig][bone]
		_parents[bone] = _bone_parents[bone]
		_positions[bone] = Vector3.ZERO
		_rotations[bone] = Quaternion.IDENTITY
		_rotations_inv[bone] = Quaternion.IDENTITY
		_rotation_tracks[bone] = -1
		_position_tracks[bone] = -1

	# Construct the tracks
	_animation.clear()
	for bone in AxisStudioBone.COUNT:
		# If a bone has no parent then don't drive it
		if _parents[bone] < 0:
			continue

		# Construct the rotation track and key frame
		var rt := _animation.add_track(Animation.TYPE_ROTATION_3D)
		_rotation_tracks[bone] = rt
		_animation.track_set_path(rt, _names[bone])
		_animation.rotation_track_insert_key(rt, 0, Quaternion.IDENTITY)

		# Construct the position track and key frame
		if bone_update == BoneUpdate.FULL:
			var pt := _animation.add_track(Animation.TYPE_POSITION_3D)
			_position_tracks[bone] = pt
			_animation.track_set_path(pt, _names[bone])
			_animation.position_track_insert_key(pt, 0, Vector3.ZERO)


# Update the animations
func _update_animations() -> void:
	# Poll the UDP server
	_server.poll()

	# Switch to any new connection
	if _server.is_connection_available():
		_connection = _server.take_connection()

	# Skip if no connection
	if not _connection:
		return

	# Process incoming packets
	while _connection.get_available_packet_count() > 0:
		var packet := _connection.get_packet()
		_process_packet(packet)


# Process a received packet
func _process_packet(packet : PackedByteArray) -> void:
	# Skip invalid packets
	if packet.size() < 64:
		return

	# Skip if header or footer are incorrect
	if packet.decode_u16(0) != 0xDDFF or packet.decode_u16(62) != 0xEEFF:
		return

	# Print the frame number
	# var frame := packet.decode_u16(46)
	# print("Frame: ", frame)

	# Verify the number of joints
	var joint_count := packet.decode_u16(6) / 6
	if joint_count != AxisStudioBone.COUNT:
		return

	# Process the bones
	var adjustment := _bone_rotations[skeleton_rig]
	for bone in AxisStudioBone.COUNT:
		# Parse the packet
		var offset := 64 + bone * 24
		var pos_x := packet.decode_float(offset) / 100.0
		var pos_y := packet.decode_float(offset + 4) / 100.0
		var pos_z := packet.decode_float(offset + 8) / 100.0
		var rot_y := deg_to_rad(packet.decode_float(offset + 12))
		var rot_x := deg_to_rad(packet.decode_float(offset + 16))
		var rot_z := deg_to_rad(packet.decode_float(offset + 20))

		# Decode positions and rotations
		_positions[bone] = Vector3(pos_x, pos_y, pos_z)
		_rotations[bone] = Basis.from_euler(Vector3(rot_x, rot_y, rot_z)).get_rotation_quaternion() * adjustment
		_rotations_inv[bone] = _rotations[bone].inverse()

	# Apply the animations
	for bone in AxisStudioBone.COUNT:
		# Get the parent joint (skip if none)
		var parent : int = _parents[bone]
		if parent < 0:
			continue

		# Set rotation
		var q := _rotations_inv[parent] * _rotations[bone]
		_animation.track_set_key_value(_rotation_tracks[bone], 0, q)

		# Set position if enabled
		if bone_update == BoneUpdate.FULL:
			var p := _rotations_inv[parent] * (_positions[bone] - _positions[parent])
			_animation.track_set_key_value(_position_tracks[bone], 0, p)
