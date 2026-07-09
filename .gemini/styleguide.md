# PR review guide for widget_snap (Gemini Code Assist)

## Context

Flutter package that exports widgets to PNG, published on pub.dev, zero
dependencies. The public API (`toPngBytes`, `toPngFile`, `WidgetSnap`) is
semver-committed since 1.0.0.

## Review focus

- **Breaking changes**: any change to the signature/behavior of the public API
  must be flagged — that's a MAJOR bump per `doc/RELEASING.md`.
- **Tests included**: a change to `lib/src/capture.dart` without a new test is
  a gap — call it out.
- **New dependencies**: the package commits to zero dependencies — adding one
  to `pubspec.yaml` needs a very strong reason.
- **Web support**: code in `lib/src/` must run on both VM and web (conditional
  import via `save_io.dart`/`save_web.dart`; no direct `dart:io` import outside
  `*_io.dart` files).
- Don't ask for a `version:` bump in feature PRs — versions are bumped at
  release time.

## Ignore

- Formatting/style — `analysis_options.yaml` + `dart format` handle it; don't
  comment on formatting.
