import { logGL } from "./common.js";

const _SHADER = Symbol("GLShader"),
  _PROGRAM = Symbol("GLProgram"),
  _READY = Symbol("ready");

// shader: KHR_techniques_webgl.shader & {_data: Thenable<string>}
// program: KHR_techniques_webgl.program
export function loadShader(gl, shader) {
  if (shader.hasOwnProperty(_SHADER)) return shader[_SHADER];
  const { type } = shader;
  const s = gl.createShader(type);
  shader[_READY] = shader._data.then((data) => {
    logGL(gl, "shaderSource", s, data.split("\n", 1)[0]);
    gl.shaderSource(s, data);
    gl.compileShader(s);
  });
  return (shader[_SHADER] = s);
}
export function loadProgram(gl, program) {
  if (program.hasOwnProperty(_PROGRAM)) return program[_PROGRAM];
  const shaders = [program.vertexShader$, program.fragmentShader$];
  const prog = gl.createProgram();
  Promise.all(
    shaders.map((s) => (gl.attachShader(prog, loadShader(gl, s)), s[_READY]))
  ).then((_) => {
    gl.linkProgram(prog);
    program[_READY] = null;
  });
  return (program[_PROGRAM] = prog);
}
export function useProgram(gl, program) {
  const prog = loadProgram(gl, program);
  if (
    program[_READY] === null &&
    !(program[_READY] = gl.getProgramParameter(prog, gl.LINK_STATUS))
  ) {
    const logs = gl
      .getAttachedShaders(prog)
      .map((shader) => gl.getShaderInfoLog(shader));
    logs.unshift(gl.getProgramInfoLog(prog));
    throw new Error(logs.join("\n").replace("\n\n", "\n"));
  }
  return program[_READY] && (gl.useProgram(prog), true);
}
