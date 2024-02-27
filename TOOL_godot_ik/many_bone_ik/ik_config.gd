
class LimitCone:
	var direction: Vector3
	var angle: float

	func _init(direction: Vector3, angle: float):
		self.direction = direction
		self.angle = angle

const Kusudama = preload("kusudama.gd")
const Twist = preload("twist.gd")

var bone_configurations_kusudama = Kusudama.new().bone_configurations
var bone_configurations_twist = Twist.new().bone_configurations

@export
var bone_configurations = bone_configurations_kusudama.duplicate()


func _init():
	for key in bone_configurations_twist.keys():
		for key_twist in bone_configurations_twist[key].keys():
			bone_configurations[key][key_twist] =  bone_configurations_twist[key][key_twist]
	for key in bone_configurations_kusudama.keys():
		for key_kusudama in bone_configurations_kusudama[key].keys():
			bone_configurations[key][key_kusudama] =  bone_configurations_kusudama[key][key_kusudama]

