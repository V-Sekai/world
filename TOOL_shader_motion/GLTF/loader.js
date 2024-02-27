import { fetchImage, fetchArrayBuffer } from "./fetch.js";

export const extenLoaders = {
  KHR_techniques_webgl: loadTechniques,
};
export const imageLoaders = {
  async default(data, img) {
    return fetchImage(
      URL.createObjectURL(new Blob([await data], { type: img.mimeType }))
    );
  },
};
export function loadGLTF(gltf, binary, baseURI) {
  // buffers & bufferViews
  for (const view of gltf.bufferViews || []) {
    const buf = gltf.buffers[view.buffer];
    if (buf._data === undefined)
      // only load used buffer
      buf._data =
        buf.uri === undefined
          ? Promise.resolve(binary)
          : fetchArrayBuffer(new URL(buf.uri, baseURI)).then(
              (b) => new Uint8Array(b)
            ); // byteLength is ignored
    view._data = buf._data.then((s) =>
      s.subarray(view.byteOffset || 0).subarray(0, view.byteLength)
    );
  }
  // images & textures
  for (const tex of gltf.textures || []) {
    const img =
      Object.entries(tex.extensions || {})
        .map(([name, { source }]) => extenLoaders[name] && gltf.images[source])
        .find((x) => x) || gltf.images[tex.source]; // get first supported image
    if (img && img._data === undefined)
      // only load used image
      img._data =
        img.uri !== undefined
          ? fetchImage(new URL(img.uri, baseURI))
          : (img.extras || {}).width !== undefined
          ? gltf.bufferViews[img.bufferView]._data
          : (imageLoaders[img.mimeType] || imageLoaders.default)(
              gltf.bufferViews[img.bufferView]._data,
              img
            );
    Object.assign(tex, {
      source$: img,
      sampler$: gltf.samplers && gltf.samplers[tex.sampler],
    });
  }
  // accessors & meshes
  for (const acc of gltf.accessors || [])
    Object.assign(acc, { bufferView$: gltf.bufferViews[acc.bufferView] });
  for (const mesh of gltf.meshes || [])
    for (const prim of mesh.primitives || [])
      Object.assign(prim, {
        material$: gltf.materials && gltf.materials[prim.material],
        indices$: gltf.accessors && gltf.accessors[prim.indices],
        attributes$: Object.fromEntries(
          Object.entries(prim.attributes).map(([k, v]) => [
            k,
            gltf.accessors[v],
          ])
        ),
      });
  // materials
  (gltf.materials || []).forEach(function resolveMat(x) {
    for (const [key, value] of Object.entries(x))
      if (
        value instanceof Object &&
        !key.startsWith("_") &&
        !key.endsWith("$")
      ) {
        resolveMat(value);
        if (key.endsWith("Texture") && value.index !== undefined)
          value.index$ = gltf.textures[value.index]; // deref texture
      }
  });
  // nodes & scenes
  for (const node of gltf.nodes || [])
    Object.assign(node, {
      children$: (node.children || []).map(
        (i) => ((gltf.nodes[i]._parent = node), gltf.nodes[i])
      ),
    });
  for (const scene of gltf.scenes || [])
    Object.assign(scene, {
      nodes$: (scene.nodes || []).map((i) => gltf.nodes[i]),
    });
  if (gltf.scene !== undefined)
    Object.assign(gltf, { scene$: gltf.scenes[gltf.scene] });
  // extensions
  for (const [name, ext] of Object.entries(gltf.extensions || {}))
    (extenLoaders[name] || ((x) => x))(ext, gltf, baseURI);
  return gltf;
}
export function loadTechniques(ext, gltf, baseURI) {
  // shaders & programs
  for (const prog of ext.programs || [])
    for (const name of ["vertexShader", "fragmentShader"]) {
      const shader = ext.shaders[prog[name]];
      if (shader._data === undefined)
        // only load used shader
        shader._data = (
          shader.uri === undefined
            ? gltf.bufferViews[shader.bufferView]._data
            : fetchArrayBuffer(new URL(shader.uri, baseURI))
        ).then((b) => new TextDecoder().decode(b));
      Object.assign(prog, { [name + "$"]: shader });
    }
  // techniques
  for (const tech of ext.techniques || [])
    Object.assign(tech, { program$: ext.programs[tech.program] });
  return ext;
}
