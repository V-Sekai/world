export async function fetchArrayBuffer(
  url,
  opts = { mode: "cors", referrerPolicy: "no-referrer" }
) {
  const response = await fetch(url, opts);
  if (!response.ok)
    throw new Error(`could not fetch: ${url}, status = ${response.statusText}`);
  return response.arrayBuffer();
}
export async function fetchImage(
  url,
  opts = { mode: "cors", referrerPolicy: "no-referrer" }
) {
  const img = new Image();
  img.crossOrigin = opts.mode === "cors" ? "anonymous" : null;
  img.referrerPolicy = opts.referrerPolicy;
  img.src = url;
  await img.decode();
  return img;
}
export async function fetchGLTF(url, ...args) {
  return parseGLTF(await fetchArrayBuffer(url, ...args));
}
// parse GLTF or GLB
export function parseGLTF(arrayBuffer) {
  let chunk0, chunk1;
  if (arrayBuffer.byteLength >= 20) {
    const [magic, version, length, chunkLength, chunkType] = new Uint32Array(
      arrayBuffer,
      0,
      5
    );
    if (magic === 0x46546c67 /*GLTF*/ && chunkType === 0x4e4f534a /*JSON*/) {
      chunk0 = new Uint8Array(arrayBuffer, 20, chunkLength);
      if (28 + chunkLength <= length)
        chunk1 = new Uint8Array(
          arrayBuffer,
          28 + chunkLength,
          length - (28 + chunkLength)
        );
    }
  }
  return [JSON.parse(new TextDecoder().decode(chunk0 || arrayBuffer)), chunk1];
}
