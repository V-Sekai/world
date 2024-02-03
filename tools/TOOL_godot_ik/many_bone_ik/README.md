# Many Bone IK

## Rotation Twist Constraints

| Body Part                | Description                                                                                                                                                                                         | Movement Type      | From Degrees | Range |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ | ------------ | ----- |
| Head                     | The head can rotate side-to-side up to 60-70 degrees, enabling the character to look left and right.                                                                                                | side-to-side       | 60           | 10    |
| Neck                     | The neck can rotate side-to-side up to 50-60 degrees for looking left and right.                                                                                                                    | side-to-side       | 50           | 10    |
| [Side]UpperLeg (Sitting) | The upper leg can rotate slightly up to 5-10 degrees for sitting.                                                                                                                                   | slight rotation    | 5            | 5     |
| [Side]UpperArm           | The upper arm can also rotate slightly up to 30-40 degrees for more natural arm movement.                                                                                                           | slight rotation    | 30           | 10    |
| [Side]Hand               | The wrist can also rotate slightly up to 20-30 degrees, enabling the hand to twist inward or outward for grasping and gesturing.                                                                    | wrist twist        | 20           | 10    |
| Hips                     | The hips can rotate up to 45-55 degrees, allowing for twisting and turning movements.                                                                                                               | rotation           | 45           | 10    |
| Spine                    | The spine can rotate up to 20-30 degrees, providing flexibility for bending and twisting.                                                                                                           | rotation           | 20           | 10    |
| Chest                    | The chest can rotate up to 15-25 degrees, contributing to the twisting motion of the upper body.                                                                                                    | rotation           | 15           | 10    |
| UpperChest               | The upper chest can rotate up to 10-20 degrees, aiding in the overall rotation of the torso.                                                                                                        | rotation           | 10           | 10    |
| [Side]UpperLeg           | The upper leg can rotate up to 30-40 degrees, allowing for movements such as kicking or stepping.                                                                                                   | rotation           | 30           | 10    |
| [Side]LowerLeg           | The lower leg can rotate slightly up to 10-15 degrees, providing flexibility for running or jumping.                                                                                                | slight rotation    | 10           | 5     |
| [Side]Foot               | The foot can rotate inward or outward (inversion and eversion) up to 20-30 degrees, enabling balance and various stances.                                                                           | inversion/eversion | 20           | 10    |
| [Side]Shoulder           | The shoulder can rotate up to 90 degrees in a normal range of motion. This allows for movements such as lifting an arm or throwing. However, with forced movement, it can rotate beyond this limit. | rotation           | up to 90     | -     |

## Table with Descriptions and Normalized Vector3 Points for Kusudama 0 - Kusudama 3

| Body Part      | Description                                                                                                                                                                                                                              | Kusudama 0                           | Kusudama 1                           | Kusudama 2                           | Kusudama 3                           |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------ | ------------------------------------ | ------------------------------------ |
| Hips           | The hips can tilt forward and backward up to 20-30 degrees, allowing the legs to swing in a wide arc during walking or running. They can also move side-to-side up to 10-20 degrees, enabling the legs to spread apart or come together. | `Vector3(0.267, 0.535, 0.802),0.349` | `Vector3(0.373, 0.620, 0.688),0.349` | `Vector3(0.371, 0.557, 0.743),0.174` | `Vector3(0.408, 0.571, 0.733),0.174` |
| UpperChest     | The upper chest can tilt forward and backward up to 10-20 degrees, allowing for natural breathing and posture adjustments.                                                                                                               | `Vector3(0.316, 0.632, 0.949),0.174` | `Vector3(0.377, 0.755, 0.533),0.174` | N/A                                  | N/A                                  |
| Chest          | The chest can tilt forward and backward up to 10-20 degrees, allowing for natural breathing and posture adjustments.                                                                                                                     | `Vector3(0.288, 0.576, 0.864),0.174` | `Vector3(0.346, 0.691, 0.633),0.174` | N/A                                  | N/A                                  |
| Spine          | The spine can tilt forward and backward up to 35-45 degrees, allowing for bending and straightening of the torso.                                                                                                                        | `Vector3(0.291, 0.581, 0.872),0.610` | `Vector3(0.359, 0.718, 0.599),0.788` | N/A                                  | N/A                                  |
| [Side]UpperLeg | The upper leg can swing forward and backward up to 80-90 degrees, allowing for steps during walking and running.                                                                                                                         | `Vector3(0.275, 0.550, 0.826),1.396` | `Vector3(0.334, 0.668, 0.695),1.570` | N/A                                  | N/A                                  |
| [Side]LowerLeg | The knee can bend and straighten up to 110-120 degrees, allowing the lower leg to move towards or away from the upper leg during walking, running, and stepping.                                                                         | `Vector3(0.286, 0.573, 0.859),1.919` | `Vector3(0.340, 0.680, 0.680),2.094` | N/A                                  | N/A                                  |
| [Side]Foot     | The ankle can tilt up (dorsiflexion) up to 10-20 degrees and down (plantarflexion) up to 35-40 degrees, allowing the foot to step and adjust during walking and running.                                                                 | `Vector3(0.309, 0.618, 0.927),0.174` | `Vector3(0.367, 0.734, 0.567),0.698` | N/A                                  | N/A                                  |
| [Side]Shoulder | The shoulder can tilt forward and backward up to 160 degrees, allowing the arms to swing in a wide arc. They can also move side-to-side up to 40-50 degrees, enabling the arms to extend outwards or cross over the chest.               | `Vector3(0.312, 0.625, 0.938),2.792` | `Vector3(0.360, 0.720, 0.594),0.872` | N/A                                  | N/A                                  |
| [Side]UpperArm | The upper arm can swing forward and backward up to 110-120 degrees, allowing for reaching and swinging motions.                                                                                                                          | `Vector3(0.305, 0.609, 0.913),1.919` | `Vector3(0.362, 0.724, 0.586),2.094` | N/A                                  | N/A                                  |
| [Side]LowerArm | The elbow can bend and straighten up to 120-130 degrees, allowing the forearm to move towards or away from the upper arm during reaching and swinging motions.                                                                           | `Vector3(0.313, 0.625, 0.937),2.094` | `Vector3(0.361, 0.721, 0.590),2.269` | N/A                                  | N/A                                  |
| [Side]Hand     | The wrist can tilt up (wrist extension) and down (wrist flexion) up to 50-60 degrees, allowing the hand to move towards or away from the forearm.                                                                                        | `Vector3(0.320, 0.640, 0.960),0.872` | `Vector3(0.365, 0.730, 0.583),1.047` | N/A                                  | N/A                                  |



```gdscript
var bone_configurations = {
    "Root": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))], "twist_from": deg_to_rad(0.0), "twist_range": deg_to_rad(2)},
    "Head": {
        "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(35.0))],
        "twist_from": deg_to_rad(-35.0),
        "twist_range": deg_to_rad(65.0)
    },
    "Neck": {
        "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(25.0))],
        "twist_from": deg_to_rad(-25.0),
        "twist_range": deg_to_rad(55.0)
    },
    "Hips": {
        "kususdama": [LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(22.5))],
        "twist_from": deg_to_rad(-22.5),
        "twist_range": deg_to_rad(50.0)
    },
    "Spine": {
        "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(15.0))],
        "twist_from": deg_to_rad(-15.0),
        "twist_range": deg_to_rad(25.0)
    },
    "Chest": {
        "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(12.5))],
        "twist_from": deg_to_rad(-12.5),
        "twist_range": deg_to_rad(25.0)
    },
    "UpperChest": {
        "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(10.0))],
        "twist_from": deg_to_rad(-10.0),
        "twist_range": deg_to_rad(20.0)
    },
    "LeftUpperArm": {
        "twist_from": deg_to_rad(80.0),
        "twist_range": deg_to_rad(35.0),
        "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(120.0))]
    },
    "RightUpperArm": {
        "twist_from": deg_to_rad(80.0),
        "twist_range": deg_to_rad(35.0),
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
    "LeftHand": {"kususdama": [LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(65.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(70.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(40.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(45.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))]},
    "RightHand": {"kususdama": [LimitCone.new(((Vector3.MODEL_TOP + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(65.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_BOTTOM + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(70.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_LEFT + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(40.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0)), LimitCone.new(((Vector3.MODEL_RIGHT + Vector3.MODEL_FRONT) / 2.0), deg_to_rad(45.0)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(0.0))]},
    "LeftThumb": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
    "RightThumb": {"kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(90.0))]},
    "LeftUpperLeg": {
        "twist_from": deg_to_rad(-20.0),
        "twist_range": deg_to_rad(30.0)
        #"kususdama": [
            #LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
            #LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
            #LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
        #]
    },
    "RightUpperLeg": {
        "twist_from": deg_to_rad(-20.0),
        "twist_range": deg_to_rad(30.0)
        #"kususdama": [
            #LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)),
            #LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)),
            #LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))
        #]
    },
    "LeftLowerLeg": {"twist_from": deg_to_rad(-55.0), "twist_range": deg_to_rad(50.0), "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_RIGHT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))]},
    "RightLowerLeg": {"twist_from": deg_to_rad(-145.0), "twist_range": deg_to_rad(50.0), "kususdama": [LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_FRONT, deg_to_rad(2.5)), LimitCone.new(Vector3.MODEL_REAR, deg_to_rad(2.5))]},
}
```