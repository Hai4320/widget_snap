# widget_snap

Flutter package export widget ra PNG — render offscreen, hỗ trợ nội dung lớn
hơn màn hình. Pure Flutter, zero dependencies, publish trên pub.dev.

## Lệnh

```sh
make check      # format + analyze + test + test web (chạy trước khi commit)
make test-web   # flutter test --platform chrome test/capture_test.dart
make images     # regenerate hình README trong doc/ (bằng chính package)
```

## Cấu trúc

- `lib/src/capture.dart` — render pipeline chính (extension `toPngBytes`/`toPngFile`)
- `lib/src/facade.dart` — API static `WidgetSnap.pngBytes` / `WidgetSnap.pngFile`
- `lib/src/save_io.dart` / `save_web.dart` — lưu file theo platform (conditional import)
- `tool/readme_images.dart` — generate hình README, chạy qua `flutter test`

## Quy ước

- `flutter analyze` phải sạch 100% — lint là fail.
- Sửa gì thêm test đó, đặc biệt mọi thay đổi trong `lib/src/capture.dart`.
- API đã cam kết semver từ 1.0.0: đổi signature/hành vi của
  `toPngBytes`/`toPngFile`/`WidgetSnap` là MAJOR. Quy trình release đầy đủ:
  `doc/RELEASING.md`.
- Không bump `version:` trong pubspec khi làm feature — bump lúc release.
- Hình README: font Roboto không có glyph `→`, đừng dùng trong text của hình.
