# Changelog

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
