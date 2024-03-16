class KusudamaAccessCone:
	var direction: Vector3
	var limit_angle: float
	
	func _init(direction: Vector3, limit_angle: float):
		self.direction = direction
		self.limit_angle = limit_angle


## Kusudamas are used to expose the movement of bones in a 3D model. Each bone has its own kusudama, which is a chain of limit cones. The limit cones define the open areas from the previous KusudamaAccessCone to the current limit cone.
##
## A KusudamaAccessCone is defined by a direction and a radius angle on a unit sphere. The direction is a Vector3 object that represents the axis along which the bone can move. The angle is the maximum angle (in radians) that the bone can deviate from this axis.
##
## Each limit cone should have a maximum of 90 degrees to represent one hemisphere. So, if you have a point at the center, it can move within any of the cones, and it can transition smoothly from one cone to another when it moves through the areas between them.

@export
var bone_configurations = {
	"Root": {"kususdama": [KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))]},
	"Hips": {"kususdama": [KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0))]},
	"Spine": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(5.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(5.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(5.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(5.0)),
			KusudamaAccessCone.new(Vector3.MODEL_TOP, deg_to_rad(5.0))
		]
	},
	"Chest": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(10.0))
		]
	},
	"UpperChest": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(5.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(5.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(5.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(5.0))
		]
	},
	"Neck": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(15.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(10.0))
		]
	},
	"Head": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(40.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(25.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(25.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(25.0))
		]
	},
	"LeftShoulder": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(70.0)), 
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(60.0)),   
			KusudamaAccessCone.new(Vector3.MODEL_TOP, deg_to_rad(90.0)),    
			KusudamaAccessCone.new(Vector3.MODEL_BOTTOM, deg_to_rad(50.0)) 
		]
	},
	"RightShoulder": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(70.0)),  
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(60.0)),  
			KusudamaAccessCone.new(Vector3.MODEL_TOP, deg_to_rad(90.0)),   
			KusudamaAccessCone.new(Vector3.MODEL_BOTTOM, deg_to_rad(50.0))
		]
	},
	"LeftUpperArm": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(45.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(30.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(20.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(60.0))
		]
	},
	"RightUpperArm": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(45.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(30.0)),
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(20.0)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(60.0))
		]
	},
	"LeftLowerArm": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(1.5)),
			KusudamaAccessCone.new(Vector3.MODEL_TOP, deg_to_rad(1.5)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(1.5))
		]
	},
	"RightLowerArm": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(1.5)),
			KusudamaAccessCone.new(Vector3.MODEL_TOP, deg_to_rad(1.5)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(1.5))
		]
	},
	"LeftHand": {
		"kususdama": [
			KusudamaAccessCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			KusudamaAccessCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			KusudamaAccessCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			KusudamaAccessCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))
		]
	},
	"RightHand": {
		"kususdama": [
			KusudamaAccessCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			KusudamaAccessCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			KusudamaAccessCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			KusudamaAccessCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)),
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))
		]
	},
	"LeftThumb": {"kususdama": [KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"RightThumb": {"kususdama": [KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"LeftUpperLeg": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0)),  # Allow forward kick
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(45.0)),   # Allow backward motion
			KusudamaAccessCone.new(Vector3.MODEL_LEFT, deg_to_rad(45.0))    # Allow sidestep motion
		]
	},    
	"RightUpperLeg": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0)),  # Allow forward kick
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(45.0)),   # Allow backward motion
			KusudamaAccessCone.new(Vector3.MODEL_RIGHT, deg_to_rad(45.0))   # Allow sidestep motion
		]
	},
	"LeftLowerLeg": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			KusudamaAccessCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
	"RightLowerLeg": {
		"kususdama": [
			KusudamaAccessCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			KusudamaAccessCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			KusudamaAccessCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	}
}
