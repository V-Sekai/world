import { vec3, vec4, quat, mat4 } from "../gl-matrix.js";
import { getWorldPosition } from "../GLTF/index.js";
import { viewAccessor } from "../wGLTF/index.js";
import { RetargetBindposesBoneWeights } from "./MeshUtil.js";

const Quaternion = {
  Inverse: (q) => quat.conjugate(quat.create(), q),
};
const Matrix4x4 = {
  Translate: (t) => mat4.fromTranslation(mat4.create(), t),
  Rotate: (q) => mat4.fromQuat(mat4.create(), q),
  SetRow(mat, row, v) {
    for (let col = 0; col < 4; col++) mat[col * 4 + row] = v[col];
  },
  zero: new Float32Array(16),
};
const gl = WebGL2RenderingContext;

export class MeshPlayerGen {
  // TODO: implement CreateShapeTex

  CreateBoneTex(boneTex) {
    const { skel, layout } = this;
    const flip = vec3.fromValues(1, 1, -1);
    const axesData = Array.from({ length: skel.bones.length }, () =>
      vec4.create()
    );
    const restPose = Array.from(
      { length: skel.bones.length },
      () => Matrix4x4.zero
    );
    for (let b = 0; b < skel.bones.length; b++)
      if (skel.bones[b]) {
        const slot0 = Math.max(
          ...layout.bones[b]
            .map((slot, axis) => (slot < 0 ? null : slot - axis))
            .filter((x) => x !== null)
        );
        const sign = Float32Array.from(skel.axes[b].sign);
        for (let i = 0; i < 3; i++) if (layout.bones[b][i] < 0) sign[i] = 0;
        const p = skel.parents[b];
        if (p < 0)
          vec4.set(
            axesData[b],
            1 / skel.humanScale,
            1 / skel.humanScale,
            1 / skel.humanScale,
            -1 - (slot0 + 3)
          );
        else vec4.set(axesData[b], ...sign, slot0);
        if (p < 0) restPose[b] = mat4.create();
        else if (skel.bones[p] == skel.bones[b]) throw "TODO";
        else {
          const diff = vec3.sub(
            vec3.create(),
            getWorldPosition(skel.bones[b]),
            getWorldPosition(skel.bones[p])
          );
          restPose[b] = Matrix4x4.Rotate(
            Quaternion.Inverse(skel.axes[p].postQ)
          );
          mat4.mul(
            restPose[b],
            restPose[b],
            Matrix4x4.Translate(vec3.mul(diff, diff, flip))
          );
          mat4.mul(
            restPose[b],
            restPose[b],
            Matrix4x4.Rotate(skel.axes[b].preQ)
          );
        }
      }
    const mats = Array.from({ length: skel.bones.length }, () => []);
    for (let b = 0; b < skel.bones.length; b++)
      if (skel.bones[b]) {
        const pos = vec3.mul(
          vec3.create(),
          getWorldPosition(skel.bones[b]),
          flip
        );
        const mat = Matrix4x4.Rotate(Quaternion.Inverse(skel.axes[b].postQ));
        mat4.mul(mat, mat, Matrix4x4.Translate(vec3.scale(pos, pos, -1))); // bindpose
        mat4.mul(mat, mat, mat4.fromScaling(mat4.create(), flip)); // flip vertex attribs
        for (let p = b; p >= 0; p = skel.parents[p]) {
          Matrix4x4.SetRow(mat, 3, axesData[p]);
          mats[b].push(mat4.clone(mat));
          mat4.copy(mat, restPose[p]);
        }
      }

    const width = Math.max(...mats.map((l) => l.length));
    const colors = Float32Array.from(
      mats
        .map((l) =>
          l
            .concat(
              Array.from({ length: width - l.length }, () => Matrix4x4.zero)
            )
            .map((x) => Array.from(x))
        )
        .flat(2)
    );
    Object.assign(boneTex, {
      source$: {
        _data: Promise.resolve(colors),
        extras: {
          type: gl.FLOAT,
          internalformat: gl.RGBA32F,
          width: colors.length / 4 / skel.bones.length,
          height: skel.bones.length,
        },
      },
      sampler$: {
        wrapS: gl.CLAMP_TO_EDGE,
        wrapT: gl.CLAMP_TO_EDGE,
        magFilter: gl.NEAREST,
        minFilter: gl.NEAREST,
      },
    });
  }
  CreatePlayer(mesh, boneTex, sources) {
    const { gltf, skel, layout } = this;
    this.CreateBoneTex(boneTex);
    // console.log("skel.bones", skel.bones);
    for (const source of sources) {
      const skinned = source.skin !== undefined;
      const srcMesh = gltf.meshes[source.mesh];
      const srcBones = skinned
        ? gltf.skins[source.skin].joints.map((i) => gltf.nodes[i])
        : [source];
      const objectToRoot = getWorldPosition(source);
      // console.log("srcBones", skinned, srcMesh, srcBones, objectToRoot);

      const posCache =
        objectToRoot[0] ** 2 + objectToRoot[1] ** 2 + objectToRoot[2] ** 2 >
          1e-6 && new Map();
      const uv0Cache = new Map(),
        uv1Cache = new Map();
      for (const prim of srcMesh.primitives) {
        const { POSITION, NORMAL, TEXCOORD_0, JOINTS_0, WEIGHTS_0 } =
          prim.attributes$;
        const pos = !posCache
          ? POSITION
          : posCache.get(POSITION) ||
            posCache
              .set(POSITION, {
                componentType: gl.FLOAT,
                type: "VEC3",
                count: POSITION.count,
                bufferView$: {
                  target: gl.ARRAY_BUFFER,
                  _data: viewAccessor(POSITION).then((pos0) => {
                    const pos = pos0.slice();
                    for (let i = 0; i < pos.length; i += 3)
                      (pos[i + 0] += objectToRoot[0]),
                        (pos[i + 1] += objectToRoot[1]),
                        (pos[i + 2] += objectToRoot[2]);
                    return pos;
                  }),
                },
              })
              .get(POSITION);
        const uv0 =
          uv0Cache.get(TEXCOORD_0) ||
          uv0Cache
            .set(TEXCOORD_0, {
              componentType: gl.FLOAT,
              type: "VEC4",
              count: POSITION.count,
              bufferView$: {
                target: gl.ARRAY_BUFFER,
                _data: viewAccessor(TEXCOORD_0).then((uv) => {
                  const uv0 = new Float32Array(TEXCOORD_0.count * 4);
                  for (let v = 0; v < TEXCOORD_0.count; v++)
                    (uv0[v * 4 + 0] = uv[v * 2 + 0]),
                      (uv0[v * 4 + 1] = uv[v * 2 + 1]);
                  return uv0;
                }),
              },
            })
            .get(TEXCOORD_0);
        const uv1Key = skinned ? WEIGHTS_0 : POSITION.count;
        const uv1 =
          uv1Cache.get(uv1Key) ||
          uv1Cache
            .set(uv1Key, {
              componentType: gl.FLOAT,
              type: "VEC4",
              count: POSITION.count,
              bufferView$: {
                target: gl.ARRAY_BUFFER,
                _data: Promise.all(
                  skinned
                    ? [viewAccessor(JOINTS_0), viewAccessor(WEIGHTS_0)]
                    : []
                ).then((boneWeights) => {
                  const [
                    boneIndices = new Uint16Array(POSITION.count * 4),
                    weights = new Float32Array(POSITION.count * 4),
                  ] = boneWeights.map((x) => x.slice());
                  if (!skinned)
                    for (let i = 0; i < weights.length; i += 4) weights[i] = 1;
                  RetargetBindposesBoneWeights(srcBones, skel.bones, [
                    boneIndices,
                    weights,
                  ]);
                  const uv1 = weights;
                  for (let i = 0; i < boneIndices.length; i++)
                    uv1[i] = boneIndices[i] + weights[i] / 2;
                  return uv1;
                }),
              },
            })
            .get(uv1Key);
        mesh.primitives.push({
          __proto__: prim,
          attributes$: {
            POSITION: pos,
            NORMAL: NORMAL,
            _TEXCOORD_0: uv0,
            _TEXCOORD_1: uv1,
          },
          material$: {
            __proto__: prim.material$,
            extras: {
              boneTexture: { index$: boneTex },
              shapeTexture: { index$: boneTex },
            },
          },
        });
      }
    }
  }
}
