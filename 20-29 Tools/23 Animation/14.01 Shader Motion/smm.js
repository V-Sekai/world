import Shader_MeshPlayer from "../shader/MeshPlayer.js";
import Shader_VideoDecoder from "../shader/VideoDecoder.js";
import * as GLTF from "../GLTF/index.js";
import * as wGLTF from "../wGLTF/index.js";

export function createSMMContext(gl) {
  const techniques = createTechniques(gl);
  const textures = createTextures(gl);
  const decoder = {
    technique: techniques.VideoDecoder,
    uniforms: {
      _MainTex_ST: [1, 1, 0, 0],
      _MainTex: { index$: textures.motion },
    },
  };
  return {
    techniques: techniques,
    textures: textures,
    uniforms: {
      motionST: decoder.uniforms._MainTex_ST,
    },
    renderDecoder(gl) {
      textures.motionDec.needsUpdate = true;
      gl.bindFramebuffer(gl.FRAMEBUFFER, textures.motionDec.framebuffer);
      gl.viewport(0, 0, 40, 45);
      gl.clearColor(0, 0, 0, 0);
      gl.clear(gl.COLOR_BUFFER_BIT);
      gl.disable(gl.BLEND);
      gl.disable(gl.DEPTH_TEST);
      gl.disable(gl.CULL_FACE);
      if (wGLTF.useProgram(gl, decoder.technique.program$)) {
        wGLTF.bindUniforms(gl, decoder.uniforms, decoder.technique);
        gl.bindVertexArray(null); // safari: avoid drawArrays generating INVALID_OPERATION
        gl.drawArrays(gl.TRIANGLES, 0, 6);
      }
    },
  };
}
function createTechniques(gl) {
  const gltf = GLTF.loadGLTF(
    {
      buffers: [{}],
      bufferViews: [{ buffer: 0 }],
      images: [
        {
          bufferView: 0,
          extras: {
            type: gl.UNSIGNED_BYTE,
            internalformat: gl.RGBA,
            width: 1,
            height: 1,
          },
        },
      ],
      samplers: [
        {
          wrapS: gl.CLAMP_TO_EDGE,
          wrapT: gl.CLAMP_TO_EDGE,
          magFilter: gl.NEAREST,
          minFilter: gl.NEAREST,
        },
      ],
      textures: [{ source: 0, sampler: 0 }],
    },
    Uint8Array.of(255, 255, 255, 255)
  );

  const techMeshPlayer = {
    attributes: {
      in_POSITION0: { semantic: "POSITION" },
      in_NORMAL0: { semantic: "NORMAL" },
      in_TEXCOORD0: { semantic: "_TEXCOORD_0" },
      in_TEXCOORD1: { semantic: "_TEXCOORD_1" },
    },
    uniforms: {
      unity_ObjectToWorld: { type: gl.FLOAT_MAT4, semantic: "MODEL" },
      unity_MatrixVP: { type: gl.FLOAT_MAT4, semantic: "VIEWPROJECTION" },

      _RotationTolerance: { type: gl.FLOAT, value: 0.1 },
      _HumanScale: { type: gl.FLOAT, value: -1 },
      _Layer: { type: gl.FLOAT, value: 0 },

      _MotionDec: { type: gl.SAMPLER_2D },
      _Bone: { type: gl.SAMPLER_2D },
      _Shape: { type: gl.SAMPLER_2D },
      _MainTex: { type: gl.SAMPLER_2D, value: { index$: gltf.textures[0] } },
      _MainTex_ST: { type: gl.FLOAT_VEC4, value: [1, 1, 0, 0] },
      _Color: { type: gl.FLOAT_VEC4, value: [1, 1, 1, 1] },
    },
  };
  const ext = GLTF.loadTechniques({
    shaders: [
      { type: gl.VERTEX_SHADER, _data: Promise.resolve(Shader_MeshPlayer.vs) },
      {
        type: gl.FRAGMENT_SHADER,
        _data: Promise.resolve(Shader_MeshPlayer.fs),
      },
      {
        type: gl.FRAGMENT_SHADER,
        _data: Promise.resolve(Shader_MeshPlayer.fs.replace(/\bdiscard;/, ";")),
      },
      {
        type: gl.VERTEX_SHADER,
        _data: Promise.resolve(Shader_VideoDecoder.vs),
      },
      {
        type: gl.FRAGMENT_SHADER,
        _data: Promise.resolve(Shader_VideoDecoder.fs),
      },
    ],
    programs: [
      { vertexShader: 0, fragmentShader: 2 },
      { vertexShader: 0, fragmentShader: 1 },
      { vertexShader: 3, fragmentShader: 4 },
    ],
    techniques: [
      { program: 0, ...techMeshPlayer },
      {
        program: 1,
        ...techMeshPlayer,
        uniforms: {
          ...techMeshPlayer.uniforms,
          _Cutoff: { type: gl.FLOAT, value: 0, semantic: "ALPHACUTOFF" },
        },
      },
      {
        program: 2,
        uniforms: {
          _MainTex: { type: gl.SAMPLER_2D },
          _MainTex_ST: { type: gl.FLOAT_VEC4, value: [1, 1, 0, 0] },
        },
      },
    ],
  });
  ext.programs.forEach((prog) => wGLTF.loadProgram(gl, prog)); // preload shader programs
  return {
    MeshPlayer: ext.techniques[0],
    MeshPlayerAlphaTest: ext.techniques[1],
    VideoDecoder: ext.techniques[2],
  };
  // [shaders.MeshPlayer, glob.shaders.MeshPlayerAlphaTest].map(prog => {
  // 	gl.bindAttribLocation(prog, 0, "in_POSITION0");
  // 	gl.bindAttribLocation(prog, 1, "in_NORMAL0");
  // 	gl.bindAttribLocation(prog, 2, "in_TEXCOORD0");
  // 	gl.bindAttribLocation(prog, 3, "in_TEXCOORD1");
  // });
}

function createTextures(gl) {
  const bufferRGBA = new Uint8Array(40 * 45 * 4);
  const bufferFloat = new Float32Array(40 * 45);
  const gltf = GLTF.loadGLTF(
    {
      buffers: [{}],
      bufferViews: [{ buffer: 0 }],
      images: [
        {
          uri: "motion/default.png",
          extras: { internalformat: gl.RGBA, flipY: true },
        }, // firefox doesn't support sRGB video texture
        {
          bufferView: 0,
          extras: {
            type: gl.UNSIGNED_BYTE,
            internalformat: gl.RGBA,
            width: 40,
            height: 45,
          },
        },
      ],
      samplers: [
        {
          wrapS: gl.CLAMP_TO_EDGE,
          wrapT: gl.CLAMP_TO_EDGE,
          magFilter: gl.LINEAR,
          minFilter: gl.LINEAR,
        },
        {
          wrapS: gl.CLAMP_TO_EDGE,
          wrapT: gl.CLAMP_TO_EDGE,
          magFilter: gl.NEAREST,
          minFilter: gl.NEAREST,
        },
      ],
      textures: [
        { source: 0, sampler: 0 },
        { source: 1, sampler: 1 },
      ],
    },
    bufferRGBA,
    location.href
  );
  const motion = gltf.textures[0];
  const motionDec = gltf.textures[1];
  const framebuffer = gl.createFramebuffer();
  gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
  gl.framebufferTexture2D(
    gl.FRAMEBUFFER,
    gl.COLOR_ATTACHMENT0,
    gl.TEXTURE_2D,
    wGLTF.loadTexture(gl, motionDec),
    0
  );
  return {
    motion: motion,
    motionDec: Object.assign(motionDec, {
      needsUpdate: false,
      framebuffer: framebuffer,
      readPixels() {
        if (this.needsUpdate) {
          this.needsUpdate = false;
          gl.bindFramebuffer(gl.READ_FRAMEBUFFER, framebuffer);
          gl.readPixels(0, 0, 40, 45, gl.RGBA, gl.UNSIGNED_BYTE, bufferRGBA);
          for (let i = 0; i < 40 * 45; i++)
            bufferFloat[i] =
              (((bufferRGBA[i * 4 + 3] / 0x100 + bufferRGBA[i * 4 + 2]) /
                0x100 +
                bufferRGBA[i * 4 + 1]) /
                0x100 +
                bufferRGBA[i * 4]) /
                0x40 -
              1;
        }
        return bufferFloat;
      },
    }),
  };
}
