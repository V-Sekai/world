extends Label3D

class_name PinLabel3D

@export var skeleton: Skeleton3D = null

func _ready():
	assert(skeleton != null, "Skeleton3D has not been assigned.")

func _process(delta):
	if skeleton == null:
		return
	
	for pin_i in range(skeleton.get_bone_count()):
		var bone_name = skeleton.get_bone_name(pin_i)
		var targets_3d: Marker3D = get_parent()

		var bone_i: int = skeleton.find_bone(bone_name)
		if bone_i == -1:
			continue
		
		var current_pose: Transform3D = targets_3d.global_transform
		var rest_pose: Transform3D = skeleton.get_bone_global_rest(bone_i)
		
		var diff_vec: Vector3 = current_pose.origin - rest_pose.origin
		text = vector_to_color_bars(diff_vec)


func value_to_color(value: float) -> String:
	if value < -1:
		return "█" # Full block (large negative difference)
	elif value < -0.5:
		return "▓" # Dark shade (medium negative difference)
	elif value < 0:
		return "▒" # Medium shade (small negative difference)
	elif value == 0:
		return " " # Light shade (no difference)
	elif value <= 0.5:
		return "-" # Custom character for small positive difference
	elif value <= 1:
		return "+" # Custom character for medium positive difference
	else:
		return "*" # Custom character for large positive difference


func vector_to_color_bars(vec: Vector3) -> String:
	var x_bar := value_to_color(vec.x)
	var y_bar := value_to_color(vec.y)
	var z_bar := value_to_color(vec.z)
	return "%s\n%s\n%s" % [x_bar, y_bar, z_bar]
