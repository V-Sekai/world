import { gl, logGL, nameGL, TypedArray } from "./common.js";

const _TEXTURE = Symbol("GLTexture");
const defaults = {
  magFilter: gl.LINEAR, // firefox: disable mipmap since generateMipmap is slow
  minFilter: navigator.userAgent.match(/Gecko\//)
    ? gl.LINEAR
    : gl.LINEAR_MIPMAP_LINEAR,
  internalformat: gl.SRGB8_ALPHA8, // use linear workflow
};
const format32Fto16F = Object.fromEntries(
  Object.keys(gl)
    .filter((k) => /32F$/.test(k))
    .map((k) => [gl[k], gl[k.replace("32F", "16F")]])
);

// texture: gltf.texture & {_data: Thenable<ArrayBufferView|Element> | WebGLRenderingContext => Thenable<ArrayBufferView>}
export function loadTexture(gl, texture, def = defaults) {
  if (texture.hasOwnProperty(_TEXTURE)) return texture[_TEXTURE];
  const {
    wrapS = gl.REPEAT,
    wrapT = gl.REPEAT,
    magFilter = def.magFilter,
    minFilter = def.minFilter,
  } = texture.sampler$ || {};
  const { extras: { target = gl.TEXTURE_2D } = {}, _data } =
    texture.source$ || {};
  const tex = gl.createTexture();
  gl.bindTexture(target, tex);
  gl.texParameteri(target, gl.TEXTURE_WRAP_S, wrapS);
  gl.texParameteri(target, gl.TEXTURE_WRAP_T, wrapT);
  gl.texParameteri(target, gl.TEXTURE_MAG_FILTER, magFilter);
  gl.texParameteri(target, gl.TEXTURE_MIN_FILTER, minFilter);
  if (_data)
    (_data instanceof Function ? _data(gl) : _data).then((data) => {
      const {
        extras: {
          internalformat = def.internalformat,
          width,
          height,
          format = gl.RGBA,
          type = gl.UNSIGNED_BYTE,
          flipY = false,
          compressed = false,
        } = {},
      } = texture.source$;
      // downgrade float to half when OES_texture_float_linear is needed but unavailable
      const internalfmt =
        (type === gl.FLOAT &&
          magFilter != gl.NEAREST &&
          !gl.getExtension("OES_texture_float_linear") &&
          format32Fto16F[internalformat]) ||
        internalformat;
      // retype arrayBufferView required by texImage2D
      if (data.byteOffset !== undefined && !compressed)
        data = new TypedArray[type](
          data.buffer,
          data.byteOffset,
          data.byteLength / TypedArray[type].BYTES_PER_ELEMENT
        );

      logGL(
        gl,
        "[compressed]texImage2D",
        nameGL[target],
        0,
        nameGL[internalfmt] || internalfmt,
        width,
        height,
        0,
        nameGL[format],
        nameGL[type],
        data
      );
      gl.bindTexture(target, tex);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, flipY);
      if (compressed)
        gl.compressedTexImage2D(target, 0, internalfmt, width, height, 0, data);
      else
        gl.texImage2D(
          target,
          0,
          internalfmt,
          ...(width >= 0 ? [width, height, 0] : []),
          format,
          type,
          data
        );
      if (
        minFilter >= gl.NEAREST_MIPMAP_NEAREST &&
        minFilter <= gl.LINEAR_MIPMAP_LINEAR
      )
        gl.generateMipmap(target);
    });
  return (texture[_TEXTURE] = tex);
}
