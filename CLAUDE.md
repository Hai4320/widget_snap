# widget_snap

Flutter package that exports any widget to PNG — rendered offscreen, supports
content larger than the screen. Pure Flutter, zero dependencies, published on
pub.dev.

## Commands

```sh
make check      # format + analyze + test + web test (run before committing)
make test-web   # flutter test --platform chrome test/capture_test.dart
make images     # regenerate README images in doc/ (using the package itself)
```

## Structure

- `lib/src/capture.dart` — core render pipeline (extension `toPngBytes`/`toPngFile`)
- `lib/src/facade.dart` — static API `WidgetSnap.pngBytes` / `WidgetSnap.pngFile`
- `lib/src/save_io.dart` / `save_web.dart` — per-platform file saving (conditional import)
- `tool/readme_images.dart` — generates README images, run via `flutter test`

## Documentation requirements

This is a published library — docs are part of the API surface:

- **100% dartdoc on the public API.** Every public member gets `///`: what it
  does, how params interact, platform caveats (e.g. "not supported on the
  web"). No `// TODO` or bare declarations in the public surface.
- **One change, all surfaces.** An API/param/behavior change updates dartdoc,
  `README.md`, and `CHANGELOG.md` in the same PR — never "docs later"
  (pub.dev only refreshes the README on publish).
- **CHANGELOG is user-facing.** New entry at the top, written from the user's
  perspective: what changed, how to migrate if breaking. No internal jargon.
- **Example stays current.** A new param or capability gets exercised in
  `example/` so users see it working.
- README images: the Roboto font has no `→` glyph, don't use it in image text.

## Quality requirements

- `flutter analyze` must be 100% clean — a lint is a failure. Lint set is
  `very_good_analysis` (strict: 80-char lines, package imports, dartdoc on
  public members…).
- Every change ships with tests, especially anything in `lib/src/capture.dart`.
  Behavior changes need tests on **both VM and web** (`make check` covers both).
- **Zero dependencies is a feature.** Never add a runtime dependency to
  `pubspec.yaml`.
- **Fail loud.** Errors surface as thrown exceptions with actionable messages —
  never a silent blank/garbage image (see the existing "fails loud" tests).
- **Additive-only in minor versions.** New params must be optional with
  defaults that keep existing call sites compiling and behaving identically.
- The API is semver-committed since 1.0.0: changing the signature/behavior of
  `toPngBytes`/`toPngFile`/`WidgetSnap` is a MAJOR bump. Full release process:
  `doc/RELEASING.md` (dry-run must show 0 warnings; pub.dev score must not drop).
- Don't bump `version:` in pubspec in feature work — bump at release time.
