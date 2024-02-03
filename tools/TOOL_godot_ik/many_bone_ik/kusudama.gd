class LimitCone:
	var direction: Vector3
	var angle: float
	
	func _init(direction: Vector3, angle: float):
		self.direction = direction
		self.angle = angle

@export
var bone_configurations = {
	# Root has minimal rotation as it's the base of the skeleton
	"Root": {"kusudama": []},
	# Hips allow for forward/backward and some lateral movement
	"Hips": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(45.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(30.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(20.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(20.0))
		]
	},

	# Spine allows for flexion and extension, limited lateral bending
	"Spine": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(35.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(15.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(15.0))
		]
	},

	# Chest allows for more rotation than spine, similarly limited by the rib cage
	"Chest": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(25.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(15.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(10.0))
		]
	},

	# UpperChest follows the chest but usually has even less range of motion
	"UpperChest": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(5.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(5.0))
		]
	},

	# Neck allows rotation and some tilt
	"Neck": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(30.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(20.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(30.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(30.0))
		]
	},

	# Head can nod and look side-to-side
	"Head": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(40.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(30.0)),
			LimitCone.new(Vector3.MODEL_LEFT, deg_to_rad(40.0)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(40.0))
		]
	},

	# Upper limbs (Arms)
	"LeftUpperArm": {"kusudama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]},
	"LeftLowerArm": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
	"RightUpperArm": {"kusudama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]},
	"RightLowerArm": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_TOP, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},

	# Hands have very complex movement; this is just a rough constraint
	"LeftHand": {
		"kusudama": [
			LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(65.0)),
			LimitCone.new(Vector3.MODEL_FRONT.normalized(), deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(70.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(40.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)),
			LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0).normalized(), deg_to_rad(45.0)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))
		]
	},
	"RightHand": {
		"kusudama": [
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

	# Lower limbs (Legs)
	"LeftUpperLeg": {"kusudama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"LeftLowerLeg": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(110.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(5.0))
		]
	},
	"RightUpperLeg": {"kusudama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
	"RightLowerLeg": {
		"kusudama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(110.0)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(5.0))
		]
	},

	# Feet and Toes: adding general constraints, toes are usually kept simple due to their minor role in rigging
	"LeftFoot": {"kusudama": [LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(45.0))]},
	"RightFoot": {"kusudama": [LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(45.0))]},
	"LeftToes": {"kusudama": []},
	"RightToes": {"kusudama": []}
}

