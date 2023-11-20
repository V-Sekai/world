import { gl } from "./common.js";

const blendFuncMap = {
  OPAQUE: [gl.ONE, gl.ZERO, gl.ONE, gl.ZERO],
  MASK: [gl.ONE, gl.ZERO, gl.ONE, gl.ZERO],
  BLEND: [gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA],
};
const depthWriteMap = {
  OPAQUE: true,
  MASK: true,
  BLEND: false,
};

// material: gltf.material & {depthWrite?: boolean}
export function setStates(gl, material) {
  const {
    alphaMode = "OPAQUE",
    alphaCutoff = 0.5,
    doubleSided = false,
    depthWrite = depthWriteMap[alphaMode],
  } = material;
  gl.depthMask(depthWrite);
  gl.enable(gl.DEPTH_TEST), gl.depthFunc(gl.LEQUAL);
  gl.enable(gl.BLEND), gl.blendFuncSeparate(...blendFuncMap[alphaMode]);
  if (!doubleSided) gl.enable(gl.CULL_FACE), gl.cullFace(gl.BACK);
  else gl.disable(gl.CULL_FACE);
}
