import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'capture.dart';
import 'save.dart';

/// Discoverable entry point named after the package: type `WidgetSnap.` and
/// autocomplete shows the whole API. Each method is a one-line delegate to
/// the `Widget` extensions ([WidgetSnapPng.toPngBytes],
/// [WidgetSnapPngFile.toPngFile]) — use whichever style reads better.
abstract final class WidgetSnap {
  /// See [WidgetSnapPng.toPngBytes].
  static Future<Uint8List> pngBytes(
    Widget content,
    BuildContext context, {
    double? width,
    double? height,
    double pixelRatio = 2.5,
    Duration delay = Duration.zero,
  }) => content.toPngBytes(
    context,
    width: width,
    height: height,
    pixelRatio: pixelRatio,
    delay: delay,
  );

  /// See [WidgetSnapPngFile.toPngFile]. Not supported on the web.
  static Future<String> pngFile(
    Widget content,
    BuildContext context, {
    required String filename,
    double? width,
    double? height,
    double pixelRatio = 2.5,
    Duration delay = Duration.zero,
  }) => content.toPngFile(
    context,
    filename: filename,
    width: width,
    height: height,
    pixelRatio: pixelRatio,
    delay: delay,
  );
}
