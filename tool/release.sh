#!/usr/bin/env bash
# Preflight + publish helper for the process in doc/RELEASING.md.
#
#   tool/release.sh            run every check, stop before anything irreversible
#   tool/release.sh --publish  checks, then pub publish + git tag + GitHub release
set -euo pipefail
cd "$(dirname "$0")/.."

fail() { echo "✗ $1" >&2; exit 1; }
ok()   { echo "✓ $1"; }

# --- git state ---------------------------------------------------------------
[[ -z $(git status --porcelain) ]] || fail "working tree not clean"
branch=$(git rev-parse --abbrev-ref HEAD)
[[ $branch == main ]] || fail "release from main (currently on: $branch)"
git fetch -q origin main
[[ $(git rev-parse HEAD) == $(git rev-parse origin/main) ]] ||
  fail "main is not in sync with origin/main"
ok "git: clean tree, on main, synced with origin"

# --- version & changelog -----------------------------------------------------
version=$(sed -n 's/^version: *//p' pubspec.yaml)
[[ -n $version ]] || fail "no version: in pubspec.yaml"
! git rev-parse -q --verify "refs/tags/v$version" >/dev/null ||
  fail "tag v$version already exists — bump version: in pubspec.yaml"
grep -q "^## $version" CHANGELOG.md ||
  fail "CHANGELOG.md has no '## $version' entry"
! grep -q "^## Unreleased" CHANGELOG.md ||
  fail "CHANGELOG.md still has an '## Unreleased' section — fold it into $version"
ok "version $version: not yet tagged, CHANGELOG entry present"

# --- quality gates (RELEASING.md steps 1 & 4) --------------------------------
make check
ok "format + analyze + tests (VM & Chrome)"

dry=$(dart pub publish --dry-run 2>&1) || { echo "$dry" | tail -20; fail "publish dry-run failed"; }
echo "$dry" | grep -q "has 0 warnings" ||
  { echo "$dry" | tail -20; fail "publish dry-run has warnings"; }
ok "pub publish dry-run: 0 warnings"

# CI on main — best effort, the release must not outrun a red build.
ci=$(gh run list --branch main --limit 1 --json conclusion -q '.[0].conclusion' 2>/dev/null || true)
if [[ $ci == success ]]; then
  ok "CI on main: green"
else
  echo "⚠ CI on main: '${ci:-unknown}' — check Actions (stable + beta) before publishing"
fi

if [[ ${1:-} != --publish ]]; then
  echo
  echo "All checks passed. Release v$version with: tool/release.sh --publish"
  exit 0
fi

# --- irreversible from here (RELEASING.md steps 6-7) --------------------------
dart pub publish   # asks its own y/N confirmation; one-way, no undo
git tag "v$version"
git push origin "v$version"
notes=$(awk "/^## $version\$/{f=1;next} /^## /{f=0} f" CHANGELOG.md)
gh release create "v$version" --title "widget_snap $version" --notes "$notes"
echo
echo "Done. Post-release checks (RELEASING.md step 8):"
echo "  https://pub.dev/packages/widget_snap — version, README/images, score"
