# widget_snap release process

Internal maintainer doc. Every version published to pub.dev is **immutable**
(no edits/deletes, only a 7-day retract window) — walk the whole checklist
before pulling the trigger.

Automation: `make release-check` runs every gate below (steps 1, 4, plus
version/CHANGELOG/tag consistency) and stops before anything irreversible;
`make release` adds publish + tag + GitHub release (steps 6–7). This
walkthrough stays the source of truth for *what* the gates mean.

## 1. Code & tests

```sh
flutter analyze                                        # must be 100% clean (lint = fail)
flutter test                                           # unit/widget tests on the VM
flutter test --platform chrome test/capture_test.dart  # verify web runtime
```

- Every change ships with tests — especially anything in `lib/src/capture.dart`.
- Display/capture behavior changed → run the example on a simulator and eyeball
  it: `cd example && flutter run`.
- README images changed → regenerate with the package itself:
  `flutter test tool/readme_images.dart` (note: the Roboto font has no `→`
  glyph, don't use it in image text).

## 2. Pick a version (semver — API committed since 1.0.0)

| Bump | When |
|---|---|
| PATCH `x.y.Z` | Bug fixes, docs/README fixes, no API change |
| MINOR `x.Y.0` | New feature/parameter, doesn't break user code |
| MAJOR `X.0.0` | Breaking: signature/behavior change of `toPngBytes` / `toPngFile` / `WidgetSnap`, raising the minimum SDK |

Update `version:` in `pubspec.yaml`.

- Raising the `sdk:`/`flutter:` constraint breaks users on older versions →
  MINOR at minimum, consider MAJOR.
- Lowering/widening a constraint → actually test with the old SDK (`fvm`),
  don't guess.

## 3. Update docs

- `CHANGELOG.md`: add the new entry **at the top**, written from the user's
  perspective (what changed, how to migrate if breaking).
- `README.md`: update if API/parameters/limits changed; update the
  "Verified on Flutter …" line if tested on a newer Flutter.
- Remember: the README on pub.dev only changes when a new version is published —
  batch every docs fix into the next release, don't leave it for "later".

## 4. Validate the package

```sh
dart pub publish --dry-run
```

Requirements: **0 warnings**, sane archive size (~700 KB — unusually large
means junk files leaked in; `build/` is blocked by `.pubignore` + `.gitignore`).

## 5. Push & wait for CI

```sh
git add -A && git commit -m "release: vX.Y.Z"
git push
```

Wait for CI to go green on **both stable and beta** (Actions → CI). Beta going
red because Flutter changed an internal API → fix before releasing; that is
this package's number-one risk.

## 6. Publish

```sh
dart pub publish        # confirm y — one-way, no undo
```

Published the wrong thing: `dart pub retract <version>` (within 7 days), then
fix and publish a newer version. Versions can never be deleted.

## 7. Tag & GitHub Release

```sh
git tag vX.Y.Z && git push origin vX.Y.Z
gh release create vX.Y.Z --title "widget_snap X.Y.Z" --notes "<copy from CHANGELOG>"
```

## 8. After release (5 minutes)

- Open https://pub.dev/packages/widget_snap: new version shows, README/images
  render correctly, score didn't drop (Scores tab — pana reruns after a few
  minutes).
- README images are served from GitHub raw via `repository:` — make sure
  `doc/*.png` is pushed.
- Sweep new issues/PRs on GitHub.

## Short checklist

```
[ ] analyze + test (VM & Chrome) green
[ ] version bump follows semver
[ ] CHANGELOG + README updated
[ ] dry-run 0 warnings
[ ] push, CI stable+beta green
[ ] dart pub publish
[ ] tag vX.Y.Z + GitHub release
[ ] check the pub.dev page
```
