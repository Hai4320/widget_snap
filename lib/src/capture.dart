import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Core capture API: `myWidget.toPngBytes(context)`.
extension WidgetSnapPng on Widget {
  /// Renders this widget in an offscreen tree and returns the encoded PNG
  /// bytes. Pin [width], [height], or both; the unpinned axis grows to fit the
  /// content. With neither set, defaults to the current view's width (height
  /// grows) — use [height] for naturally-wide content (timelines, charts).
  /// Content with async images? Pass a [delay] so they resolve before capture.
  ///
  /// Pure capture, no IO — the host app owns what happens to the bytes.
  /// `toPngFile` is the ready-made temp-file wrapper.
  ///
  /// Self-contained: drives Flutter's own render pipeline (BuildOwner +
  /// PipelineOwner + RenderView) — no `screenshot`/third-party capture dep.
  /// The widget never has to be mounted or visible, so content larger than the
  /// screen works. [context] carries the app's inherited themes (fonts,
  /// colors, text styles, directionality) into the offscreen tree.
  Future<Uint8List> toPngBytes(
    BuildContext context, {
    double? width,
    double? height,
    double pixelRatio = 2.5,
    Duration delay = Duration.zero,
  }) async {
    // Pin the given axis; the other grows to fit. Default to the current
    // view's width (matches what the user sees) only when neither axis is set.
    final pinnedWidth =
        width ?? (height == null ? MediaQuery.sizeOf(context).width : null);
    // ponytail: clamp by the pinned axis (the larger, if both) — the GPU
    // texture cap (~4096px on low-end devices) would clip or OOM huge canvases.
    // The *growing* axis can still exceed the cap; revisit with tiled capture
    // if users hit it.
    final cap = [
      pinnedWidth,
      height,
    ].whereType<double>().reduce((a, b) => a > b ? a : b);
    // A pinned axis larger than the cap makes 4096/cap < 1.0. We never
    // downscale below native, so floor the allowed maximum at 1.0: the pinned
    // axis just rides over the cap (same caveat as the growing axis).
    final maxRatio = math.max(1, 4096 / cap).toDouble();
    final ratio = math.min(math.max(pixelRatio, 1), maxRatio).toDouble();
    final flutterView = View.of(context);

    final pipelineOwner = PipelineOwner();
    // The offscreen tree MUST mount on the framework's own BuildOwner:
    // `GlobalKey.currentContext` resolves through
    // `WidgetsBinding.instance.buildOwner`'s registry, so under a private
    // BuildOwner every GlobalKey in the content — including Flutter-internal
    // ones (`Ink`, form fields) — comes back null and the build crashes. The
    // tree is unmounted again in the `finally` below so those keys unregister
    // and the tree can be GC'd.
    final buildOwner = WidgetsBinding.instance.buildOwner!;

    // Keep a direct handle on the boundary render object we rasterize (a
    // GlobalKey lookup would find the *live* app tree's owner registry, not
    // this subtree).
    final repaintBoundary = RenderRepaintBoundary();

    // Pin each given axis (min == max); leave the other unbounded so the
    // RenderView sizes the child to its content along it.
    final constraints = BoxConstraints(
      minWidth: pinnedWidth ?? 0,
      maxWidth: pinnedWidth ?? double.infinity,
      minHeight: height ?? 0,
      maxHeight: height ?? double.infinity,
    );
    final renderView = RenderView(
      view: flutterView,
      configuration: ViewConfiguration(
        logicalConstraints: constraints,
        physicalConstraints: constraints * ratio,
        devicePixelRatio: ratio,
      ),
      child: repaintBoundary,
    );
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    // A widget that throws during build (e.g. Tooltip, which needs an Overlay
    // this headless tree doesn't have) is silently swapped for a
    // 100000x100000 ErrorWidget by the framework — the export would come out
    // as unusable blown-up garbage. Capture build errors and fail loud with
    // the original exception instead.
    final buildErrors = <FlutterErrorDetails>[];
    T collectingBuildErrors<T>(T Function() body) {
      final oldOnError = FlutterError.onError;
      FlutterError.onError = buildErrors.add;
      try {
        return body();
      } finally {
        FlutterError.onError = oldOnError;
      }
    }

    // The offscreen tree has no MaterialApp above it: provide media/direction
    // and a white Material so Ink, InkWell and Text render like in-app. The
    // widget tree mounts directly under the boundary — it sizes to the
    // content exactly.
    final rootElement = collectingBuildErrors(
      () => RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: MediaQuery(
          data: MediaQuery.of(context),
          child: Directionality(
            textDirection: Directionality.of(context),
            child: Material(color: Colors.white, child: this),
          ),
        ),
      ).attachToRenderTree(buildOwner),
    );

    try {
      if (buildErrors.isNotEmpty) {
        Error.throwWithStackTrace(
          buildErrors.first.exception,
          buildErrors.first.stack ?? StackTrace.current,
        );
      }
      buildOwner.finalizeTree();
      pipelineOwner
        ..flushLayout()
        ..flushCompositingBits()
        ..flushPaint();

      // Async content (NetworkImage, asset decode) paints blank on the first
      // frame. A non-zero [delay] gives it time to resolve, then rebuilds and
      // repaints before rasterizing.
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
        collectingBuildErrors(() {
          buildOwner
            ..buildScope(rootElement)
            ..finalizeTree();
        });
        if (buildErrors.isNotEmpty) {
          Error.throwWithStackTrace(
            buildErrors.first.exception,
            buildErrors.first.stack ?? StackTrace.current,
          );
        }
        pipelineOwner
          ..flushLayout()
          ..flushCompositingBits()
          ..flushPaint();
      }

      final image = await repaintBoundary.toImage(pixelRatio: ratio);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        return bytes!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      // Detach the content (adapter with no child) and unmount the subtree so
      // its GlobalKeys leave the shared BuildOwner registry — otherwise every
      // export leaks its tree and risks duplicate-key crashes on re-export.
      RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
      ).attachToRenderTree(buildOwner, rootElement);
      buildOwner.finalizeTree();
    }
  }
}
