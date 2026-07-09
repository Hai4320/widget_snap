# widget_snap example

Captures an `Ink`-heavy widget offscreen on first frame and shows the result
side by side with a live copy — a blank capture is immediately visible.

The capture call in `lib/main.dart` is commented with every param: pin `width`
**or** `height` (the other axis grows to fit), plus `pixelRatio` and `delay`.

```sh
flutter run              # Android/iOS/desktop
flutter run -d chrome    # web
```
