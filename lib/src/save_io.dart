import 'dart:io';

import 'package:flutter/material.dart';

import 'package:widget_snap/src/capture.dart';

/// `dart:io` convenience layer: `myWidget.toPngFile(context, filename: …)`.
extension WidgetSnapPngFile on Widget {
  /// Convenience wrapper over [WidgetSnapPng.toPngBytes]: captures this widget
  /// and writes the PNG to [filename] under the system temp dir, returning
  /// the written file's path. Use this when the next step needs a path (share
  /// sheet, gallery save); use `toPngBytes` directly for upload/preview.
  ///
  /// [filename] must be a bare file name (`report.png`), not a path: the
  /// file always lands under the system temp dir, and a path separator in
  /// the name throws an [ArgumentError].
  ///
  /// Not supported on the web — throws [UnsupportedError] there. Use
  /// `toPngBytes` and trigger a browser download instead.
  ///
  /// [backgroundColor] fills behind the content (defaults to opaque white);
  /// pass `Colors.transparent` for a PNG with an alpha channel. See
  /// [WidgetSnapPng.toPngBytes] for the full parameter reference.
  Future<String> toPngFile(
    BuildContext context, {
    required String filename,
    double? width,
    double? height,
    double pixelRatio = 2.5,
    Duration delay = Duration.zero,
    Color backgroundColor = Colors.white,
  }) async {
    // Fail fast: 'exports/a.png' would silently write outside the temp dir
    // (or die deep inside File with an obscure ENOENT).
    if (filename.contains('/') || filename.contains(r'\')) {
      throw ArgumentError.value(
        filename,
        'filename',
        'must be a bare file name (no path separators): the file is always '
            'written under the system temp directory',
      );
    }
    final bytes = await toPngBytes(
      context,
      width: width,
      height: height,
      pixelRatio: pixelRatio,
      delay: delay,
      backgroundColor: backgroundColor,
    );
    final file = File('${Directory.systemTemp.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
