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

## Conventions

- `flutter analyze` must be 100% clean — a lint is a failure.
- Every change ships with tests, especially anything in `lib/src/capture.dart`.
- The API is semver-committed since 1.0.0: changing the signature/behavior of
  `toPngBytes`/`toPngFile`/`WidgetSnap` is a MAJOR bump. Full release process:
  `doc/RELEASING.md`.
- Don't bump `version:` in pubspec in feature work — bump at release time.
- README images: the Roboto font has no `→` glyph, don't use it in image text.
