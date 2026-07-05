import 'dart:io';

import 'package:flutter/widgets.dart';

import 'capture.dart';

/// `dart:io` convenience layer: `myWidget.toPngFile(context, filename: …)`.
extension WidgetSnapPngFile on Widget {
  /// Convenience wrapper over [WidgetSnapPng.toPngBytes]: captures this widget
  /// and writes the PNG to [filename] under the system temp dir, returning
  /// the written file's path. Use this when the next step needs a path (share
  /// sheet, gallery save); use `toPngBytes` directly for upload/preview.
  ///
  /// Not supported on the web — throws [UnsupportedError] there. Use
  /// `toPngBytes` and trigger a browser download instead.
  Future<String> toPngFile(
    BuildContext context, {
    required String filename,
    double? width,
    double pixelRatio = 2.5,
    Duration delay = Duration.zero,
  }) async {
    final bytes = await toPngBytes(
      context,
      width: width,
      pixelRatio: pixelRatio,
      delay: delay,
    );
    final file = File('${Directory.systemTemp.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
