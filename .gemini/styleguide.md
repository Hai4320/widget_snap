# PR review guide for widget_snap (Gemini Code Assist)

## Context

Flutter package that exports widgets to PNG, published on pub.dev, zero
dependencies. The public API (`toPngBytes`, `toPngFile`, `WidgetSnap`) is
semver-committed since 1.0.0. Docs are part of the API surface — review them
with the same weight as code.

## Documentation checks

- **Dartdoc on every public member.** A new/changed public API without `///`
  docs (behavior, param interaction, platform caveats) is a blocking gap.
- **Docs move with the API.** An API/param/behavior change must update dartdoc,
  `README.md`, and `CHANGELOG.md` in the same PR — flag any that lag behind.
- **CHANGELOG entry is user-facing**: at the top, says what changed and how to
  migrate if breaking. Flag internal-jargon entries.
- **Example coverage**: a new param or capability should be exercised in
  `example/` — call out when it isn't.

## Quality checks

- **Breaking changes**: any change to the signature/behavior of the public API
  must be flagged — that's a MAJOR bump per `doc/RELEASING.md`.
- **Additive-only in minors**: new params must be optional with defaults that
  keep existing call sites compiling and behaving identically.
- **Tests included**: a change to `lib/src/capture.dart` without a new test is
  a gap. Behavior changes need coverage on both VM and web
  (`flutter test` + `--platform chrome`).
- **Fail loud**: error paths must throw with actionable messages — flag
  anything that could return a silent blank/garbage image.
- **New dependencies**: the package commits to zero runtime dependencies —
  adding one to `pubspec.yaml` should be rejected absent a very strong reason.
- **Web support**: code in `lib/src/` must run on both VM and web (conditional
  import via `save_io.dart`/`save_web.dart`; no direct `dart:io` import outside
  `*_io.dart` files).
- Don't ask for a `version:` bump in feature PRs — versions are bumped at
  release time.

## Ignore

- Formatting/style — `analysis_options.yaml` + `dart format` handle it; don't
  comment on formatting.
