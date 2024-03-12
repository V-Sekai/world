class LimitCone:
	var direction: Vector3
	var limit_angle: float
	
	func _init(direction: Vector3, limit_angle: float):
		self.direction = direction
		self.limit_angle = limit_angle


## Kusudamas are used to expose the movement of bones in a 3D model. Each bone has its own kusudama, which is a chain of limit cones. The limit cones define the open areas from the previous LimitCone to the current limit cone.
##
## A LimitCone is defined by a direction and a radius angle on a unit sphere. The direction is a Vector3 object that represents the axis along which the bone can move. The angle is the maximum angle (in radians) that the bone can deviate from this axis.
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
	"LeftShoulder": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(50.0)), 
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(60.0)),   
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(65.0)),    
			LimitCone.new(Vector3.MODEL_BOTTOM, deg_to_rad(35.0)) 
		]
	},
	"RightShoulder": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(50.0)),  
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(60.0)),  
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(65.0)),   
			LimitCone.new(Vector3.MODEL_BOTTOM, deg_to_rad(35.0))
		]
	},
	"LeftUpperArm": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(60.0))]},
	"RightUpperArm": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(60.0))]},
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
