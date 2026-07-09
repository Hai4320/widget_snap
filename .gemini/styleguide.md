# Hướng dẫn review PR cho widget_snap (Gemini Code Assist)

Viết review comment bằng tiếng Việt.

## Bối cảnh

Package Flutter export widget ra PNG, publish trên pub.dev, zero dependencies.
API public (`toPngBytes`, `toPngFile`, `WidgetSnap`) đã cam kết semver từ 1.0.0.

## Trọng tâm khi review

- **Breaking change**: mọi thay đổi signature/hành vi của API public phải được
  gắn cờ — đó là MAJOR bump theo `doc/RELEASING.md`.
- **Test đi kèm**: thay đổi trong `lib/src/capture.dart` mà không có test mới
  là thiếu sót, hãy chỉ ra.
- **Dependency mới**: package cam kết zero dependencies — thêm dependency vào
  `pubspec.yaml` cần lý do rất mạnh.
- **Web support**: code trong `lib/src/` phải chạy được cả VM lẫn web
  (conditional import qua `save_io.dart`/`save_web.dart`, không import `dart:io`
  trực tiếp ngoài file `*_io.dart`).
- Không yêu cầu bump `version:` trong PR feature — version bump làm lúc release.

## Bỏ qua

- Style đã có `analysis_options.yaml` + `dart format` lo — đừng comment về
  formatting.
