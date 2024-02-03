# README

## Joint Rules

Instead, I recommend the rule that the +Y axis is pointed from the parent joint to the child joint as the roll axis, and the +X rotation bend the joints to the inside of the body (it is almost the direction of the muscle contraction). This is the rule I adopted as the ReferencePose for SkeletonProfileHumanoid in Godot 4.

This rule is compatible with Blender's bone format since in Blender's default settings will point the bone's +Y axis implicitly from the Head to the Tail. Also, you can check if the Joint Rules are correct by selecting multiple bones and rotating them to the +X direction in the local/independent mode, and see if the joints bend to the inside of the body.

```
Root
└─ Hips
	├─ LeftUpperLeg
	│  └─ LeftLowerLeg
	│     └─ LeftFoot
	│        └─ LeftToes
	├─ RightUpperLeg
	│  └─ RightLowerLeg
	│     └─ RightFoot
	│        └─ RightToes
	└─ Spine
		└─ Chest
			└─ UpperChest
				├─ Neck
				│   └─ Head
				│       ├─ Jaw
				│       ├─ LeftEye
				│       └─ RightEye
				├─ LeftShoulder
				│  └─ LeftUpperArm
				│     └─ LeftLowerArm
				│        └─ LeftHand
				│           ├─ LeftThumbMetacarpal
				│           │  └─ LeftThumbProximal
				│           ├─ LeftIndexProximal
				│           │  └─ LeftIndexIntermediate
				│           │    └─ LeftIndexDistal
				│           ├─ LeftMiddleProximal
				│           │  └─ LeftMiddleIntermediate
				│           │    └─ LeftMiddleDistal
				│           ├─ LeftRingProximal
				│           │  └─ LeftRingIntermediate
				│           │    └─ LeftRingDistal
				│           └─ LeftLittleProximal
				│              └─ LeftLittleIntermediate
				│                └─ LeftLittleDistal
				└─ RightShoulder
					└─ RightUpperArm
						└─ RightLowerArm
							└─ RightHand
							├─ RightThumbMetacarpal
							│  └─ RightThumbProximal
							├─ RightIndexProximal
							│  └─ RightIndexIntermediate
							│     └─ RightIndexDistal
							├─ RightMiddleProximal
							│  └─ RightMiddleIntermediate
							│     └─ RightMiddleDistal
							├─ RightRingProximal
							│  └─ RightRingIntermediate
							│     └─ RightRingDistal
							└─ RightLittleProximal
								└─ RightLittleIntermediate
									└─ RightLittleDistal
```
