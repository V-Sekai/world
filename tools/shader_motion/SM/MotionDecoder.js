import { vec3, quat, mat4 } from "../gl-matrix.js";
import { SwingTwist, DecodeVideoFloat, orthogonalize } from "./ShaderImpl.js";

// ported from MotionDecoder.cs
const PositionScale = 2;
const RotationTolerance = 0.1;
const layerSize = 3;
export class MotionDecoder {
  constructor(layout, width = 80, height = 45, tileRadix = 3, tileLen = 2) {
    this.layout = layout;
    this.motions = layout.bones.map(() => [
      vec3.create(),
      quat.fromValues(0, 0, 0, NaN),
      NaN,
    ]);
    this.tileCount = [width / tileLen, height];
    this.tilePow = Math.pow(tileRadix, tileLen * 3);
  }
  SampleTile(idx) {
    let x = (idx / this.tileCount[1]) >> 0;
    let y = idx % this.tileCount[1];
    x += (this.layer >> 1) * layerSize;
    if ((this.layer & 1) != 0) x = this.tileCount[0] - 1 - x;

    x *= this.texSizeX / this.tileCount[0];
    y *= this.texSizeY / this.tileCount[1];
    return this.tex[
      ((this.texSizeY - 1 - y) * this.texSizeX + x) * this.texSizeZ
    ];
  }
  Update(req, layer = 0) {
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
    for (let b = 0; b < this.layout.bones.length; b++) {
      buf.fill(0);
      for (let axis = 0; axis < this.layout.bones[b].length; axis++)
        if (this.layout.bones[b][axis] >= 0)
          vec[(axis / 3) >> 0][axis % 3] = this.SampleTile(
            this.layout.bones[b][axis]
          );

      let [position, rotation, scale] = this.motions[b];
      if (this.layout.bones[b].length <= 3) {
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
      this.motions[b][2] = scale;
    }

    // TODO: implement shape
  }
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
