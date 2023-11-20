import { vec3, quat } from "../gl-matrix.js";
// ported from HumanAxes.cs
export function SwingTwist(out, x, y, z) {
  const deg2rad = Math.PI / 180;
  const degreeYZ = vec3.fromValues(0, y, z);
  const degreeYZlength = vec3.length(degreeYZ);
  vec3.normalize(degreeYZ, degreeYZ);
  quat.setAxisAngle(out, degreeYZ, deg2rad * degreeYZlength);
  quat.rotateX(out, out, deg2rad * x);
}
// ported from ShaderImpl.cs
export function DecodeVideoFloat(hi, lo, pow) {
  hi = hi * ((pow - 1) / 2) + (pow - 1) / 2;
  lo = lo * ((pow - 1) / 2) + (pow - 1) / 2;
  let x = Math.round(lo);
  let y = Math.min(lo - x, 0);
  let z = Math.max(lo - x, 0);
  let r = Math.round(hi);
  if ((r & 1) != 0) [x, y, z] = [pow - 1 - x, -z, -y];
  if (x == 0) y += Math.min(0, hi - r);
  if (x == pow - 1) z += Math.max(0, hi - r);
  x += r * pow;
  x -= (pow * pow - 1) / 2;
  y += 0.5;
  z -= 0.5;
  return (
    (((y + z) / Math.max(Math.abs(y), Math.abs(z))) * 0.5 + x) / ((pow - 1) / 2)
  );
}
export function orthogonalize(U, V, u, v) {
  let B = vec3.dot(u, v) * -2;
  let A = vec3.dot(u, u) + vec3.dot(v, v);
  A += Math.sqrt(Math.max(0, A * A - B * B));
  vec3.scale(U, u, A);
  vec3.scaleAndAdd(U, U, v, B);
  vec3.scale(U, U, vec3.dot(u, U) / vec3.dot(U, U));
  vec3.scale(V, v, A);
  vec3.scaleAndAdd(V, V, u, B);
  vec3.scale(V, V, vec3.dot(v, V) / vec3.dot(V, V));
}
