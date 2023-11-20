export class FPSCounter {
  constructor() {
    this.index = 0;
    this.timeStamps = new Array(20).fill(0);
  }
  update(timeStamp) {
    const delta = timeStamp - this.timeStamps[this.index];
    this.timeStamps[this.index] = timeStamp;
    if (++this.index >= this.timeStamps.length) this.index = 0;
    return (1e3 * this.timeStamps.length) / delta;
  }
}
export function resizeCanvas(gl) {
  const window = gl.canvas.ownerDocument.defaultView;
  const canvasWidth = Math.round(
    window.devicePixelRatio * gl.canvas.clientWidth
  );
  const canvasHeight = Math.round(
    window.devicePixelRatio * gl.canvas.clientHeight
  );
  if (gl.canvas.width != canvasWidth || gl.canvas.height != canvasHeight) {
    gl.canvas.width = canvasWidth;
    gl.canvas.height = canvasHeight;
  }
}
export function downloadFile(url, fileName) {
  const a = document.createElement("a");
  a.style = "display: none";
  a.href = url;
  a.download = fileName;
  a.click();
}
