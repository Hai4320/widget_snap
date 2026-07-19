# Changelog

## 1.2.0

- Add optional `backgroundColor` param to `toPngBytes` / `toPngFile` /
  `WidgetSnap.*`. Fills behind the content; defaults to opaque white (existing
  call sites are unchanged). Pass `Colors.transparent` for a PNG with an alpha
  channel, or any color to tint the canvas.

## 1.1.0

- Add optional `height` param to `toPngBytes` / `toPngFile` / `WidgetSnap.*`.
  Pin the width **or** the height (or both); the unpinned axis grows to fit.
  Pinning height captures naturally-wide content (timelines, charts) without
  distortion. The `pixelRatio` GPU-cap clamp now follows the pinned axis.

## 1.0.1

- Docs: badges and CI (stable + beta, weekly) — no code changes.

## 1.0.0

Initial release.

- `toPngBytes` / `toPngFile` extension methods on `Widget`, plus the
  `WidgetSnap` facade mirroring both.
- Offscreen capture through Flutter's own render pipeline — the widget never
  has to be mounted or visible, so content larger than the screen works.
- Width-driven layout: pick the width, height grows to fit; `pixelRatio` is
  clamped to the ~4096 px GPU texture cap.
- Inherits theme, `MediaQuery`, and text direction from the given `context`.
- Fails loud on build errors in the offscreen tree (e.g. `Tooltip` without an
  `Overlay`) instead of exporting a blown-up `ErrorWidget`.
- All platforms, no permissions, zero dependencies. On the web use
  `toPngBytes`; `toPngFile` throws `UnsupportedError` (no writable
  filesystem).
- Verified on Flutter 3.35 and 3.41 — tests run on the VM and in Chrome,
  example app exercised on iOS.
