# Targets mirror the checklist in doc/RELEASING.md
.PHONY: get format analyze test test-web images check release-check release

get:
	flutter pub get

format:
	dart format .

analyze:
	flutter analyze

test:
	flutter test

test-web:
	flutter test --platform chrome test/capture_test.dart

images:
	flutter test tool/readme_images.dart

check: format analyze test test-web

release-check:
	tool/release.sh

release:
	tool/release.sh --publish
