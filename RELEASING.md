# Quy trình release widget_snap

Tài liệu nội bộ cho maintainer. Mỗi version publish lên pub.dev là **bất biến**
(không sửa/xóa được, chỉ retract trong 7 ngày) — đi hết checklist trước khi bấm.

## 1. Code & kiểm thử

```sh
flutter analyze                                        # phải sạch 100% (lint = fail)
flutter test                                           # unit/widget tests trên VM
flutter test --platform chrome test/capture_test.dart  # verify runtime web
```

- Sửa gì thêm test đó — đặc biệt mọi thay đổi trong `lib/src/capture.dart`.
- Đổi hành vi hiển thị/capture → chạy example trên simulator xem bằng mắt:
  `cd example && flutter run`.
- Đổi hình minh họa README → regenerate bằng chính package:
  `flutter test tool/readme_images.dart` (lưu ý: font Roboto không có glyph `→`,
  đừng dùng trong text của hình).

## 2. Chọn version (semver — API đã cam kết từ 1.0.0)

| Bump | Khi nào |
|---|---|
| PATCH `x.y.Z` | Sửa bug, sửa docs/README, không đổi API |
| MINOR `x.Y.0` | Thêm tính năng/tham số mới, không phá code người dùng |
| MAJOR `X.0.0` | Breaking: đổi signature/hành vi của `toPngBytes` / `toPngFile` / `WidgetSnap`, nâng SDK tối thiểu |

Cập nhật `version:` trong `pubspec.yaml`.

- Nâng constraint `sdk:`/`flutter:` là breaking với người đang ở version cũ →
  tối thiểu MINOR, cân nhắc MAJOR.
- Hạ/nới constraint → phải test thật bằng SDK cũ (`fvm`), không đoán.

## 3. Cập nhật tài liệu

- `CHANGELOG.md`: thêm entry mới **lên đầu**, viết theo góc nhìn người dùng
  (cái gì đổi, migrate thế nào nếu breaking).
- `README.md`: cập nhật nếu API/tham số/limits đổi; cập nhật dòng
  "Verified on Flutter …" nếu đã test trên version Flutter mới.
- Nhớ: README trên pub.dev chỉ đổi khi publish version mới — gom mọi sửa docs
  vào release kế tiếp, đừng chờ "sửa sau".

## 4. Kiểm tra gói

```sh
dart pub publish --dry-run
```

Yêu cầu: **0 warnings**, archive size hợp lý (~700 KB — to bất thường là lọt
file rác; `build/` đã bị chặn bởi `.pubignore` + `.gitignore`).

## 5. Đẩy code & chờ CI

```sh
git add -A && git commit -m "release: vX.Y.Z"
git push
```

Chờ CI xanh **cả stable lẫn beta** (Actions → CI). Beta đỏ vì Flutter đổi
internal API → sửa trước khi release, đó chính là rủi ro số một của package này.

## 6. Publish

```sh
dart pub publish        # xác nhận y — một chiều, không undo
```

Lỡ publish sai: `dart pub retract <version>` (trong 7 ngày), rồi fix và publish
bản mới cao hơn. Không bao giờ xóa được version.

## 7. Tag & GitHub Release

```sh
git tag vX.Y.Z && git push origin vX.Y.Z
gh release create vX.Y.Z --title "widget_snap X.Y.Z" --notes "<copy từ CHANGELOG>"
```

## 8. Sau release (5 phút)

- Mở https://pub.dev/packages/widget_snap: version mới hiện, README/ảnh render
  đúng, score không tụt (tab Scores — pana chạy lại sau vài phút).
- Ảnh README lấy từ GitHub raw theo `repository:` — đảm bảo `doc/*.png` đã push.
- Quét issue/PR mới trên GitHub.

## Checklist rút gọn

```
[ ] analyze + test (VM & Chrome) xanh
[ ] version bump đúng semver
[ ] CHANGELOG + README cập nhật
[ ] dry-run 0 warnings
[ ] push, CI stable+beta xanh
[ ] dart pub publish
[ ] tag vX.Y.Z + GitHub release
[ ] kiểm tra trang pub.dev
```
