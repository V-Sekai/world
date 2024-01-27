@tool
class_name AxisStudioReader
extends JointReader


## Enumeration of axis-studio joints
enum AxisStudioJoint {
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

# Array of parent-joints (for flattening tree)
const _parents : Array[int] = [
	-1,										# HIPS -> nothing
	AxisStudioJoint.HIPS,					# RIGHT_UP_LEG -> HIPS
	AxisStudioJoint.RIGHT_UP_LEG,			# RIGHT_LEG -> RIGHT_UP_LEG
	AxisStudioJoint.RIGHT_LEG,				# RIGHT_FOOT -> RIGHT_LEG
	AxisStudioJoint.HIPS,					# LEFT_UP_LEG -> HIPS
	AxisStudioJoint.LEFT_UP_LEG,			# LEFT_LEG -> LEFT_UP_LEG
	AxisStudioJoint.LEFT_LEG,				# LEFT_FOOT -> LEFT_LEG
	AxisStudioJoint.HIPS,					# SPINE -> HIPS
	AxisStudioJoint.SPINE,					# SPINE_1 -> SPINE
	AxisStudioJoint.SPINE_1,				# SPINE_2 -> SPINE_1
	AxisStudioJoint.SPINE_2,				# SPINE_3 -> SPINE_2
	AxisStudioJoint.SPINE_3,				# NECK -> SPINE_3
	AxisStudioJoint.NECK,					# HEAD -> NECK
	AxisStudioJoint.SPINE_2,				# RIGHT_SHOULDER -> SPINE_2
	AxisStudioJoint.RIGHT_SHOULDER,			# RIGHT_ARM -> RIGHT_SHOULDER
	AxisStudioJoint.RIGHT_ARM,				# RIGHT_FORE_ARM -> RIGHT_ARM
	AxisStudioJoint.RIGHT_FORE_ARM,			# RIGHT_HAND -> RIGHT_FORE_ARM
	AxisStudioJoint.RIGHT_HAND,				# RIGHT_HAND_THUMB_1 -> RIGHT_HAND
	AxisStudioJoint.RIGHT_HAND_THUMB_1,		# RIGHT_HAND_THUMB_2 -> RIGHT_HAND_THUMB_1
	AxisStudioJoint.RIGHT_HAND_THUMB_2,		# RIGHT_HAND_THUMB_3 -> RIGHT_HAND_THUMB_2
	AxisStudioJoint.RIGHT_HAND,				# RIGHT_IN_HAND_INDEX -> RIGHT_HAND
	AxisStudioJoint.RIGHT_IN_HAND_INDEX,	# RIGHT_HAND_INDEX_1 -> RIGHT_IN_HAND_INDEX
	AxisStudioJoint.RIGHT_HAND_INDEX_1,		# RIGHT_HAND_INDEX_2 -> RIGHT_HAND_INDEX_1
	AxisStudioJoint.RIGHT_HAND_INDEX_2,		# RIGHT_HAND_INDEX_3 -> RIGHT_HAND_INDEX_2
	AxisStudioJoint.RIGHT_HAND,				# RIGHT_IN_HAND_MIDDLE -> RIGHT_HAND
	AxisStudioJoint.RIGHT_IN_HAND_MIDDLE,	# RIGHT_HAND_MIDDLE_1 -> RIGHT_IN_HAND_MIDDLE
	AxisStudioJoint.RIGHT_HAND_MIDDLE_1,	# RIGHT_HAND_MIDDLE_2 -> RIGHT_HAND_MIDDLE_1
	AxisStudioJoint.RIGHT_HAND_MIDDLE_2,	# RIGHT_HAND_MIDDLE_3 -> RIGHT_HAND_MIDDLE_2
	AxisStudioJoint.RIGHT_HAND,				# RIGHT_IN_HAND_RING -> RIGHT_HAND
	AxisStudioJoint.RIGHT_IN_HAND_RING,		# RIGHT_HAND_RING_1 -> RIGHT_IN_HAND_RING
	AxisStudioJoint.RIGHT_HAND_RING_1,		# RIGHT_HAND_RING_2 -> RIGHT_HAND_RING_1
	AxisStudioJoint.RIGHT_HAND_RING_2,		# RIGHT_HAND_RING_3 -> RIGHT_HAND_RING_2
	AxisStudioJoint.RIGHT_HAND,				# RIGHT_IN_HAND_PINKY -> RIGHT_HAND
	AxisStudioJoint.RIGHT_IN_HAND_PINKY,	# RIGHT_HAND_PINKY_1 -> RIGHT_IN_HAND_PINKY
	AxisStudioJoint.RIGHT_HAND_PINKY_1,		# RIGHT_HAND_PINKY_2 -> RIGHT_HAND_PINKY_1
	AxisStudioJoint.RIGHT_HAND_PINKY_2,		# RIGHT_HAND_PINKY_3 -> RIGHT_HAND_PINKY_2
	AxisStudioJoint.SPINE_2,				# LEFT_SHOULDER -> SPINE_2
	AxisStudioJoint.LEFT_SHOULDER,			# LEFT_ARM -> LEFT_SHOULDER
	AxisStudioJoint.LEFT_ARM,				# LEFT_FORE_ARM -> LEFT_ARM
	AxisStudioJoint.LEFT_FORE_ARM,			# LEFT_HAND -> LEFT_FORE_ARM
	AxisStudioJoint.LEFT_HAND,				# LEFT_HAND_THUMB_1 -> LEFT_HAND
	AxisStudioJoint.LEFT_HAND_THUMB_1,		# LEFT_HAND_THUMB_2 -> LEFT_HAND_THUMB_1
	AxisStudioJoint.LEFT_HAND_THUMB_2,		# LEFT_HAND_THUMB_3 -> LEFT_HAND_THUMB_2
	AxisStudioJoint.LEFT_HAND,				# LEFT_IN_HAND_INDEX -> LEFT_HAND
	AxisStudioJoint.LEFT_IN_HAND_INDEX,		# LEFT_HAND_INDEX_1 -> LEFT_IN_HAND_INDEX
	AxisStudioJoint.LEFT_HAND_INDEX_1,		# LEFT_HAND_INDEX_2 -> LEFT_HAND_INDEX_1
	AxisStudioJoint.LEFT_HAND_INDEX_2,		# LEFT_HAND_INDEX_3 -> LEFT_HAND_INDEX_2
	AxisStudioJoint.LEFT_HAND,				# LEFT_IN_HAND_MIDDLE -> LEFT_HAND
	AxisStudioJoint.LEFT_IN_HAND_MIDDLE,	# LEFT_HAND_MIDDLE_1 -> LEFT_IN_HAND_MIDDLE
	AxisStudioJoint.LEFT_HAND_MIDDLE_1,		# LEFT_HAND_MIDDLE_2 -> LEFT_HAND_MIDDLE_1
	AxisStudioJoint.LEFT_HAND_MIDDLE_2,		# LEFT_HAND_MIDDLE_3 -> LEFT_HAND_MIDDLE_2
	AxisStudioJoint.LEFT_HAND,				# LEFT_IN_HAND_RING -> LEFT_HAND
	AxisStudioJoint.LEFT_IN_HAND_RING,		# LEFT_HAND_RING_1 -> LEFT_IN_HAND_RING
	AxisStudioJoint.LEFT_HAND_RING_1,		# LEFT_HAND_RING_2 -> LEFT_HAND_RING_1
	AxisStudioJoint.LEFT_HAND_RING_2,		# LEFT_HAND_RING_3 -> LEFT_HAND_RING_2
	AxisStudioJoint.LEFT_HAND,				# LEFT_IN_HAND_PINKY -> LEFT_HAND
	AxisStudioJoint.LEFT_IN_HAND_PINKY,		# LEFT_HAND_PINKY_1 -> LEFT_IN_HAND_PINKY
	AxisStudioJoint.LEFT_HAND_PINKY_1,		# LEFT_HAND_PINKY_2 -> LEFT_HAND_PINKY_1
	AxisStudioJoint.LEFT_HAND_PINKY_2		# LEFT_HAND_PINKY_3 -> LEFT_HAND_PINKY_2
]

# Mapping array from Joint to associated AxisStudioJoint
const _joint_map : Array[int] = [
	AxisStudioJoint.HIPS,					# JOINT_HIPS
	AxisStudioJoint.SPINE,					# JOINT_SPINE
	AxisStudioJoint.SPINE_1,				# JOINT_CHEST
	AxisStudioJoint.SPINE_3,				# JOINT_UPPER_CHEST
	AxisStudioJoint.NECK,					# JOINT_NECK
	AxisStudioJoint.HEAD,					# JOINT_HEAD
	AxisStudioJoint.LEFT_SHOULDER,			# JOINT_LEFT_SHOULDER
	AxisStudioJoint.LEFT_ARM,				# JOINT_LEFT_UPPER_ARM
	AxisStudioJoint.LEFT_FORE_ARM,			# JOINT_LEFT_LOWER_ARM
	AxisStudioJoint.LEFT_HAND,				# JOINT_LEFT_HAND
	AxisStudioJoint.LEFT_HAND_THUMB_1,		# JOINT_LEFT_THUMB_METACARPAL
	AxisStudioJoint.LEFT_HAND_THUMB_2,		# JOINT_LEFT_THUMB_PROXIMAL
	AxisStudioJoint.LEFT_HAND_THUMB_3,		# JOINT_LEFT_THUMB_DISTAL
	AxisStudioJoint.LEFT_HAND_INDEX_1,		# JOINT_LEFT_INDEX_PROXIMAL
	AxisStudioJoint.LEFT_HAND_INDEX_2,		# JOINT_LEFT_INDEX_INTERMEDIATE
	AxisStudioJoint.LEFT_HAND_INDEX_3,		# JOINT_LEFT_INDEX_DISTAL
	AxisStudioJoint.LEFT_HAND_MIDDLE_1,		# JOINT_LEFT_MIDDLE_PROXIMAL
	AxisStudioJoint.LEFT_HAND_MIDDLE_2,		# JOINT_LEFT_MIDDLE_INTERMEDIATE
	AxisStudioJoint.LEFT_HAND_MIDDLE_3,		# JOINT_LEFT_MIDDLE_DISTAL
	AxisStudioJoint.LEFT_HAND_RING_1,		# JOINT_LEFT_RING_PROXIMAL
	AxisStudioJoint.LEFT_HAND_RING_2,		# JOINT_LEFT_RING_INTERMEDIATE
	AxisStudioJoint.LEFT_HAND_RING_3,		# JOINT_LEFT_RING_DISTAL
	AxisStudioJoint.LEFT_HAND_PINKY_1,		# JOINT_LEFT_LITTLE_PROXIMAL
	AxisStudioJoint.LEFT_HAND_PINKY_2,		# JOINT_LEFT_LITTLE_INTERMEDIATE
	AxisStudioJoint.LEFT_HAND_PINKY_3,		# JOINT_LEFT_LITTLE_DISTAL
	AxisStudioJoint.RIGHT_SHOULDER,			# JOINT_RIGHT_SHOULDER
	AxisStudioJoint.RIGHT_ARM,				# JOINT_RIGHT_UPPER_ARM
	AxisStudioJoint.RIGHT_FORE_ARM,			# JOINT_RIGHT_LOWER_ARM
	AxisStudioJoint.RIGHT_HAND,				# JOINT_RIGHT_HAND
	AxisStudioJoint.RIGHT_HAND_THUMB_1,		# JOINT_RIGHT_THUMB_METACARPAL
	AxisStudioJoint.RIGHT_HAND_THUMB_2,		# JOINT_RIGHT_THUMB_PROXIMAL
	AxisStudioJoint.RIGHT_HAND_THUMB_3,		# JOINT_RIGHT_THUMB_DISTAL
	AxisStudioJoint.RIGHT_HAND_INDEX_1,		# JOINT_RIGHT_INDEX_PROXIMAL
	AxisStudioJoint.RIGHT_HAND_INDEX_2,		# JOINT_RIGHT_INDEX_INTERMEDIATE
	AxisStudioJoint.RIGHT_HAND_INDEX_3,		# JOINT_RIGHT_INDEX_DISTAL
	AxisStudioJoint.RIGHT_HAND_MIDDLE_1,	# JOINT_RIGHT_MIDDLE_PROXIMAL
	AxisStudioJoint.RIGHT_HAND_MIDDLE_2,	# JOINT_RIGHT_MIDDLE_INTERMEDIATE
	AxisStudioJoint.RIGHT_HAND_MIDDLE_3,	# JOINT_RIGHT_MIDDLE_DISTAL
	AxisStudioJoint.RIGHT_HAND_RING_1,		# JOINT_RIGHT_RING_PROXIMAL
	AxisStudioJoint.RIGHT_HAND_RING_2,		# JOINT_RIGHT_RING_INTERMEDIATE
	AxisStudioJoint.RIGHT_HAND_RING_3,		# JOINT_RIGHT_RING_DISTAL
	AxisStudioJoint.RIGHT_HAND_PINKY_1,		# JOINT_RIGHT_LITTLE_PROXIMAL
	AxisStudioJoint.RIGHT_HAND_PINKY_2,		# JOINT_RIGHT_LITTLE_INTERMEDIATE
	AxisStudioJoint.RIGHT_HAND_PINKY_3,		# JOINT_RIGHT_LITTLE_DISTAL
	AxisStudioJoint.LEFT_UP_LEG,			# JOINT_LEFT_UPPER_LEG
	AxisStudioJoint.LEFT_LEG,				# JOINT_LEFT_LOWER_LEG
	AxisStudioJoint.LEFT_FOOT,				# JOINT_LEFT_FOOT
	AxisStudioJoint.RIGHT_UP_LEG,			# JOINT_RIGHT_UPPER_LEG
	AxisStudioJoint.RIGHT_LEG,				# JOINT_RIGHT_LOWER_LEG
	AxisStudioJoint.RIGHT_FOOT,				# JOINT_RIGHT_FOOT
]


# UDP Server
var _server : UDPServer = UDPServer.new()

# Current connection
var _connection : PacketPeerUDP

# Axis Studio joints
var _asj_joints : Array[Joint] = []

# Joints
var _joints : Array[Joint] = []



## Initialize the class
func _init() -> void:
	# Fill Axis Studio joints ready for use
	for index in AxisStudioJoint.COUNT:
		var joint := Joint.new()
		joint.valid = true
		_asj_joints.append(joint)

	# Fill Joints (invalid to start)
	_joints.resize(Joint.JOINT_COUNT)
	_joints.fill(Joint.new())


## Stop listening
func stop() -> void:
	_server.stop()
	_connection = null


## Start listening
func listen(p_port : int = 7004) -> void:
	stop()
	_server.listen(p_port)


## Read updated joint data
func read() -> bool:
	# Poll the server
	_server.poll()

	# Switch to any new connection
	if _server.is_connection_available():
		_connection = _server.take_connection()

	# Skip if no connection
	if not _connection:
		return false

	# Check for available packets and skip to the last
	var packet : PackedByteArray
	while _connection.get_available_packet_count() > 0:
		packet = _connection.get_packet()

	# Skip if no new packet
	if not packet:
		return false

	# Skip invalid packets
	if packet.size() < 64:
		return false

	# Skip if header or footer are incorrect
	if packet.decode_u16(0) != 0xDDFF or packet.decode_u16(62) != 0xEEFF:
		return false

	# Verify the number of joints
	var asj_count := packet.decode_u16(6) / 6
	if asj_count != AxisStudioJoint.COUNT:
		return false

	# Process the joints
	for index in AxisStudioJoint.COUNT:
		# Parse the packet
		var offset := 64 + index * 24
		var pos_x := packet.decode_float(offset) / 100.0
		var pos_y := packet.decode_float(offset + 4) / 100.0
		var pos_z := packet.decode_float(offset + 8) / 100.0
		var rot_y := deg_to_rad(packet.decode_float(offset + 12))
		var rot_x := deg_to_rad(packet.decode_float(offset + 16))
		var rot_z := deg_to_rad(packet.decode_float(offset + 20))
		var pos := Vector3(pos_x, pos_y, pos_z)
		var rot := Vector3(rot_x, rot_y, rot_z)
		
		# Decode positions and rotations
		var joint := _asj_joints[index]
		joint.position = pos
		joint.rotation = Basis.from_euler(rot).get_rotation_quaternion()

	# Flatten joint-tree
	for index in AxisStudioJoint.COUNT:
		var parent_index := _parents[index]
		if parent_index < 0:
			continue

		var joint := _asj_joints[index]
		var parent := _asj_joints[parent_index]

		var new_pos := parent.position + parent.rotation * joint.position
		var new_rot := parent.rotation * joint.rotation
		
		joint.position = new_pos
		joint.rotation = new_rot

	# Map to standard joints
	for index in Joint.JOINT_COUNT:
		var asj_index := _joint_map[index]
		_joints[index] = _asj_joints[asj_index]

	# New data available
	return true


## Get the array of joints
func get_joints() -> Array[Joint]:
	return _joints
