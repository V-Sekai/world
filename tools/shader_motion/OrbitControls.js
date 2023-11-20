import { mat4 } from "../gl-matrix.js";
export class OrbitControls {
  reset() {
    this.rotationXY = [0, 0];
    this.translation = [0, 0, -3];
  }
  multiplyMatrixV(out) {
    mat4.translate(out, out, this.translation);
    mat4.rotateX(out, out, this.rotationXY[0]);
    mat4.rotateY(out, out, this.rotationXY[1]);
  }
  constructor(camera, canvas) {
    this.enabled = true;
    this.buttonOrbit = 0;
    this.buttonPan = 1;
    this.reset();

    const scope = this;
    function handleOrbit(movementX, movementY) {
      const scale = (Math.PI * 2) / canvas.clientWidth;
      scope.rotationXY[1] += movementX * scale;
      scope.rotationXY[0] += movementY * scale;
      scope.rotationXY[0] = Math.min(
        Math.max(scope.rotationXY[0], -Math.PI / 2),
        +Math.PI / 2
      );
    }
    function handlePanZoom(movementX, movementY, scale = 1, clientX, clientY) {
      const offsetX =
        clientX === undefined
          ? 0
          : clientX - (canvas.clientLeft + canvas.clientWidth / 2);
      const offsetY =
        clientY === undefined
          ? 0
          : clientY - (canvas.clientTop + canvas.clientHeight / 2);
      const clientDist = canvas.clientHeight / 2 / Math.tan(camera.yfov / 2);
      scope.translation[2] /= scale;
      scope.translation[0] -=
        (scope.translation[2] / clientDist) *
        (movementX - offsetX * (scale - 1));
      scope.translation[1] +=
        (scope.translation[2] / clientDist) *
        (movementY - offsetY * (scale - 1));
    }

    function onDblClick(event) {
      if (!scope.enabled) return;
      event.preventDefault(), scope.reset();
    }
    function onContextMenu(event) {
      if (!scope.enabled) return;
      event.preventDefault();
    }
    function onPointerDown(event) {
      if (
        !scope.enabled ||
        (event.pointerType !== "mouse" && event.pointerType !== "pen")
      )
        return;
      event.preventDefault();
      canvas.ownerDocument.addEventListener("pointermove", onPointerMove);
      canvas.ownerDocument.addEventListener("pointerup", onPointerUp);
    }
    function onPointerUp(event) {
      if (
        !scope.enabled ||
        (event.pointerType !== "mouse" && event.pointerType !== "pen")
      )
        return;
      canvas.ownerDocument.removeEventListener("pointermove", onPointerMove);
      canvas.ownerDocument.removeEventListener("pointerup", onPointerUp);
    }
    function onPointerMove(event) {
      if (
        !scope.enabled ||
        (event.pointerType !== "mouse" && event.pointerType !== "pen")
      )
        return;
      event.preventDefault();
      if (
        scope.buttonOrbit !== undefined &&
        event.buttons & (1 << scope.buttonOrbit)
      )
        handleOrbit(event.movementX, event.movementY);
      if (
        scope.buttonPan !== undefined &&
        event.buttons & (1 << scope.buttonPan)
      )
        handlePanZoom(event.movementX, event.movementY);
    }
    function onWheel(event) {
      if (!scope.enabled) return;
      event.preventDefault();
      event.stopPropagation();
      handlePanZoom(0, 0, 1.2 ** Math.sign(-event.deltaY)); // don't apply zoom offset
    }
    let touch;
    function onTouchStart(event) {
      if (!scope.enabled) return;
      event.preventDefault();
      touch = getAverageTouch(event.touches);
    }
    function onTouchMove(event) {
      if (!scope.enabled) return;
      event.preventDefault();
      event.stopPropagation();
      const touch0 = touch;
      touch = getAverageTouch(event.touches);
      if (touch.length !== touch0.length) return;
      const movementX = touch.clientX - touch0.clientX;
      const movementY = touch.clientY - touch0.clientY;
      if (touch.length === 1) handleOrbit(movementX, movementY);
      else
        handlePanZoom(
          movementX,
          movementY,
          touch.scale / touch0.scale,
          touch0.clientX,
          touch0.clientY
        );
    }
    canvas.addEventListener("dblclick", onDblClick);
    canvas.addEventListener("contextmenu", onContextMenu);
    canvas.addEventListener("pointerdown", onPointerDown);
    canvas.addEventListener("wheel", onWheel, { passive: false });
    canvas.addEventListener("touchstart", onTouchStart, { passive: false });
    canvas.addEventListener("touchmove", onTouchMove, { passive: false });
  }
}
function getAverageTouch(touches) {
  let sumX = 0,
    sumY = 0,
    sumX2 = 0,
    sumY2 = 0;
  for (let touch of touches) {
    (sumX += touch.clientX), (sumX2 += touch.clientX ** 2);
    (sumY += touch.clientY), (sumY2 += touch.clientY ** 2);
  }
  const n = touches.length;
  return {
    clientX: sumX / n,
    clientY: sumY / n,
    length: n,
    scale: Math.sqrt(sumX2 * n - sumX ** 2 + (sumY2 * n - sumY ** 2)) / n,
  };
}
