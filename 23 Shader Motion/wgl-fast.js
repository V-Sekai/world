export function GLContext(gl) {
  return Object.assign(gl, GLContext.prototype);
}
const contextMap = new WeakMap();
function contextGet(gl) {
  return (
    contextMap.get(gl) ||
    contextMap.set(gl, { __proto__: Object.getPrototypeOf(gl) }).get(gl)
  );
}
// optimize getAttribLocation, getUniformLocation
Object.assign(GLContext.prototype, {
  linkProgram(prog) {
    const PROG = contextGet(prog);
    Object.assign(PROG, {
      getAttribLocation: undefined,
      getUniformLocation: undefined,
    });
    return contextGet(this).linkProgram.call(this, prog);
  },
  ...Object.fromEntries(
    ["getAttribLocation", "getUniformLocation"].map((method) => [
      method,
      function (prog, name) {
        const PROG = contextGet(prog);
        const dict = PROG[method] || (PROG[method] = Object.create(null));
        const loc = dict[name];
        return loc !== undefined
          ? loc
          : (dict[name] = contextGet(this)[method].call(this, prog, name));
      },
    ])
  ),
});
// optimize texImage2D by texSubImage2D
Object.assign(GLContext.prototype, {
  bindTexture(target, value) {
    const GL = contextGet(this);
    GL.lastTexture = value;
    return GL.bindTexture.call(this, target, value);
  },
  texImage2D(target, level, internalformat, ...args) {
    const lastArg = args[args.length - 1];
    const [width, height, border, format, type, source] =
      args.length > 3
        ? args
        : [
            lastArg.naturalWidth || lastArg.videoWidth || lastArg.width,
            lastArg.naturalHeight || lastArg.videoHeight || lastArg.height,
            0,
            ...args,
          ];

    const GL = contextGet(this),
      TEX = contextGet(GL.lastTexture);
    let dirty =
      TEX.source !== source || TEX.width !== width || TEX.height !== height;
    if (dirty) {
      [TEX.source, TEX.width, TEX.height] = [source, width, height];
      if (source && source.srcObject) TEX.cooldown = performance.now() + 100; // chrome: image isn't available when stream starts
    }
    if (performance.now() > TEX.cooldown)
      (TEX.cooldown = undefined), (dirty = true);

    if (TEX.cooldown === undefined)
      return dirty
        ? GL.texImage2D.call(this, target, level, internalformat, ...args)
        : GL.texSubImage2D.call(
            this,
            target,
            level,
            0 /*xoffset*/,
            0 /*yoffset*/,
            ...(args.length == 3 ? args : [width, height, format, type, source])
          );
  },
});
