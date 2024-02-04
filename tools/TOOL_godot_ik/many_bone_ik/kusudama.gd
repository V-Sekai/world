class LimitCone:
	var direction: Vector3
	var angle: float
	
	func _init(direction: Vector3, angle: float):
		self.direction = direction
		self.angle = angle

@export
var bone_configurations = {
	"Root": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))]},
	"Hips": {"kususdama": [LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0))]},
	"Spine": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(5.0))
		]
	},
	"Chest": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(10.0))
		]
	},
	"UpperChest": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(5.0))
		]
	},
	"Neck": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(15.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(10.0))
		]
	},
	"Head": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(40.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(25.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(25.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(25.0))
		]
	},
	"LeftShoulder": {},
	"RightShoulder": {},
	"LeftUpperArm": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]},
	"RightUpperArm": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]},
	"LeftLowerArm": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
	"RightLowerArm": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
	"LeftHand": {
		"kususdama": [
			LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))
		]
	},
	"RightHand": {
		"kususdama": [
			LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))
		]
	},
	"LeftThumb": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"RightThumb": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"LeftUpperLeg": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0)),  # Allow forward kick
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(45.0)),   # Allow backward motion
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(45.0))    # Allow sidestep motion
		]
	},    
	"RightUpperLeg": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0)),  # Allow forward kick
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(45.0)),   # Allow backward motion
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(45.0))   # Allow sidestep motion
		]
	},
	"LeftLowerLeg": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
	"RightLowerLeg": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	}
}
