class LimitCone:
	var direction: Vector3
	var angle: float
	
	func _init(direction: Vector3, angle: float):
		self.direction = direction
		self.angle = angle


# ## Table with Descriptions and Normalized Vector3 Points for Kusudama 0 - Kusudama 3
#
# | Body Part      | Description                                                                                                                                                                                                                              | Kusudama 0                           | Kusudama 1                           | Kusudama 2                           | Kusudama 3                           |
# | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------ | ------------------------------------ | ------------------------------------ |
# | Hips           | The hips can tilt forward and backward up to 20-30 degrees, allowing the legs to swing in a wide arc during walking or running. They can also move side-to-side up to 10-20 degrees, enabling the legs to spread apart or come together. | `Vector3(0.267, 0.535, 0.802),0.349` | `Vector3(0.373, 0.620, 0.688),0.349` | `Vector3(0.371, 0.557, 0.743),0.174` | `Vector3(0.408, 0.571, 0.733),0.174` |
# | UpperChest     | The upper chest can tilt forward and backward up to 10-20 degrees, allowing for natural breathing and posture adjustments.                                                                                                               | `Vector3(0.316, 0.632, 0.949),0.174` | `Vector3(0.377, 0.755, 0.533),0.174` | N/A                                  | N/A                                  |
# | Chest          | The chest can tilt forward and backward up to 10-20 degrees, allowing for natural breathing and posture adjustments.                                                                                                                     | `Vector3(0.288, 0.576, 0.864),0.174` | `Vector3(0.346, 0.691, 0.633),0.174` | N/A                                  | N/A                                  |
# | Spine          | The spine can tilt forward and backward up to 35-45 degrees, allowing for bending and straightening of the torso.                                                                                                                        | `Vector3(0.291, 0.581, 0.872),0.610` | `Vector3(0.359, 0.718, 0.599),0.788` | N/A                                  | N/A                                  |
# | [Side]UpperLeg | The upper leg can swing forward and backward up to 80-90 degrees, allowing for steps during walking and running.                                                                                                                         | `Vector3(0.275, 0.550, 0.826),1.396` | `Vector3(0.334, 0.668, 0.695),1.570` | N/A                                  | N/A                                  |
# | [Side]LowerLeg | The knee can bend and straighten up to 110-120 degrees, allowing the lower leg to move towards or away from the upper leg during walking, running, and stepping.                                                                         | `Vector3(0.286, 0.573, 0.859),1.919` | `Vector3(0.340, 0.680, 0.680),2.094` | N/A                                  | N/A                                  |
# | [Side]Foot     | The ankle can tilt up (dorsiflexion) up to 10-20 degrees and down (plantarflexion) up to 35-40 degrees, allowing the foot to step and adjust during walking and running.                                                                 | `Vector3(0.309, 0.618, 0.927),0.174` | `Vector3(0.367, 0.734, 0.567),0.698` | N/A                                  | N/A                                  |
# | [Side]Shoulder | The shoulder can tilt forward and backward up to 160 degrees, allowing the arms to swing in a wide arc. They can also move side-to-side up to 40-50 degrees, enabling the arms to extend outwards or cross over the chest.               | `Vector3(0.312, 0.625, 0.938),2.792` | `Vector3(0.360, 0.720, 0.594),0.872` | N/A                                  | N/A                                  |
# | [Side]UpperArm | The upper arm can swing forward and backward up to 110-120 degrees, allowing for reaching and swinging motions.                                                                                                                          | `Vector3(0.305, 0.609, 0.913),1.919` | `Vector3(0.362, 0.724, 0.586),2.094` | N/A                                  | N/A                                  |
# | [Side]LowerArm | The elbow can bend and straighten up to 120-130 degrees, allowing the forearm to move towards or away from the upper arm during reaching and swinging motions.                                                                           | `Vector3(0.313, 0.625, 0.937),2.094` | `Vector3(0.361, 0.721, 0.590),2.269` | N/A                                  | N/A                                  |
# | [Side]Hand     | The wrist can tilt up (wrist extension) and down (wrist flexion) up to 50-60 degrees, allowing the hand to move towards or away from the forearm.                                                                                        | `Vector3(0.320, 0.640, 0.960),0.872` | `Vector3(0.365, 0.730, 0.583),1.047` | N/A                                  | N/A                                  |

@export
var bone_configurations = {
	"Root": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))]},
	"Hips": {"kususdama": [LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(0.0))]},
	"Spine": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0))]},
	"Chest": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(20.0))]},
	"UpperChest": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0))]},
	"Head": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(30.0))]},
	"Neck": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(20.0))]},
	"LeftUpperArm": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]},
	"RightUpperArm": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]},
	"LeftLowerArm": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
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
	"LeftUpperLeg": {},
	"RightUpperLeg": {},
	"LeftLowerLeg": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
	"RightLowerLeg": {
		"kususdama": [
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
			LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
		]
	},
}
