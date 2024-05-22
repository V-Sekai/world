@tool
class_name JointReader
extends RefCounted


## Get the array of joints
func get_joints() -> Array[Joint]:
	push_error("Only implementations of JointReader should be used")
	breakpoint
	return []
