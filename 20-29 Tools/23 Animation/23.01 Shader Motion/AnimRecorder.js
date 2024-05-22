class AnimationCurve {
  constructor(precision = 1e-3) {
    this.frames = new Float32Array(32);
    this.length = 0;
    this.precision = precision;
  }
  add(time, value) {
    let n = this.length;
    if (n * 2 == this.frames.length) {
      const frames = new Float32Array(this.frames.length * 2);
      frames.set(this.frames);
      this.frames = frames;
    }
    while (n >= 2) {
      const time0 = this.frames[n * 2 - 4],
        value0 = this.frames[n * 2 - 3];
      const time1 = this.frames[n * 2 - 2],
        value1 = this.frames[n * 2 - 1];
      const time2 = time,
        value2 = value;
      const area = Math.abs(
        +time0 * value1 -
          time1 * value0 +
          time1 * value2 -
          time2 * value1 +
          time2 * value0 -
          time0 * value2
      );

      if (area < this.precision) n--;
      else break;
    }
    this.frames[n * 2 + 0] = time;
    this.frames[n * 2 + 1] = value;
    this.length = n + 1;
  }
}

function serializeAnimationClip(animCurves, name) {
  const output = [];

  output.push(
    `%YAML 1.1
%TAG !u! tag:unity3d.com,2011:
--- !u!74 &7400000
AnimationClip:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {fileID: 0}
  m_PrefabInstance: {fileID: 0}
  m_PrefabAsset: {fileID: 0}
  m_Name: ${name}
  serializedVersion: 6
  m_Legacy: 0
  m_Compressed: 0
  m_UseHighQualityCurve: 1
  m_RotationCurves: []
  m_CompressedRotationCurves: []
  m_EulerCurves: []
  m_PositionCurves: []
  m_ScaleCurves: []
  m_FloatCurves:
`
  );
  let maxTime = 0;
  for (let [curveName, curve] of animCurves) {
    if (curve.length)
      maxTime = Math.max(maxTime, curve.frames[curve.length * 2 - 2]);
    output.push(
      `  - curve:
      serializedVersion: 2
      m_Curve:
`
    );
    for (let i = 0; i < curve.length; i++)
      output.push(
        `      - serializedVersion: 2
        time: ${curve.frames[i * 2 + 0].toFixed(4)}
        value: ${curve.frames[i * 2 + 1].toFixed(4)}
`
      );
    output.push(
      `      m_PreInfinity: 2
      m_PostInfinity: 2
      m_RotationOrder: 4
    attribute: ${curveName}
    path:
    classID: 95
    script:
`
    );
  }
  output.push(
    `  m_PPtrCurves: []
  m_SampleRate: 30
  m_WrapMode: 0
  m_Bounds:
    m_Center: {x: 0, y: 0, z: 0}
    m_Extent: {x: 0, y: 0, z: 0}
  m_ClipBindingConstant:
    genericBindings: []
    pptrCurveMapping: []
  m_AnimationClipSettings:
    serializedVersion: 2
    m_AdditiveReferencePoseClip: {fileID: 0}
    m_AdditiveReferencePoseTime: 0
    m_StartTime: 0
    m_StopTime: ${maxTime.toFixed(4)}
    m_OrientationOffsetY: 0
    m_Level: 0
    m_CycleOffset: 0
    m_HasAdditiveReferencePose: 0
    m_LoopTime: 0
    m_LoopBlend: 0
    m_LoopBlendOrientation: 1
    m_LoopBlendPositionY: 1
    m_LoopBlendPositionXZ: 1
    m_KeepOriginalOrientation: 1
    m_KeepOriginalPositionY: 1
    m_KeepOriginalPositionXZ: 1
    m_HeightFromFeet: 0
    m_Mirror: 0
  m_EditorCurves: []
  m_EulerEditorCurves: []
  m_HasGenericRootTransform: 0
  m_HasMotionFloatCurves: 0
  m_Events: []
`
  );
  return output;
}

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

    this.curves = new Map(
      [...RootMotionNames, ...AnimatorMuscleName].map((name) => [
        name,
        new AnimationCurve(),
      ])
    );
    this.deltaTime = 0;
    this.bucket = 0;
  }
  takeSnapshot(deltaTime) {
    this.deltaTime += deltaTime;
    this.bucket += deltaTime * this.frameRate;
    if (this.bucket < 1) return;
    this.bucket %= 1;

    const pose = this.getHumanPose();

    if (this.isRecording) this.currentTime += this.deltaTime;
    this.deltaTime = 0;
    this.isRecording = true;

    for (let i = 0; i < pose.rootT.length; i++)
      this.curves.get(`RootT.${"xyz"[i]}`).add(this.currentTime, pose.rootT[i]);
    for (let i = 0; i < pose.rootQ.length; i++)
      this.curves
        .get(`RootQ.${"xyzw"[i]}`)
        .add(this.currentTime, pose.rootQ[i]);
    for (let i = 0; i < pose.muscles.length; i++)
      this.curves
        .get(AnimatorMuscleName[i])
        .add(this.currentTime, pose.muscles[i]);
  }
  saveToClip(name = "clip") {
    return new Blob(serializeAnimationClip(this.curves, name), {
      type: "text/yaml",
    });
  }
}
