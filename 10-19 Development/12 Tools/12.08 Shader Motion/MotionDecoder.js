const { vec3, quat, mat4 } = glMatrix;

// ported from HumanAxes.cs
export function SwingTwist(out, x, y, z) {
  const deg2rad = Math.PI / 180;
  const degreeYZ = vec3.fromValues(0, y, z);
  const degreeYZlength = vec3.length(degreeYZ);
  vec3.normalize(degreeYZ, degreeYZ);
  quat.setAxisAngle(out, degreeYZ, deg2rad * degreeYZlength);
  quat.rotateX(out, out, deg2rad * x);
}

function LookRotation(out, z, y) {
  const x = vec3.create();
  vec3.normalize(y, y);
  vec3.normalize(z, z);
  vec3.cross(x, y, z);
  mat4.getRotation(
    out,
    mat4.fromValues(
      x[0],
      x[1],
      x[2],
      0,
      y[0],
      y[1],
      y[2],
      0,
      z[0],
      z[1],
      z[2],
      0,
      0,
      0,
      0,
      1
    )
  );
}

// ported from ShaderImpl.cs
function DecodeVideoFloat(hi, lo, pow) {
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
function orthogonalize(U, V, u, v) {
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

// ported from MotionLayout.cs
const layout = {};
layout.baseIndices = [
  0, 27, 30, 33, 36, 39, 42, 12, 15, 21, 24, 45, 48, 51, 54, 57, 60, 63, 66, 69,
  70, 71, 73, 75, 90, 92, 93, 94, 96, 97, 98, 100, 101, 102, 104, 105, 106, 108,
  109, 110, 112, 113, 114, 116, 117, 118, 120, 121, 122, 124, 125, 126, 128,
  129, 18,
];
layout.channels = [
  [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [0, 1, 2],
  [2],
  [2],
  [1, 2],
  [1, 2],
  [1, 2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [1, 2],
  [2],
  [2],
  [0, 1, 2],
];

// ported from MotionDecoder.cs
const PositionScale = 2;
const RotationTolerance = 0.1;
export class MotionDecoder {
  constructor(width = 80, height = 45, tileRadix = 3, tileLen = 2) {
    this.motions = layout.baseIndices.map(() => [
      vec3.create(),
      quat.fromValues(0, 0, 0, NaN),
      NaN,
    ]);
    this.tileCount = [width / tileLen, height];
    this.tilePow = Math.pow(tileRadix, tileLen * 3);
  }
  sampleTile(idx) {
    let x = (idx / this.tileCount[1]) >> 0;
    let y = idx % this.tileCount[1];
    x += (this.layer >> 1) * 3;
    if ((this.layer & 1) != 0) x = this.tileCount[0] - 1 - x;

    x *= this.texSizeX / this.tileCount[0];
    y *= this.texSizeY / this.tileCount[1];
    return this.tex[
      ((this.texSizeY - 1 - y) * this.texSizeX + x) * this.texSizeZ
    ];
  }
  update(req, layer = 0) {
    this.tex = req.getData();
    this.texSizeX = req.width;
    this.texSizeY = req.height;
    this.texSizeZ = 1;
    this.layer = layer;

    const buf = new Float32Array(5 * 3);
    const vec = Array.from({ length: 5 }, (_, i) =>
      buf.subarray(i * 3, i * 3 + 3)
    );
    const rotY = vec3.create();
    const rotZ = vec3.create();
    for (let i = 0; i < layout.baseIndices.length; i++) {
      buf.fill(0);
      let idx = layout.baseIndices[i];
      for (let j of layout.channels[i])
        vec[(j / 3) >> 0][j % 3] = this.sampleTile(idx++);

      let [position, rotation, scale] = this.motions[i];
      if (layout.channels[i][0] < 3) {
        vec3.scale(rotation, vec[0], 180);
        rotation[3] = NaN;
      } else {
        for (let j = 0; j < 3; j++)
          vec[2][j] = DecodeVideoFloat(vec[1][j], vec[2][j], this.tilePow);
        orthogonalize(rotY, rotZ, vec[3], vec[4]);

        const lenY = vec3.length(rotY);
        const lenZ = vec3.length(rotZ);
        const err =
          vec3.squaredDistance(vec[3], rotY) +
          vec3.squaredDistance(vec[4], rotZ) +
          // + (Math.max(lenY, lenZ)-1)**2;
          Math.max(0.1 - Math.max(lenY, lenZ), 0) ** 2;
        if (err > RotationTolerance * RotationTolerance)
          vec[2][0] = vec[2][1] = vec[2][2] = NaN;

        vec3.scale(position, vec[2], PositionScale);
        scale = lenY / lenZ;
        LookRotation(rotation, rotZ, rotY);
      }
      this.motions[i][2] = scale;
    }
  }
}
