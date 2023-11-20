import { logGL, nameGL, TypedArray } from "./common.js";
import { loadProgram } from "./program.js";
import { bindBuffer } from "./buffer.js";

const _VAO = Symbol("GLVertexArray");
const numOfComp = {
  SCALAR: 1,
  VEC2: 2,
  VEC3: 3,
  VEC4: 4,
  MAT2: 4,
  MAT3: 9,
  MAT4: 16,
};

// accessor: gltf.accessor
// attributes: {[semantic: string]: gltf.accessor}
// technique: KHR_techniques_webgl.technique
export function bindAttribute(gl, loc, accessor) {
  // note: gltf2 doesn't support integer-valued attribute (vertexAttribIPointer)
  const {
    type,
    componentType,
    byteOffset = 0,
    normalized = false,
    bufferView$: { byteStride = 0 },
  } = accessor;
  bindBuffer(gl, accessor.bufferView$, gl.ARRAY_BUFFER);
  logGL(
    gl,
    "vertexAttribPointer",
    loc,
    numOfComp[type],
    nameGL[componentType],
    normalized,
    byteStride,
    byteOffset
  );
  gl.vertexAttribPointer(
    loc,
    numOfComp[type],
    componentType,
    normalized,
    byteStride,
    byteOffset
  );
  gl.enableVertexAttribArray(loc);
}
export function bindAttributes(gl, attributes, technique) {
  // note: bindings are cached as vertex array object
  const main = attributes.POSITION || attributes; // associate VAO to the main attribute
  if (main.hasOwnProperty(_VAO)) return gl.bindVertexArray(main[_VAO]);
  const prog = loadProgram(gl, technique.program$);
  const vao = (main[_VAO] = gl.createVertexArray());
  gl.bindVertexArray(vao);
  for (const [name, attr] of Object.entries(technique.attributes)) {
    const loc = gl.getAttribLocation(prog, name);
    const acc = attributes[attr.semantic || name];
    if (loc !== -1 && acc !== undefined) bindAttribute(gl, loc, acc);
  }
}
export async function viewAccessor(accessor) {
  const data = await accessor.bufferView$._data;
  const { type, componentType, byteOffset = 0, count } = accessor;
  return new TypedArray[componentType](
    data.buffer,
    data.byteOffset + byteOffset,
    count * numOfComp[type]
  );
}
// primitive: gltf.mesh.primitive
export function drawPrimitive(gl, primitive) {
  const {
    mode = gl.TRIANGLES,
    indices$: { count, componentType, byteOffset = 0 } = {},
  } = primitive;
  if (count === undefined)
    // no indices
    gl.drawArrays(mode, 0, primitive.attributes$.POSITION.count);
  else if (
    bindBuffer(gl, primitive.indices$.bufferView$, gl.ELEMENT_ARRAY_BUFFER)
  )
    gl.drawElements(mode, count, componentType, byteOffset);
}
