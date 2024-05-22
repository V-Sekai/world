let lastOp;
export function logGL(gl, func, ...args) {
  // console.debug(performance.now(), func+"()", args);
  // checkErr(gl);
  // lastOp = `${func}(${args.map(x=>(x&&typeof(x)==="object")?"object":x)})`;
  // console.log(lastOp);
}

export const gl = WebGL2RenderingContext;
export const TypedArray = {
  [gl.BYTE]: Int8Array,
  [gl.UNSIGNED_BYTE]: Uint8Array,
  [gl.SHORT]: Int16Array,
  [gl.UNSIGNED_SHORT]: Uint16Array,
  [gl.INT]: Int32Array,
  [gl.UNSIGNED_INT]: Uint32Array,
  [gl.FLOAT]: Float32Array,
  [gl.HALF_FLOAT]: Uint16Array,
};
export const nameGL = Object.fromEntries(
  Object.entries(WebGL2RenderingContext).map(([k, v]) => [v, k])
);

function checkErr(gl) {
  if (gl.getError === undefined) return;
  const lastErr = gl.getError();
  if (lastErr !== 0) alert(`lastErr=${lastErr}, lastOp=${lastOp}`);
}
