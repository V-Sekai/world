# Bone orientation

Unity calibrates bone orientations when an avatar is imported.

In most cases, x-axis is used for twist (axial motion) and yz-axes are used for swing (spherical motion).

It's exact values can be accessed by Unity internal methods `Avatar.GetPostRotation` and `Avatar.GetLimitSign`, and **they do not match the axes of the bone Transform**.

For reference, we provide a table of calibrated bone orientations when the avatar is in T-pose (facing forward),
with Unity's axes convention +X = right, +Y = up, +Z = forward.

| Bone                         | x-axis | y-axis | z-axis | Bone                | x-axis | y-axis | z-axis |
|:-----------------------------|:-------|:-------|:-------|:--------------------|:-------|:-------|:-------|
| Hips                         | +X     | +Y     | +Z     | Left UpperLeg/Foot  | -Y     | -Z     | +X     |
| Spine/(Upper)Chest/Neck/Head | +Y     | -Z     | -X     | Left LowerLeg       | -Y     | +Z     | -X     |
| LeftEye                      |        | -Y     | -X     | Right UpperLeg/Foot | +Y     | +Z     | +X     |
| RightEye                     |        | +Y     | -X     | Right LowerLeg      | +Y     | -Z     | -X     |
| Left Shoulder/UpperArm/Hand  | -X     | -Y     | -Z     | Left Thumb          |        | -X-Z   | +Y     |
| Left LowerArm                | -X     | +Z     | -Y     | Left Index/Middle   |        | +Y     | -Z     |
| Right Shoulder/UpperArm/Hand | -X     | +Y     | +Z     | Left Ring/Little    |        | -Y     | -Z     |
| Right LowerArm               | -X     | -Z     | +Y     | Right Thumb         |        | -X+Z   | -Y     |
| Jaw                          |        | TBD    | TBD    | Right Index/Middle  |        | -Y     | +Z     |
| Left/Right Toes              |        |        | +X     | Right Ring/Little   |        | +Y     | +Z     |

There are a few things worth noting in the table.

* Some entries are omitted because the bones can't rotate in certain axes.
* Finger orientations apply to all three bones Proximal/Intermediate/Distal.
* Axes for right limbs can be derived from left ones by flipping signs of ±Y and ±Z.
* X-axis may be the opposite of bone direction, because rotation sign is baked into it.
* Some axes implicitly used by Mecanim have signs flipped to match handedness of adjacent bones.
* Hips' orientation matches rootQ in Unity and is not intended for swing-twist.

# Bone rotation

Bone rotation is computed from its neutral pose relative to its parent bone.

The neutral pose, aka motorcycle pose, can be seen in avatar's muscle settings in Unity,
and accessed by Unity internal method `Avatar.GetPreRotation`.

The rotation is **expressed by swing-twist angles**, instead of euler angles or quaternion,
for compatibility with Unity's muscle system and easier interpolation.

Here is C# code for computing bone rotation, assuming calibrated orientation.

```
boneLocalRotation = boneLocalNeutralRotation * SwingTwist(angles);
Quaternion SwingTwist(Vector3 angles) {
	var anglesYZ = new Vector3(0, angles.y, angles.z);
	return Quaternion.AngleAxis(anglesYZ.magnitude, anglesYZ.normalized)
		* Quaternion.AngleAxis(angles.x, new Vector3(1, 0, 0));
}
```

**The resulting swing-twist angles should match Unity animator's muscle values up to scaling.**

For example, the yz-angles of the bone `Left Thumb Proximal` should be more or less
the muscle values of `Left Thumb Spread` & `Left Thumb 1 Stretched` multiplied by the bone's range limit.
However, this is only an *approximation* due to the complex behavior like twist distribution in Mecanim.