import { gl, logGL, nameGL } from "./common.js";
import { loadProgram } from "./program.js";
import { loadTexture } from "./texture.js";

const _CMDLIST = Symbol("cmdlist");
const textureTarget = {
  [gl.SAMPLER_2D]: gl.TEXTURE_2D,
  [gl.SAMPLER_3D]: gl.TEXTURE_3D,
  [gl.SAMPLER_CUBE]: gl.TEXTURE_CUBE_MAP,
  [gl.SAMPLER_2D_ARRAY]: gl.TEXTURE_2D_ARRAY,
};
const uniformSetter = {
  [gl.INT]: "uniform1i",
  [gl.INT_VEC2]: "uniform2i",
  [gl.INT_VEC3]: "uniform3i",
  [gl.INT_VEC4]: "uniform4i",
  [gl.BOOL]: "uniform1i",
  [gl.BOOL_VEC2]: "uniform2i",
  [gl.BOOL_VEC3]: "uniform3i",
  [gl.BOOL_VEC4]: "uniform4i",
  [gl.FLOAT]: "uniform1f",
  [gl.FLOAT_VEC2]: "uniform2f",
  [gl.FLOAT_VEC3]: "uniform3f",
  [gl.FLOAT_VEC4]: "uniform4f",
  [gl.FLOAT_MAT2]: "uniformMatrix2f",
  [gl.FLOAT_MAT3]: "uniformMatrix3f",
  [gl.FLOAT_MAT4]: "uniformMatrix4f",
};

// uniform: KHR_techniques_webgl.technique.uniform
// values: {[semantic: string]: KHR_techniques_webgl.uniform.value}
// technique: KHR_techniques_webgl.technique
export function bindUniform(
  gl,
  loc,
  uniform,
  texCounter,
  call = (o, m, ...a) => o[m](...a)
) {
  const { type, value } = uniform;
  const target = textureTarget[type];
  if (target !== undefined) {
    const unit = texCounter[0]++;
    logGL(gl, "uniform1i", loc, unit);
    call(gl, "activeTexture", gl.TEXTURE0 + unit);
    call(
      gl,
      "bindTexture",
      target,
      value ? loadTexture(gl, value.index$) : null
    );
    call(gl, "uniform1i", loc, unit);
  } else {
    const method = uniformSetter[type];
    logGL(gl, method + "[v]", loc, value);
    if (method.startsWith("uniformMatrix"))
      call(gl, method + "v", loc, false, value);
    else if (value.length !== undefined) call(gl, method + "v", loc, value);
    else call(gl, method, loc, value);
  }
}
export function bindUniforms(gl, values, technique) {
  // note: bindings are cached as command list
  if (!values.hasOwnProperty(_CMDLIST)) {
    const prog = loadProgram(gl, technique.program$);
    const list = (values[_CMDLIST] = []),
      texCounter = [0];
    const call = (_, method, ...args) => list.push([method, args]);
    for (const [name, unif] of Object.entries(technique.uniforms)) {
      const loc = gl.getUniformLocation(prog, name);
      const { [unif.semantic || name]: val = unif.value } = values;
      if (loc !== null && val !== undefined)
        bindUniform(gl, loc, { __proto__: unif, value: val }, texCounter, call);
    }
  }
  for (const [method, args] of values[_CMDLIST]) gl[method](...args);
}
