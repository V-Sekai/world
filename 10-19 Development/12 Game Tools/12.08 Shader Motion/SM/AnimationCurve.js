export class AnimationCurve {
  constructor(precision = 1e-3) {
    this.keys = new Float32Array(32); // even: time, odd: value
    this.length = 0;
    this.precision = precision;
  }
  Add(time, value) {
    let n = this.length;
    if (n * 2 == this.keys.length) {
      const keys = new Float32Array(
        this.keys.length + ((this.keys.length >> 2) << 1)
      ); // 1.5x array growth
      keys.set(this.keys);
      this.keys = keys;
    }
    while (n >= 2) {
      // very simple keyframe reduction
      const time0 = this.keys[n * 2 - 4],
        value0 = this.keys[n * 2 - 3];
      const time1 = this.keys[n * 2 - 2],
        value1 = this.keys[n * 2 - 1];
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
    this.keys[n * 2 + 0] = time;
    this.keys[n * 2 + 1] = value;
    this.length = n + 1;
  }
}
const classIDByType = { Animator: 95 };
export function SerializeAnimationClip({
  name = "",
  curves = [],
  frameRate = 60,
}) {
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
  for (const [relativePath, type, propertyName, curve] of curves) {
    if (curve.length)
      maxTime = Math.max(maxTime, curve.keys[curve.length * 2 - 2]);
    output.push(
      `  - curve:
      serializedVersion: 2
      m_Curve:
`
    );
    for (let i = 0; i < curve.length; i++)
      output.push(
        `      - serializedVersion: 2
        time: ${curve.keys[i * 2 + 0].toFixed(4)}
        value: ${curve.keys[i * 2 + 1].toFixed(4)}
`
      );
    output.push(
      `      m_PreInfinity: 2
      m_PostInfinity: 2
      m_RotationOrder: 4
    attribute: ${propertyName}
    path: ${relativePath}
    classID: ${classIDByType[type]}
    script:
`
    );
  }
  output.push(
    `  m_PPtrCurves: []
  m_SampleRate: ${frameRate}
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
