function RetargetBones(srcBones, dstBones) {
  return srcBones.map((bone) => {
    let i = -1;
    for (let b = bone; b && i < 0; b = b._parent) i = dstBones.lastIndexOf(b);
    return i;
  });
}
function RetargetBoneWeights([boneIndices, weights], boneMap) {
  const dict = new Map();
  for (let v = 0; v < boneIndices.length / 4; v++) {
    dict.clear();
    for (let i = 0; i < 4; i++) {
      const b = boneMap[boneIndices[v * 4 + i]];
      dict.set(b, (dict.get(b) || 0) + weights[v * 4 + i]);
    }
    const lst = [...dict.entries()].sort((x, y) => y[1] - x[1]);
    for (let i = 0; i < 4; i++)
      [boneIndices[v * 4 + i], weights[v * 4 + i]] = lst[i] || [0, 0];
  }
}
export function RetargetBindposesBoneWeights(srcBones, dstBones, boneWeights) {
  const boneMap = RetargetBones(srcBones, dstBones).map((x) => (x < 0 ? 0 : x));
  return RetargetBoneWeights(boneWeights, boneMap);
}
