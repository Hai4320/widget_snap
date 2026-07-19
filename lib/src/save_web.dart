import 'package:flutter/material.dart';

import 'package:widget_snap/src/capture.dart';

/// Web stub for the file convenience layer: browsers have no writable
/// filesystem, so [toPngFile] throws. Same signature as the IO variant so
/// shared mobile+web code compiles and `kIsWeb` guards work.
extension WidgetSnapPngFile on Widget {
  /// Not supported on the web — throws [UnsupportedError]. Use
  /// [WidgetSnapPng.toPngBytes] and hand the bytes to a download/share
  /// mechanism (e.g. `package:web` anchor download, `share_plus`).
  Future<String> toPngFile(
    BuildContext context, {
    required String filename,
    double? width,
    double? height,
    double pixelRatio = 2.5,
    Duration delay = Duration.zero,
    Color backgroundColor = Colors.white,
  }) async {
    throw UnsupportedError(
      'toPngFile is not supported on the web: there is no writable '
      'filesystem. Use toPngBytes and trigger a browser download instead.',
    );
  }
}
