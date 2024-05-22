export class Cropper {
  constructor(elem, getContentClientRect) {
    this.elem = elem;
    this.rect = [0, 0, 1, 1];
    this.getContentClientRect = getContentClientRect;
  }
  show() {
    this.resize();
    this.elem.style.visibility = "visible";
  }
  hide() {
    this.elem.style.visibility = "hidden";
  }
  resize(rect) {
    rect = rect || this.getContentClientRect();
    const par = this.elem.parentElement.getBoundingClientRect();
    this.elem.style.left =
      rect.left - par.left + this.rect[0] * rect.width + "px";
    this.elem.style.top =
      rect.top - par.top + this.rect[1] * rect.height + "px";
    this.elem.style.width = (this.rect[2] - this.rect[0]) * rect.width + "px";
    this.elem.style.height = (this.rect[3] - this.rect[1]) * rect.height + "px";
  }
  snap(clientX, clientY) {
    const rect = this.elem.getBoundingClientRect();
    const bbox = [rect.left, rect.top, rect.right, rect.bottom];
    const diff = bbox.map((v, i) => Math.abs(v - [clientX, clientY][i % 2]));
    const dmin = diff.reduce((s, v) => Math.min(s, v));
    for (let i = 0; i < 4; i++) if (diff[i] == dmin) return i;
  }
  crop(clientX, clientY) {
    const i = this.snap(clientX, clientY);
    const rect = this.getContentClientRect();
    const bbox = [rect.left, rect.top, rect.right, rect.bottom];
    this.rect[i] = Math.max(
      0,
      Math.min(
        1,
        ([clientX, clientY][i % 2] - bbox[i % 2]) /
          (bbox[(i % 2) + 2] - bbox[i % 2])
      )
    );
    this.resize(rect);
  }
}
