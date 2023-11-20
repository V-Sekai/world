import { Skeleton } from "./Skeleton.js";
import { MotionLayout } from "./MotionLayout.js";
import { MeshPlayerGen } from "./MeshPlayerGen.js";

export function CreatePlayer(gltf) {
  const skel = new Skeleton(gltf);
  const layout = new MotionLayout(skel);
  const sources = gltf.nodes
    // .filter(node => node.mesh !== undefined && gltf.meshes[node.mesh].name.match(/Body[.]/))
    .filter((node) => node.mesh !== undefined);
  const mesh = { primitives: [] };
  const boneTex = {};
  const gen = Object.assign(new MeshPlayerGen(), {
    gltf: gltf,
    skel: skel,
    layout: layout,
  });
  gen.CreatePlayer(mesh, boneTex, sources);
  return mesh;
}
