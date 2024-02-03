
class LimitCone:
	var direction: Vector3
	var angle: float

	func _init(direction: Vector3, angle: float):
		self.direction = direction
		self.angle = angle

@export
var bone_configurations = {
	"Root": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))], "twist_from": deg_to_rad(0.0), "twist_range": deg_to_rad(2)},
	"Hips": {"kususdama": [LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0))], "twist_from": deg_to_rad(0.0), "twist_range": deg_to_rad(2)},
	"Spine": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0))], "twist_from": deg_to_rad(-20.0), "twist_range": deg_to_rad(20.0)},
	"Chest": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(20.0))], "twist_from": deg_to_rad(-15.0), "twist_range": deg_to_rad(30.0)},
	"UpperChest": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0))], "twist_from": deg_to_rad(-10.0), "twist_range": deg_to_rad(20.0)},
	"Head": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(30.0))], "twist_from": deg_to_rad(-10.0), "twist_range": deg_to_rad(20.0)},
	"Neck": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(20.0))], "twist_from": deg_to_rad(-15.0), "twist_range": deg_to_rad(30.0)},
	"LeftUpperArm": {
		"twist_from": deg_to_rad(80.0),
		"twist_range": deg_to_rad(30.0),
		"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]
	},
	"RightUpperArm": {
		"twist_from": deg_to_rad(80.0),
		"twist_range": deg_to_rad(30.0),
		"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]
	},
	"LeftLowerArm": {
		"twist_from": deg_to_rad(-55.0),
		"twist_range": deg_to_rad(70.0),
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
	"RightLowerArm": {
		"twist_from": deg_to_rad(-145.0),
		"twist_range": deg_to_rad(70.0),
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},		
	"LeftHand": {"kususdama": [LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))]},
	"RightHand": {"kususdama": [LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))]},
	"LeftThumb": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"RightThumb": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"LeftUpperLeg": {
		"twist_from": deg_to_rad(-45.0),
		"twist_range": deg_to_rad(90.0),
		#"kususdama": [
			#LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			#LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
			#LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		#]
	},
	"RightUpperLeg": {
		"twist_from": deg_to_rad(-45.0),
		"twist_range": deg_to_rad(90.0),
		#"kususdama": [
			#LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			#LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
			#LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		#]
	},
	"LeftLowerLeg": {"twist_from": deg_to_rad(-55.0), "twist_range": deg_to_rad(50.0), "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))]},
	"RightLowerLeg": {"twist_from": deg_to_rad(-145.0), "twist_range": deg_to_rad(50.0), "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))]},
}
