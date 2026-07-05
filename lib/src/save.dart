/// File convenience layer, gated per platform: real `dart:io` implementation
/// on IO platforms, an [UnsupportedError] stub on the web (use `toPngBytes`
/// there and hand the bytes to a download/share mechanism).
library;

export 'save_io.dart' if (dart.library.js_interop) 'save_web.dart';
