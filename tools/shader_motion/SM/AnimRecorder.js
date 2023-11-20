import { quat } from "../gl-matrix.js";
import { AnimationCurve, SerializeAnimationClip } from "./AnimationCurve.js";

const AnimatorMuscleName = [
  "Spine Front-Back",
  "Spine Left-Right",
  "Spine Twist Left-Right",
  "Chest Front-Back",
  "Chest Left-Right",
  "Chest Twist Left-Right",
  "UpperChest Front-Back",
  "UpperChest Left-Right",
  "UpperChest Twist Left-Right",
  "Neck Nod Down-Up",
  "Neck Tilt Left-Right",
  "Neck Turn Left-Right",
  "Head Nod Down-Up",
  "Head Tilt Left-Right",
  "Head Turn Left-Right",
  "Left Eye Down-Up",
  "Left Eye In-Out",
  "Right Eye Down-Up",
  "Right Eye In-Out",
  "Jaw Close",
  "Jaw Left-Right",
  "Left Upper Leg Front-Back",
  "Left Upper Leg In-Out",
  "Left Upper Leg Twist In-Out",
  "Left Lower Leg Stretch",
  "Left Lower Leg Twist In-Out",
  "Left Foot Up-Down",
  "Left Foot Twist In-Out",
  "Left Toes Up-Down",
  "Right Upper Leg Front-Back",
  "Right Upper Leg In-Out",
  "Right Upper Leg Twist In-Out",
  "Right Lower Leg Stretch",
  "Right Lower Leg Twist In-Out",
  "Right Foot Up-Down",
  "Right Foot Twist In-Out",
  "Right Toes Up-Down",
  "Left Shoulder Down-Up",
  "Left Shoulder Front-Back",
  "Left Arm Down-Up",
  "Left Arm Front-Back",
  "Left Arm Twist In-Out",
  "Left Forearm Stretch",
  "Left Forearm Twist In-Out",
  "Left Hand Down-Up",
  "Left Hand In-Out",
  "Right Shoulder Down-Up",
  "Right Shoulder Front-Back",
  "Right Arm Down-Up",
  "Right Arm Front-Back",
  "Right Arm Twist In-Out",
  "Right Forearm Stretch",
  "Right Forearm Twist In-Out",
  "Right Hand Down-Up",
  "Right Hand In-Out",
  "LeftHand.Thumb.1 Stretched",
  "LeftHand.Thumb.Spread",
  "LeftHand.Thumb.2 Stretched",
  "LeftHand.Thumb.3 Stretched",
  "LeftHand.Index.1 Stretched",
  "LeftHand.Index.Spread",
  "LeftHand.Index.2 Stretched",
  "LeftHand.Index.3 Stretched",
  "LeftHand.Middle.1 Stretched",
  "LeftHand.Middle.Spread",
  "LeftHand.Middle.2 Stretched",
  "LeftHand.Middle.3 Stretched",
  "LeftHand.Ring.1 Stretched",
  "LeftHand.Ring.Spread",
  "LeftHand.Ring.2 Stretched",
  "LeftHand.Ring.3 Stretched",
  "LeftHand.Little.1 Stretched",
  "LeftHand.Little.Spread",
  "LeftHand.Little.2 Stretched",
  "LeftHand.Little.3 Stretched",
  "RightHand.Thumb.1 Stretched",
  "RightHand.Thumb.Spread",
  "RightHand.Thumb.2 Stretched",
  "RightHand.Thumb.3 Stretched",
  "RightHand.Index.1 Stretched",
  "RightHand.Index.Spread",
  "RightHand.Index.2 Stretched",
  "RightHand.Index.3 Stretched",
  "RightHand.Middle.1 Stretched",
  "RightHand.Middle.Spread",
  "RightHand.Middle.2 Stretched",
  "RightHand.Middle.3 Stretched",
  "RightHand.Ring.1 Stretched",
  "RightHand.Ring.Spread",
  "RightHand.Ring.2 Stretched",
  "RightHand.Ring.3 Stretched",
  "RightHand.Little.1 Stretched",
  "RightHand.Little.Spread",
  "RightHand.Little.2 Stretched",
  "RightHand.Little.3 Stretched",
];
const RootMotionNames = [
  "RootT.x",
  "RootT.y",
  "RootT.z",
  "RootQ.x",
  "RootQ.y",
  "RootQ.z",
  "RootQ.w",
];

export class AnimRecorder {
  constructor(getHumanPose, frameRate = 30) {
    this.frameRate = frameRate;
    this.getHumanPose = getHumanPose;

    this.isRecording = false;
    this.currentTime = 0;
    this.lastRootQ = quat.create();

    this.curves = new Map(
      [...RootMotionNames, ...AnimatorMuscleName].map((name) => [
        name,
        new AnimationCurve(),
      ])
    );
    this.deltaTime = 0;
    this.bucket = 0;
  }
  TakeSnapshot(deltaTime) {
    this.deltaTime += deltaTime;
    this.bucket += deltaTime * this.frameRate;
    if (this.bucket < 1) return;
    this.bucket %= 1;

    const pose = this.getHumanPose();
    // EnsureQuaternionContinuity
    if (quat.dot(pose.rootQ, this.lastRootQ) < 0)
      quat.scale(pose.rootQ, pose.rootQ, -1);
    this.lastRootQ.set(pose.rootQ);

    if (this.isRecording) this.currentTime += this.deltaTime;
    this.deltaTime = 0;
    this.isRecording = true;

    for (let i = 0; i < pose.rootT.length; i++)
      this.curves.get(`RootT.${"xyz"[i]}`).Add(this.currentTime, pose.rootT[i]);
    for (let i = 0; i < pose.rootQ.length; i++)
      this.curves
        .get(`RootQ.${"xyzw"[i]}`)
        .Add(this.currentTime, pose.rootQ[i]);
    for (let i = 0; i < pose.muscles.length; i++)
      this.curves
        .get(AnimatorMuscleName[i])
        .Add(this.currentTime, pose.muscles[i]);
  }
  SaveToClip(name = "clip") {
    const curves = [...this.curves].map(([name, curve]) => [
      "",
      "Animator",
      name,
      curve,
    ]);
    return new Blob(
      SerializeAnimationClip({
        name: name,
        curves: curves,
        frameRate: this.frameRate,
      }),
      { type: "text/yaml" }
    );
  }
}
