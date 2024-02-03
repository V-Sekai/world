# ## Rotation Twist Constraints
#
# | Body Part                | Description                                                                                                                                                                                         | Movement Type      | From Degrees | Range |
# | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ | ------------ | ----- |
# | Head                     | The head can rotate side-to-side up to 60-70 degrees, enabling the character to look left and right.                                                                                                | side-to-side       | 60           | 10    |
# | Neck                     | The neck can rotate side-to-side up to 50-60 degrees for looking left and right.                                                                                                                    | side-to-side       | 50           | 10    |
# | [Side]UpperLeg (Sitting) | The upper leg can rotate slightly up to 5-10 degrees for sitting.                                                                                                                                   | slight rotation    | 5            | 5     |
# | [Side]UpperArm           | The upper arm can also rotate slightly up to 30-40 degrees for more natural arm movement.                                                                                                           | slight rotation    | 30           | 10    |
# | [Side]Hand               | The wrist can also rotate slightly up to 20-30 degrees, enabling the hand to twist inward or outward for grasping and gesturing.                                                                    | wrist twist        | 20           | 10    |
# | Hips                     | The hips can rotate up to 45-55 degrees, allowing for twisting and turning movements.                                                                                                               | rotation           | 45           | 10    |
# | Spine                    | The spine can rotate up to 20-30 degrees, providing flexibility for bending and twisting.                                                                                                           | rotation           | 20           | 10    |
# | Chest                    | The chest can rotate up to 15-25 degrees, contributing to the twisting motion of the upper body.                                                                                                    | rotation           | 15           | 10    |
# | UpperChest               | The upper chest can rotate up to 10-20 degrees, aiding in the overall rotation of the torso.                                                                                                        | rotation           | 10           | 10    |
# | [Side]UpperLeg           | The upper leg can rotate up to 30-40 degrees, allowing for movements such as kicking or stepping.                                                                                                   | rotation           | 30           | 10    |
# | [Side]LowerLeg           | The lower leg can rotate slightly up to 10-15 degrees, providing flexibility for running or jumping.                                                                                                | slight rotation    | 10           | 5     |
# | [Side]Foot               | The foot can rotate inward or outward (inversion and eversion) up to 20-30 degrees, enabling balance and various stances.                                                                           | inversion/eversion | 20           | 10    |
# | [Side]Shoulder           | The shoulder can rotate up to 90 degrees in a normal range of motion. This allows for movements such as lifting an arm or throwing. However, with forced movement, it can rotate beyond this limit. | rotation           | up to 90     | -     |


@export
var bone_configurations = {
    "Root": {"twist_from": deg_to_rad(0.0), "twist_range": deg_to_rad(2)},
    "Hips": {"twist_from": deg_to_rad(0.0), "twist_range": deg_to_rad(2)},
    "Spine": {"twist_from": deg_to_rad(-20.0), "twist_range": deg_to_rad(20.0)},
    "Chest": {"twist_from": deg_to_rad(-15.0), "twist_range": deg_to_rad(30.0)},
    "UpperChest": {"twist_from": deg_to_rad(-10.0), "twist_range": deg_to_rad(20.0)},
    "Head": {"twist_from": deg_to_rad(-10.0), "twist_range": deg_to_rad(20.0)},
    "Neck": {"twist_from": deg_to_rad(-15.0), "twist_range": deg_to_rad(30.0)},
    "LeftUpperArm": {"twist_from": deg_to_rad(80.0), "twist_range": deg_to_rad(30.0)},
    "RightUpperArm": {"twist_from": deg_to_rad(80.0), "twist_range": deg_to_rad(30.0)},
    "LeftLowerArm": {"twist_from": deg_to_rad(-55.0), "twist_range": deg_to_rad(70.0)},
    "RightLowerArm": {"twist_from": deg_to_rad(-145.0), "twist_range": deg_to_rad(70.0)},
    "LeftUpperLeg": {"twist_from": deg_to_rad(-45.0), "twist_range": deg_to_rad(90.0)},
    "RightUpperLeg": {"twist_from": deg_to_rad(-45.0), "twist_range": deg_to_rad(90.0)},
    "LeftLowerLeg": {"twist_from": deg_to_rad(-55.0), "twist_range": deg_to_rad(50.0)},
    "RightLowerLeg": {"twist_from": deg_to_rad(-145.0), "twist_range": deg_to_rad(50.0)},
}
