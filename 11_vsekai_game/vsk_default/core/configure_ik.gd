# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# configure_ik.gd
# SPDX-License-Identifier: MIT
@tool
extends EditorScript

const AxisLookup: Dictionary = {
	"Front-Back": Vector3(1, 0, 0),  # Assuming X-axis for Front-Back
	"Left-Right": Vector3(0, 1, 0),  # Assuming Y-axis for Left-Right
	"Twist Left-Right": Vector3(0, 0, 1),  # Assuming Z-axis for twisting
	"Nod Down-Up": Vector3(1, 0, 0),
	"Tilt Left-Right": Vector3(0, 1, 0),
	"Turn Left-Right": Vector3(0, 0, 1),
	"Down-Up": Vector3(1, 0, 0),
	"In-Out": Vector3(0, 1, 0),
	"Close": Vector3(1, 0, 0),
	"Stretch": Vector3(1, 0, 0),
	"Up-Down": Vector3(1, 0, 0),
	"Twist In-Out": Vector3(0, 0, 1),
	"Stretched": Vector3(1, 0, 0),
	"Spread": Vector3(0, 1, 0)
}

const MuscleDegrees = {
	"Spine": {
		"cones": {
			"Front-Back": { "min_degrees": -40, "max_degrees": 40 },
			"Left-Right": { "min_degrees": -40, "max_degrees": 40 }
		},
		"min_degrees": -40,
		"max_degrees": 40
	},
	"Chest": {
		"cones": {
			"Front-Back": { "min_degrees": -40, "max_degrees": 40 },
			"Left-Right": { "min_degrees": -40, "max_degrees": 40 }
		},
		"min_degrees": -40,
		"max_degrees": 40
	},
	"UpperChest": {
		"cones": {
			"Front-Back": { "min_degrees": -20, "max_degrees": 20 },
			"Left-Right": { "min_degrees": -20, "max_degrees": 20 }
		},
		"min_degrees": -20,
		"max_degrees": 20
	},
	"Neck": {
		"cones": {
			"Nod Down-Up": { "min_degrees": -40, "max_degrees": 40 },
			"Tilt Left-Right": { "min_degrees": -40, "max_degrees": 40 }
		},
		"min_degrees": -40,
		"max_degrees": 40
	},
	"Head": {
		"cones": {
			"Nod Down-Up": { "min_degrees": -40, "max_degrees": 40 },
			"Tilt Left-Right": { "min_degrees": -40, "max_degrees": 40 }
		},
		"min_degrees": -40,
		"max_degrees": 40
	},
	"LeftEye": {
		"cones": {
			"Down-Up": { "min_degrees": -10, "max_degrees": 15 },
			"In-Out": { "min_degrees": -20, "max_degrees": 20 }
		},
	},
	"RightEye": {
		"cones": {
			"Down-Up": { "min_degrees": -10, "max_degrees": 15 },
			"In-Out": { "min_degrees": -20, "max_degrees": 20 }
		},
	},
	"Jaw": {
		"cones": {
			"Close": { "min_degrees": -10, "max_degrees": 10 },
			"Left-Right": { "min_degrees": -10, "max_degrees": 10 }
		},
	},
	"LeftUpperLeg": {
		"cones": {
			"Front-Back": { "min_degrees": -90, "max_degrees": 50 },
			"In-Out": { "min_degrees": -60, "max_degrees": 60 },
			"Twist In-Out": { "min_degrees": -60, "max_degrees": 60 }
		},
		"min_degrees": -90,
		"max_degrees": 60
	},
	"LeftLowerLeg": {
		"cones": {
			"Stretch": { "min_degrees": -80, "max_degrees": 80 },
			"Twist In-Out": { "min_degrees": -90, "max_degrees": 90 }
		},
		"min_degrees": -90,
		"max_degrees": 90
	},
	"LeftFoot": {
		"cones": {
			"Up-Down": { "min_degrees": -50, "max_degrees": 50 },
			"Twist In-Out": { "min_degrees": -30, "max_degrees": 30 }
		},
		"min_degrees": -50,
		"max_degrees": 50
	},
	"LeftToes": {
		"cones": {
			"Up-Down": { "min_degrees": -50, "max_degrees": 50 }
		},
	},
	"RightUpperLeg": {
		"cones": {
			"Front-Back": { "min_degrees": -90, "max_degrees": 50 },
			"In-Out": { "min_degrees": -60, "max_degrees": 60 },
			"Twist In-Out": { "min_degrees": -60, "max_degrees": 60 }
		},
		"min_degrees": -90,
		"max_degrees": 60
	},
	"RightLowerLeg": {
		"cones": {
			"Stretch": { "min_degrees": -80, "max_degrees": 80 },
			"Twist In-Out": { "min_degrees": -90, "max_degrees": 90 }
		},
		"min_degrees": -90,
		"max_degrees": 90
	},
	"RightFoot": {
		"cones": {
			"Up-Down": { "min_degrees": -50, "max_degrees": 50 },
			"Twist In-Out": { "min_degrees": -30, "max_degrees": 30 }
		},
		"min_degrees": -50,
		"max_degrees": 50
	},
	"RightToes": {
		"cones": {
			"Up-Down": { "min_degrees": -50, "max_degrees": 50 }
		},
	},
	"LeftShoulder": {
		"cones": {
			"Down-Up": { "min_degrees": -15, "max_degrees": 30 },
			"Front-Back": { "min_degrees": -15, "max_degrees": 15 }
		},
	},
	"RightShoulder": {
		"cones": {
			"Down-Up": { "min_degrees": -15, "max_degrees": 30 },
			"Front-Back": { "min_degrees": -15, "max_degrees": 15 }
		},
	},
	"LeftArm": {
		"cones": {
			"Down-Up": { "min_degrees": -60, "max_degrees": 100 },
			"Front-Back": { "min_degrees": -100, "max_degrees": 100 },
			"Twist In-Out": { "min_degrees": -90, "max_degrees": 90 }
		},
		"min_degrees": -100,
		"max_degrees": 100
	},
	"LeftForearm": {
		"cones": {
			"Stretch": { "min_degrees": -80, "max_degrees": 80 },
			"Twist In-Out": { "min_degrees": -90, "max_degrees": 90 }
		},
		"min_degrees": -90,
		"max_degrees": 90
	},
	"LeftHand": {
		"cones": {
			"Down-Up": { "min_degrees": -40, "max_degrees": 40 },
			"In-Out": { "min_degrees": -40, "max_degrees": 40 }
		},
	},
	"RightArm": {
		"cones": {
			"Down-Up": { "min_degrees": -60, "max_degrees": 100 },
			"Front-Back": { "min_degrees": -100, "max_degrees": 100 },
			"Twist In-Out": { "min_degrees": -90, "max_degrees": 90 }
		},
		"min_degrees": -100,
		"max_degrees": 100
	},
	"RightForearm": {
		"cones": {
			"Stretch": { "min_degrees": -80, "max_degrees": 80 },
			"Twist In-Out": { "min_degrees": -90, "max_degrees": 90 }
		},
		"min_degrees": -90,
		"max_degrees": 90
	},
	"RightHand": {
		"cones": {
			"Down-Up": { "min_degrees": -40, "max_degrees": 40 },
			"In-Out": { "min_degrees": -40, "max_degrees": 40 }
		},
	},
	"LeftThumbMetacarpal": {
		"cones": {
			"Stretched": { "min_degrees": -20, "max_degrees": 20 },
			"Spread": { "min_degrees": -25, "max_degrees": 25 }
		},
	},
	"LeftThumbProximal": {
		"cones": {
			"Stretched": { "min_degrees": -35, "max_degrees": 35 }
		},
	},
	"LeftIndexProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -20, "max_degrees": 20 }
		},
	},
	"LeftIndexIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"LeftIndexDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"LeftMiddleProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -7.5, "max_degrees": 7.5 }
		},
	},
	"LeftMiddleIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"LeftMiddleDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"LeftRingProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -7.5, "max_degrees": 7.5 }
		},
	},
	"LeftRingIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"LeftRingDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"LeftLittleProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -20, "max_degrees": 20 }
		},
	},
	"LeftLittleIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"LeftLittleDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightThumbMetacarpal": {
		"cones": {
			"Stretched": { "min_degrees": -20, "max_degrees": 20 },
			"Spread": { "min_degrees": -25, "max_degrees": 25 }
		},
	},
	"RightThumbProximal": {
		"cones": {
			"Stretched": { "min_degrees": -35, "max_degrees": 35 }
		},
	},
	"RightIndexProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -20, "max_degrees": 20 }
		},
	},
	"RightIndexIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightIndexDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightMiddleProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -7.5, "max_degrees": 7.5 }
		},
	},
	"RightMiddleIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightMiddleDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightRingProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -7.5, "max_degrees": 7.5 }
		},
	},
	"RightRingIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightRingDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightLittleProximal": {
		"cones": {
			"Stretched": { "min_degrees": -50, "max_degrees": 50 },
			"Spread": { "min_degrees": -20, "max_degrees": 20 }
		},
	},
	"RightLittleIntermediate": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	},
	"RightLittleDistal": {
		"cones": {
			"Stretched": { "min_degrees": -45, "max_degrees": 45 }
		},
	}
}

var bone_constraints: Dictionary = {}

func setup_constraints(many_bone_ik: ManyBoneIK3D):
	many_bone_ik.set_constraint_count(MuscleDegrees.keys().size())
	var index = 0
	for muscle_name in MuscleDegrees.keys():
		many_bone_ik.set_constraint_name_at_index(index, muscle_name)
		var movements = MuscleDegrees[muscle_name]
		var min_degrees = movements["min_degrees"] if movements.has("min_degrees") else 0
		var max_degrees = movements["max_degrees"] if movements.has("max_degrees") else 0
		var limit = Vector2(deg_to_rad(min_degrees), deg_to_rad(max_degrees))
		many_bone_ik.set_joint_twist(index, limit)
		many_bone_ik.set_kusudama_open_cone_count(index, 0)
		many_bone_ik.set_kusudama_open_cone_count(index, movements["cones"].size())
		var is_mirrored = muscle_name.begins_with("Right")
		if movements.has("cones"):
			var cone_index = 0
			for cone in movements["cones"]:
				var original_direction = AxisLookup[cone] if AxisLookup.has(cone) else Vector3(1, 0, 0)
				var direction = mirror_direction(original_direction, is_mirrored)
				many_bone_ik.set_kusudama_open_cone_center(index, cone_index, direction)
				many_bone_ik.set_kusudama_open_cone_radius(index, cone_index, deg_to_rad(movements["cones"][cone]["max_degrees"]) - deg_to_rad(movements["cones"][cone]["min_degrees"]))
				cone_index += 1
		index += 1

func mirror_direction(direction: Vector3, is_mirrored: bool) -> Vector3:
	return direction * Vector3(-1 if is_mirrored else 1, 1, 1)
		
func _run():
	print("_run")
	var root: Node = get_scene()
	var nodes: Array[Node] = root.find_children("*", "ManyBoneIK3D")
	if nodes.is_empty():
		return
	var many_bone_ik: ManyBoneIK3D = nodes[0]
	setup_constraints(many_bone_ik)
	var bone_names = ["Root", "Hips", "RightLowerArm", "RightHand", "LeftLowerArm", "LeftHand", "Head", "RightLowerLeg", "LeftLowerLeg", "RightFoot", "LeftFoot"]
	for node in many_bone_ik.get_children():
		node.free()
	many_bone_ik.set_total_effector_count(bone_names.size())
	var skeleton = many_bone_ik.get_parent() as Skeleton3D
	for i in range(bone_names.size()):
		var node = Marker3D.new()
		node.name = bone_names[i]
		many_bone_ik.add_child(node)
		node.owner = many_bone_ik.owner
		many_bone_ik.set_effector_pin_node_path(i, bone_names[i])
		many_bone_ik.set_effector_bone_name(i, bone_names[i])
		many_bone_ik.set_pin_weight(i, 1)
		many_bone_ik.set_pin_motion_propagation_factor(i, 0)
		var bone_node = many_bone_ik.get_node_or_null(bone_names[i])
		if bone_node:
			var rest_transform = skeleton.get_bone_global_rest(skeleton.find_bone(bone_names[i]))
			node.transform = rest_transform
