import { vec3 } from "../gl-matrix.js";

// todo: rotation/scale
export function getWorldPosition(node) {
  if (node._position !== undefined) return node._position;
  node._position = vec3.fromValues(...(node.translation || [0, 0, 0]));
  if (node._parent)
    vec3.add(node._position, getWorldPosition(node._parent), node._position);
  return node._position;
}
