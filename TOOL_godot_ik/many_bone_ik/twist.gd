
const twist_zero = deg_to_rad(0.0)
const lower_leg_twist = deg_to_rad(-65.0)
const left_shoulder_twist = deg_to_rad(15.0)
const right_shoulder_twist = deg_to_rad(-15.0)

@export
var bone_configurations = {
	"Root": {"twist_from": twist_zero, "twist_range": deg_to_rad(1)},
	"Hips": {"twist_from": twist_zero, "twist_range": deg_to_rad(1)},
	"Spine": {"twist_from": twist_zero, "twist_range": deg_to_rad(20.0)},
	"Chest": {"twist_from": twist_zero, "twist_range": deg_to_rad(15.0)},
	"UpperChest": {"twist_from": twist_zero, "twist_range": deg_to_rad(10.0)},
	"Head": {"twist_from": twist_zero, "twist_range": deg_to_rad(10.0)},
	"Neck": {"twist_from": twist_zero, "twist_range": deg_to_rad(15.0)},
	"LeftUpperArm": {"twist_from": deg_to_rad(60.0), "twist_range": deg_to_rad(30.0)},
	"RightUpperArm": {"twist_from": deg_to_rad(60.0), "twist_range": deg_to_rad(30.0)},
	"LeftLowerArm": {"twist_from": deg_to_rad(-55.0), "twist_range": deg_to_rad(70.0)},
	"RightLowerArm": {"twist_from": deg_to_rad(-145.0), "twist_range": deg_to_rad(70.0)},
	"LeftUpperLeg": {"twist_from": deg_to_rad(-30), "twist_range": deg_to_rad(45.0)},
	"RightUpperLeg": {"twist_from": deg_to_rad(150), "twist_range": deg_to_rad(45.0)},
	"LeftLowerLeg": {"twist_from": lower_leg_twist, "twist_range": deg_to_rad(25.0)},
	"RightLowerLeg": {"twist_from": lower_leg_twist, "twist_range": deg_to_rad(25.0)},
	"LeftShoulder": {"twist_from": left_shoulder_twist, "twist_range": deg_to_rad(30.0)},
	"RightShoulder": {"twist_from": right_shoulder_twist, "twist_range": deg_to_rad(30.0)},
}
