import { logGL, nameGL } from "./common.js";

const _BUFFER = Symbol("GLBuffer"),
  _READY = Symbol("ready");

// bufferView: gltf.bufferView & {_data: Thenable<ArrayBufferView>}
export function bindBuffer(gl, bufferView, defaultTarget) {
  const { target = defaultTarget, usage = gl.STATIC_DRAW } = bufferView;
  if (bufferView.hasOwnProperty(_BUFFER))
    return gl.bindBuffer(target, bufferView[_BUFFER]), bufferView[_READY];
  const prog = (bufferView[_BUFFER] = gl.createBuffer());
  gl.bindBuffer(target, prog);
  bufferView._data.then((data) => {
    logGL(gl, "bufferData", nameGL[target], data, nameGL[usage]);
    gl.bindBuffer(target, prog);
    gl.bufferData(target, data, usage);
    bufferView[_READY] = true;
  });
  return bufferView[_READY];
}
