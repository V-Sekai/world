import { SwingTwist } from "./MotionDecoder.js";
const { vec3, quat } = glMatrix;

// ported from MotionLayout.cs
export const skeleton = {};
skeleton.bones = [
  "Hips",
  "LeftUpperLeg",
  "RightUpperLeg",
  "LeftLowerLeg",
  "RightLowerLeg",
  "LeftFoot",
  "RightFoot",
  "Spine",
  "Chest",
  "Neck",
  "Head",
  "LeftShoulder",
  "RightShoulder",
  "LeftUpperArm",
  "RightUpperArm",
  "LeftLowerArm",
  "RightLowerArm",
  "LeftHand",
  "RightHand",
  "LeftToes",
  "RightToes",
  "LeftEye",
  "RightEye",
  "Jaw",
  "Left Thumb Proximal",
  "Left Thumb Intermediate",
  "Left Thumb Distal",
  "Left Index Proximal",
  "Left Index Intermediate",
  "Left Index Distal",
  "Left Middle Proximal",
  "Left Middle Intermediate",
  "Left Middle Distal",
  "Left Ring Proximal",
  "Left Ring Intermediate",
  "Left Ring Distal",
  "Left Little Proximal",
  "Left Little Intermediate",
  "Left Little Distal",
  "Right Thumb Proximal",
  "Right Thumb Intermediate",
  "Right Thumb Distal",
  "Right Index Proximal",
  "Right Index Intermediate",
  "Right Index Distal",
  "Right Middle Proximal",
  "Right Middle Intermediate",
  "Right Middle Distal",
  "Right Ring Proximal",
  "Right Ring Intermediate",
  "Right Ring Distal",
  "Right Little Proximal",
  "Right Little Intermediate",
  "Right Little Distal",
  "UpperChest",
];

// ported from HumanPoser.cs
const boneMuscles = [
  [
    [-1, 1],
    [-1, 1],
    [-1, 1],
  ],
  [
    [23, 1],
    [22, 1],
    [21, 1],
  ],
  [
    [31, 1],
    [30, 1],
    [29, 1],
  ],
  [
    [25, 1],
    [23, 1],
    [24, 1],
  ],
  [
    [33, 1],
    [31, 1],
    [32, 1],
  ],
  [
    [25, 1],
    [27, 1],
    [26, 1],
  ],
  [
    [33, 1],
    [35, 1],
    [34, 1],
  ],
  [
    [2, 1],
    [1, 1],
    [0, 1],
  ],
  [
    [5, 1],
    [4, 1],
    [3, 1],
  ],
  [
    [11, 1],
    [10, 1],
    [9, 1],
  ],
  [
    [14, 1],
    [13, 1],
    [12, 1],
  ],
  [
    [41, 1],
    [38, 1],
    [37, 1],
  ],
  [
    [50, 1],
    [47, 1],
    [46, 1],
  ],
  [
    [41, 1],
    [40, 1],
    [39, 1],
  ],
  [
    [50, 1],
    [49, 1],
    [48, 1],
  ],
  [
    [43, 1],
    [41, -1],
    [42, 1],
  ],
  [
    [52, 1],
    [50, -1],
    [51, 1],
  ],
  [
    [43, 1],
    [45, 1],
    [44, 1],
  ],
  [
    [52, 1],
    [54, 1],
    [53, 1],
  ],
  [
    [-1, 1],
    [27, 1],
    [28, 1],
  ],
  [
    [-1, 1],
    [35, 1],
    [36, 1],
  ],
  [
    [14, 1],
    [16, 1],
    [15, 1],
  ],
  [
    [14, 1],
    [18, 1],
    [17, 1],
  ],
  [
    [-1, 1],
    [20, 1],
    [19, 1],
  ],
  [
    [-1, 1],
    [56, 1],
    [55, 1],
  ],
  [
    [-1, 1],
    [56, 1],
    [57, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [58, 1],
  ],
  [
    [-1, 1],
    [60, 1],
    [59, 1],
  ],
  [
    [-1, 1],
    [60, 1],
    [61, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [62, 1],
  ],
  [
    [-1, 1],
    [64, 1],
    [63, 1],
  ],
  [
    [-1, 1],
    [64, 1],
    [65, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [66, 1],
  ],
  [
    [-1, 1],
    [68, 1],
    [67, 1],
  ],
  [
    [-1, 1],
    [68, 1],
    [69, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [70, 1],
  ],
  [
    [-1, 1],
    [72, 1],
    [71, 1],
  ],
  [
    [-1, 1],
    [72, 1],
    [73, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [74, 1],
  ],
  [
    [-1, 1],
    [76, 1],
    [75, 1],
  ],
  [
    [-1, 1],
    [76, 1],
    [77, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [78, 1],
  ],
  [
    [-1, 1],
    [80, 1],
    [79, 1],
  ],
  [
    [-1, 1],
    [80, 1],
    [81, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [82, 1],
  ],
  [
    [-1, 1],
    [84, 1],
    [83, 1],
  ],
  [
    [-1, 1],
    [84, 1],
    [85, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [86, 1],
  ],
  [
    [-1, 1],
    [88, 1],
    [87, 1],
  ],
  [
    [-1, 1],
    [88, 1],
    [89, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [90, 1],
  ],
  [
    [-1, 1],
    [92, 1],
    [91, 1],
  ],
  [
    [-1, 1],
    [92, 1],
    [93, 1],
  ],
  [
    [-1, 1],
    [-1, 1],
    [94, 1],
  ],
  [
    [8, 1],
    [7, 1],
    [6, 1],
  ],
];
const muscleLimits = [
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-20, 20],
  [-20, 20],
  [-20, 20],
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-40, 40],
  [-10, 15],
  [-20, 20],
  [-10, 15],
  [-20, 20],
  [-10, 10],
  [-10, 10],
  [-90, 50],
  [-60, 60],
  [-60, 60],
  [-80, 80],
  [-90, 90],
  [-50, 50],
  [-30, 30],
  [-50, 50],
  [-90, 50],
  [-60, 60],
  [-60, 60],
  [-80, 80],
  [-90, 90],
  [-50, 50],
  [-30, 30],
  [-50, 50],
  [-15, 30],
  [-15, 15],
  [-60, 100],
  [-100, 100],
  [-90, 90],
  [-80, 80],
  [-90, 90],
  [-80, 80],
  [-40, 40],
  [-15, 30],
  [-15, 15],
  [-60, 100],
  [-100, 100],
  [-90, 90],
  [-80, 80],
  [-90, 90],
  [-80, 80],
  [-40, 40],
  [-20, 20],
  [-25, 25],
  [-40, 35],
  [-40, 35],
  [-50, 50],
  [-20, 20],
  [-45, 45],
  [-45, 45],
  [-50, 50],
  [-7.5, 7.5],
  [-45, 45],
  [-45, 45],
  [-50, 50],
  [-7.5, 7.5],
  [-45, 45],
  [-45, 45],
  [-50, 50],
  [-20, 20],
  [-45, 45],
  [-45, 45],
  [-20, 20],
  [-25, 25],
  [-40, 35],
  [-40, 35],
  [-50, 50],
  [-20, 20],
  [-45, 45],
  [-45, 45],
  [-50, 50],
  [-7.5, 7.5],
  [-45, 45],
  [-45, 45],
  [-50, 50],
  [-7.5, 7.5],
  [-45, 45],
  [-45, 45],
  [-50, 50],
  [-20, 20],
  [-45, 45],
  [-45, 45],
];
const spreadMassQ = [
  [7, [21.04, -29.166, -29.166]],
  [8, [21.04, -18.517, -18.517]],
];
export class HumanPose {
  constructor() {
    return {
      muscles: new Float32Array(muscleLimits.length),
      bodyPosition: vec3.create(),
      bodyRotation: quat.create(),
    };
  }
}
export const HumanPoser = {
  setHipsPositionRotation(pose, hipsT, hipsQ, humanScale) {
    const spreadQ = quat.create();
    const q = quat.create();
    for (const [i, scale] of spreadMassQ) {
      SwingTwist(
        q,
        pose.muscles[boneMuscles[i][0][0]] * scale[0],
        pose.muscles[boneMuscles[i][1][0]] * scale[1],
        pose.muscles[boneMuscles[i][2][0]] * scale[2]
      );
      quat.mul(spreadQ, spreadQ, q);
    }
    quat.mul(spreadQ, quat.fromValues(+0.5, +0.5, +0.5, 0.5), spreadQ);
    quat.mul(spreadQ, spreadQ, quat.fromValues(-0.5, -0.5, -0.5, 0.5));
    quat.mul(pose.bodyRotation, hipsQ, spreadQ);
    vec3.scale(pose.bodyPosition, hipsT, 1 / humanScale);
  },
  setBoneSwingTwists(pose, motions) {
    pose.muscles.fill(0);
    for (let i = 0; i < skeleton.bones.length; i++)
      for (let j = 0; j < 3; j++) {
        const boneR = motions[i][1];
        const [muscle, weight] = boneMuscles[i][j];
        if (muscle >= 0) pose.muscles[muscle] += boneR[j] * weight;
      }
    for (let i = 0; i < muscleLimits.length; i++)
      pose.muscles[i] /=
        pose.muscles[i] >= 0 ? muscleLimits[i][1] : -muscleLimits[i][0];
  },
};
