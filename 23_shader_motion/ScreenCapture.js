const OFFSET = Symbol();
function isFullscreen(win) {
  return win.fullScreen !== undefined
    ? win.fullScreen // firefox
    : win.outerWidth >= win.screen.width - 16 &&
        win.outerHeight >= win.screen.height - 16; // account for border
}
function isMaximized(win) {
  return (
    win.outerWidth >= win.screen.availWidth &&
    win.outerHeight >= win.screen.availHeight
  ); // account for border
}
function getInnerScreenXY(win) {
  if (win.mozInnerScreenX !== undefined)
    return { x: win.mozInnerScreenX, y: win.mozInnerScreenY };
  if (win[OFFSET] === undefined) {
    // hack: use mouseevent screenXY
    win[OFFSET] = { x: 0, y: 0 };
    win.addEventListener(
      "mousemove",
      function (event) {
        const { left, top } = getWindowCapturePadding(win);
        win[OFFSET].x = event.screenX - event.clientX - (win.screenX - left);
        win[OFFSET].y = event.screenY - event.clientY - (win.screenY - top);
      },
      { capture: true, passive: true }
    );
  }
  const { left, top } = getWindowCapturePadding(win);
  return {
    x: win[OFFSET].x + (win.screenX - left),
    y: win[OFFSET].y + (win.screenY - top),
  };
}
function getWindowCapturePadding(win) {
  if (!/Windows/.test(navigator.userAgent))
    return { left: 0, right: 0, top: 0, bottom: 0 };
  const border = 8 / win.devicePixelRatio; // windows 8px border
  if (win.mozInnerScreenX !== undefined)
    // firefox
    return isFullscreen(win)
      ? { left: 0, right: 0, top: 0, bottom: 0 }
      : isMaximized(win)
      ? { left: 0, right: -border, top: 0, bottom: -border / 2 } // remove corner
      : { left: 0, right: 0, top: 0, bottom: 0 };
  // chrome, edge
  else
    return isFullscreen(win)
      ? { left: border, right: border, top: border, bottom: border } // add border
      : isMaximized(win)
      ? { left: 0, right: 0, top: border, bottom: 0 } // add padding-top
      : { left: -border, right: -border, top: 0, bottom: -border }; // add padding-top & remove border
}
export const getCaptureClientRect = {
  window(win) {
    const { x, y } = getInnerScreenXY(win);
    const { left, right, top, bottom } = getWindowCapturePadding(win);
    return {
      x: win.screenX - left - x,
      y: win.screenY - top - y,
      width: win.outerWidth + left + right,
      height: win.outerHeight + top + bottom,
    };
  },
  monitor(win) {
    const { x, y } = getInnerScreenXY(win);
    return { x: -x, y: -y, width: win.screen.width, height: win.screen.height };
  },
  browser(win) {
    return { x: 0, y: 0, width: win.innerWidth, height: win.innerHeight };
  },
};
export function getDisplaySurface(track) {
  return (
    track.getSettings().displaySurface ||
    (/monitor/i.test(track.label) ? "monitor" : "window")
  );
}
