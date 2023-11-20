import { mat4 } from "./gl-matrix.js";
import { GLContext } from "./wgl-fast.js";

import * as GLTF from "./GLTF/index.js";
import * as wGLTF from "./wGLTF/index.js";
import { CreatePlayer } from "./SM/MeshPlayer.js";
import { AnimRecorder } from "./SM/AnimRecorder.js";
import { MotionDecoder } from "./SM/MotionDecoder.js";
import { MotionLayout } from "./SM/MotionLayout.js";
import { HumanPose } from "./SM/HumanPoser.js";

import { createSMMContext } from "./smm.js";
import { OrbitControls } from "./OrbitControls.js";
import { FPSCounter, resizeCanvas, downloadFile } from "./util.js";
import {
  getCaptureClientRect,
  getDisplaySurface,
} from "./ScreenCapture.js";

let getCaptureRect;
let motionDec;
const avatars = {};
const $video = document.querySelector("#video");
const $canvas = document.querySelector("#canvas");
const $embed = document.querySelector("#embed");
const $overlay = document.querySelector("#overlay");
const $source = document.querySelector("#source");
{
  let sourceStream;
  const $sourceFile = document.querySelector("#sourceFile");
  const $sourceUrl = document.querySelector("#sourceUrl");
  $source.onclick = function () {
    this.dataset.value = this.value;
  };
  $source.onchange = function () {
    if (this.value === "file:") {
      this.value = this.dataset.value;
      return openFiles($sourceFile, (files) => {
        for (const file of files)
          this.value = addOption(this, URL.createObjectURL(file), file.name);
        this.onchange();
      });
    }
    if (this.value === "url:") {
      this.value = this.dataset.value;
      $source.hidden = true;
      $sourceUrl.hidden = false;
      $sourceUrl.focus();
      $sourceUrl.select();
      return;
    }
    if (this.value === "cap:") {
      this.value = this.dataset.value;
      captureScreen().then(
        () => (this.value = "cap:"),
        (e) => alert(e)
      );
      return;
    }
    if (this.value.startsWith("embed:")) {
      const value = this.value;
      this.value = this.dataset.value;
      $embed.src = value.slice(6);
      return captureEmbed().then(
        () => (this.value = value),
        (e) => alert(e)
      );
    }
    setStream(null);
    $embed.src = "";
    $embed.hidden = true;
    $video.hidden = false;
    $video.srcObject = sourceStream;
    $video.src = this.value;
    $video.muted = false;
  };
  $sourceUrl.form.onsubmit = function (event) {
    if (event) event.preventDefault();
    $sourceUrl.hidden = true;
    $source.hidden = false;
    const url = $sourceUrl.value;
    if (url) {
      const { name, embed_url, raw_url } = resolveURL(url);
      if (embed_url !== undefined) {
        $embed.src = embed_url; // preload
        return captureEmbed().then(
          () => {
            $source.value = addOption($source, `embed:${embed_url}`, name);
            $source.onchange();
          },
          (e) => alert(e)
        );
      } else {
        $source.value = addOption($source, raw_url, name);
        $source.onchange();
      }
    }
  };
  window.onhashchange = function (event) {
    const url = location.hash.replace(/^#/, "");
    if (/(^https?:)|(^\w\/)/.test(url)) {
      $overlay.innerText = "Click here to play";
      $overlay.hidden = false;
      $overlay.addEventListener(
        "pointerdown",
        (event) => {
          $overlay.hidden = true;
          $sourceUrl.value = url;
          $sourceUrl.form.onsubmit();
        },
        { once: true }
      );
    }
  };
  window.onhashchange();
  async function captureScreen() {
    $overlay.innerText = "You will see a popup asking you to share screen";
    $overlay.hidden = false;

    const constraints = {
      audio: false,
      video: {
        cursor: "false",
        displaySurface: { ideal: "window" },
        frameRate: { ideal: 60 },
        height: { max: 480 }, // restrict for performance
      },
    };
    try {
      if (!navigator.mediaDevices)
        throw new Error(`screen capture not available`);
      setStream(await navigator.mediaDevices.getDisplayMedia(constraints));
    } finally {
      $overlay.hidden = true;
    }

    $video.srcObject = sourceStream;
    $video.hidden = false;
    $embed.hidden = true;
  }
  async function captureEmbed() {
    if ($embed.hidden || !sourceStream.active) {
      const title = document.title;
      document.title = "👉 SELECT ME TO SHARE 👈";
      $overlay.innerText =
        "You will see a popup asking you to share screen\nPlease share this browser tab or application window instead";
      $overlay.hidden = false;

      const constraints = {
        audio: false,
        video: {
          cursor: "false",
          displaySurface: { ideal: "browser" },
          frameRate: { ideal: 60 },
          height: { max: 480 }, // restrict for performance
        },
      };
      try {
        if (!navigator.mediaDevices)
          throw new Error(`screen capture not available`);
        setStream(await navigator.mediaDevices.getDisplayMedia(constraints));
      } finally {
        document.title = title;
        $overlay.hidden = true;
      }

      const displaySurface = getDisplaySurface(sourceStream.getTracks()[0]);
      if (!(getCaptureRect = getCaptureClientRect[displaySurface]))
        throw new Error(`displaySurface "${displaySurface}" not supported`);

      $video.srcObject = sourceStream;
      $video.hidden = true;
      $embed.hidden = false;
    }
    const footer = document.querySelector("footer");
    $overlay.innerText = "Click page bottom to play";
    $overlay.hidden = false;
    $overlay.onpointermove = function (event) {
      const box = footer.getBoundingClientRect();
      if (
        box.left <= event.clientX &&
        event.clientX <= box.right &&
        box.top <= event.clientY &&
        event.clientY <= box.bottom
      ) {
        $overlay.hidden = true;
        $overlay.onpointermove = null;
      }
    };
  }
  function setStream(stream) {
    if (sourceStream) sourceStream.getTracks().forEach((track) => track.stop());
    sourceStream = stream;
  }
  function embedURL(url) {
    return `video.html?${performance.now() >> 0}#${url}`;
  }
  function resolveURL(url) {
    let m;
    if ((m = url.match(/^(\w\/[A-Za-z0-9_\/.\-]+)/)))
      return { name: `${m[1]}`, raw_url: `//vsk.lox9973.com/${m[1]}.mp4` };
    if (
      (m = url.match(
        /(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=))([A-Za-z0-9_\-]+)/
      ))
    )
      return {
        name: `youtube:${m[1]}`,
        embed_url: `https://www.youtube.com/embed/${m[1]}`,
      };
    if ((m = url.match(/twitch\.tv\/([A-Za-z0-9_\-]+)/)))
      return {
        name: `twitch:${m[1]}`,
        embed_url: `https://player.twitch.tv/?channel=${m[1]}&autoplay=false&parent=${location.hostname}`,
      };
    if ((m = url.match(/drive\.google\.com\/file\/d\/([A-Za-z0-9_\-]+)/)))
      return {
        name: `googledrive:${m[1]}`,
        embed_url: embedURL(`https://drive.google.com/uc?id=${m[1]}`),
      };
    return { name: url.split("/").pop(), embed_url: embedURL(url) };
  }
}
const $record = document.querySelector("#record");
const $recordTime = document.querySelector("#recordingTime");
{
  const $export = document.querySelector("#export");
  const $debug = document.querySelector("#debug");
  $record.onchange = function () {
    if (this.checked)
      for (const avatar of Object.values(avatars)) {
        avatar.humanPose = new HumanPose();
        avatar.animRecorder = new AnimRecorder(() => {
          avatar.motionDecoder.Update(
            {
              width: 40,
              height: 45,
              getData: motionDec.readPixels.bind(motionDec),
            },
            avatar.layer
          );
          avatar.humanPose.SetBoneSwingTwists(avatar.motionDecoder.motions);
          avatar.humanPose.SetHipsPositionRotation(
            ...avatar.motionDecoder.motions[0]
          );
          return {
            muscles: avatar.humanPose.muscles,
            rootT: avatar.humanPose.bodyPosition,
            rootQ: avatar.humanPose.bodyRotation,
          };
        });
      }
    else
      for (const avatar of Object.values(avatars)) {
        const url = URL.createObjectURL(avatar.animRecorder.SaveToClip());
        downloadFile(url, `mocap${avatar.layer}.anim`);
        setTimeout(() => URL.revokeObjectURL(url), 5000);
      }
  };
}
let updateAvatars;
const $avatars = Array.from({ length: 2 }, (_, i) =>
  document.querySelector(`#avatar${i}`)
);
{
  const $avatarFile = document.querySelector("#avatarFile");
  $avatars.forEach(($avatar) => {
    $avatar.onclick = function () {
      this.dataset.value = this.value;
    };
    $avatar.onchange = function () {
      if (this.value === "file:") {
        this.value = this.dataset.value;
        return openFiles($avatarFile, (files) => {
          for (const file of files) this.value = addAvatarOption(file);
          this.onchange();
        });
      }
      updateAvatars();
    };
  });
  $canvas.ondragover = function (event) {
    event.preventDefault();
  };
  $canvas.ondrop = function (event) {
    event.preventDefault();
    const file = event.dataTransfer.files[0];
    if (!file) return;
    if (file.name.endsWith(".vrm")) {
      for (const $avatar of $avatars)
        if ($avatar.value) {
          $avatar.value = addAvatarOption(file);
          $avatar.onchange();
          break;
        }
    } else if (file.name.endsWith(".mp4")) {
      $source.value = addOption($source, URL.createObjectURL(file), file.name);
      $source.onchange();
    }
  };
  function addAvatarOption(file) {
    const url = URL.createObjectURL(file);
    for (const $select of $avatars) addOption($select, url, file.name);
    return url;
  }
}
// camera
const camera = {
  znear: 0.1,
  zfar: 100,
  yfov: (45 / 180) * Math.PI, // in radians
  targetPos: [0, -1, 0],
};
const controls = new OrbitControls(camera, $canvas);
controls.keyReset = "Escape";

main();
function main() {
  const _gl = $canvas.getContext("webgl2", {
    failIfMajorPerformanceCaveat: true, // disable software rendering because it's 2fps
    premultipliedAlpha: true,
    antialias: !/Mobi/.test(navigator.userAgent), // disable MSAA on mobile
  });
  if (!_gl) {
    alert(
      "Unable to initialize WebGL. Your browser or machine may not support it."
    );
    return;
  }
  const gl = GLContext(_gl);

  const glob = createSMMContext(gl);
  motionDec = glob.textures.motionDec;
  Object.assign(glob.uniforms, {
    matrixVP: mat4.create(),
  });

  {
    const models = new Map();
    updateAvatars = function () {
      for (const [i, $avatar] of $avatars.entries()) {
        let avatar = avatars[i];
        if ((avatar ? avatar.src : "") === $avatar.value) continue;

        if (!$avatar.value) {
          console.log(`delete avatar[${i}]`);
          delete avatars[i];
          continue;
        }
        if (!avatar) {
          console.log(`create avatar[${i}]`);
          avatars[i] = avatar = {
            layer: i,
            motionDecoder: new MotionDecoder(new MotionLayout()),
          };
        }

        avatar.src = $avatar.value;
        if (!models.has($avatar.value))
          models.set($avatar.value, loadModel(gl, $avatar.value, glob));
        models.get($avatar.value).then((model) => {
          console.log(`load avatar[${i}]: ${avatar.src}`);
          avatar.draws = model.draws.map((draw) => ({
            __proto__: draw,
            uniforms: { __proto__: draw.uniforms, _Layer: avatar.layer },
          }));
        });
      }
    };
    updateAvatars();
  }

  const $fps = document.querySelector("#fps");
  const $videoRegion = document.querySelector("#videoRegion");
  let lastTimeStamp = 0;
  const fpsCounter = new FPSCounter();
  requestAnimationFrame(drawFrame);
  function drawFrame(timeStamp) {
    // frame time
    $fps.textContent = Math.round(fpsCounter.update(timeStamp));
    glob.uniforms.time = timeStamp * 1e-3;
    glob.uniforms.deltaTime = (timeStamp - lastTimeStamp) * 1e-3;
    lastTimeStamp = timeStamp;

    const motionST = glob.uniforms.motionST;
    if (!$embed.hidden) {
      const box = $videoRegion.getBoundingClientRect();
      const cap = getCaptureRect(window);
      motionST[0] = box.width / cap.width;
      motionST[1] = box.height / cap.height;
      motionST[2] = (box.x - cap.x) / cap.width;
      motionST[3] = (box.y - cap.y) / cap.height;
      motionST[3] = 1 - motionST[3] - motionST[1]; // flipY
    } else {
      motionST[0] = 1;
      motionST[1] = 1;
      motionST[2] = 0;
      motionST[3] = 0;
    }

    // motion video
    if ($video.readyState >= $video.HAVE_CURRENT_DATA && $video.videoWidth) {
      gl.bindTexture(
        gl.TEXTURE_2D,
        wGLTF.loadTexture(gl, glob.textures.motion)
      );
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
      gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        $video
      );
    }
    glob.renderDecoder(gl);

    // camera
    const aspect = gl.canvas.clientWidth / gl.canvas.clientHeight;
    mat4.perspective(
      glob.uniforms.matrixVP,
      camera.yfov,
      aspect,
      camera.znear,
      camera.zfar
    );
    controls.multiplyMatrixV(glob.uniforms.matrixVP);
    mat4.translate(
      glob.uniforms.matrixVP,
      glob.uniforms.matrixVP,
      camera.targetPos
    );
    mat4.scale(glob.uniforms.matrixVP, glob.uniforms.matrixVP, [-1, 1, 1]);

    resizeCanvas(gl);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
    gl.clearColor(0, 0, 0, 0), gl.clearDepth(1 /*FAR*/);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // avatars
    const draws = Object.values(avatars)
      .flatMap((avatar) => avatar.draws || [])
      .sort((x, y) => x.renderOrder - y.renderOrder);
    for (const draw of draws)
      if (wGLTF.useProgram(gl, draw.technique.program$)) {
        gl.frontFace(draw.mirror ? gl.CW : gl.CCW);
        wGLTF.setStates(gl, draw.material);
        wGLTF.bindUniforms(gl, draw.uniforms, draw.technique);
        wGLTF.bindAttributes(gl, draw.primitive.attributes$, draw.technique);
        wGLTF.drawPrimitive(gl, draw.primitive);
      }

    if ($record.checked)
      for (const avatar of Object.values(avatars))
        if (avatar.animRecorder.currentTime < 60) {
          avatar.animRecorder.TakeSnapshot(glob.uniforms.deltaTime);
          $recordTime.textContent = `${avatar.animRecorder.currentTime.toFixed(
            0
          )}s`;
        }
    requestAnimationFrame(drawFrame);
  }
}
async function loadModel(gl, modelURL, glob) {
  const url = new URL(modelURL, location.href);
  const gltf = GLTF.loadGLTF(...(await GLTF.fetchGLTF(url)), url);
  // console.debug("GLTF", gltf);

  const vrm = (gltf.extensions || {}).VRM;
  const mesh = vrm ? CreatePlayer(gltf) : gltf.meshes[0];

  const renderOrderMap = { OPAQUE: 2000, MASK: 2450, BLEND: 3000 };
  const matrixM = mat4.create();

  const draws = mesh.primitives.map((prim, i) => {
    const {
      alphaMode = "OPAQUE",
      alphaCutoff = 0.5,
      pbrMetallicRoughness: {
        baseColorTexture: mainTexInfo,
        baseColorFactor: mainColor = [1, 1, 1, 1],
      },
      extras: { boneTexture: boneTexInfo, shapeTexture: shapeTexInfo },
    } = prim.material$;
    const {
      renderQueue: renderOrder = renderOrderMap[alphaMode],
      floatProperties: { _ZWrite: depthWrite } = {},
    } = (vrm && vrm.materialProperties[prim.material]) || {};
    const tech =
      glob.techniques[
        alphaMode === "MASK" || depthWrite
          ? "MeshPlayerAlphaTest"
          : "MeshPlayer"
      ];
    return {
      renderOrder: renderOrder,
      mirror: !vrm,
      primitive: prim,
      technique: tech,
      material: {
        __proto__: prim.material$,
        depthWrite: depthWrite,
      },
      uniforms: {
        MODEL: matrixM,
        VIEWPROJECTION: glob.uniforms.matrixVP,
        ALPHACUTOFF: alphaCutoff,
        _Color: mainColor,
        _MainTex: mainTexInfo,
        _Bone: boneTexInfo,
        _Shape: shapeTexInfo,
        _MotionDec: { index$: glob.textures.motionDec },
      },
    };
  });
  return { draws: draws };
}
function openFiles($file, callback) {
  $file.onchange = () => $file.files.length && callback($file.files);
  return $file.click();
}
function addOption($select, value, text) {
  const $option = document.createElement("option");
  ($option.value = value), ($option.text = text);
  $select.add($option);
  return value;
}
