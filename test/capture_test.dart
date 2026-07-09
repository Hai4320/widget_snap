import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_snap/widget_snap.dart';

void main() {
  testWidgets('toPngBytes captures painted content, not a blank canvas', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final bytes = await tester.runAsync(
      () => Container(
        width: 100,
        height: 50,
        color: const Color(0xFFFF0000),
      ).toPngBytes(ctx, width: 100),
    );
    expect(bytes, isNotNull);

    final image = await tester.runAsync(
      () async {
        final codec = await ui.instantiateImageCodec(bytes!);
        return (await codec.getNextFrame()).image;
      },
    );
    final data = await tester.runAsync(() => image!.toByteData());
    // Center pixel must be red, not the white fallback background.
    final w = image!.width;
    final center = ((image.height ~/ 2) * w + w ~/ 2) * 4;
    final rgba = data!.buffer.asUint8List();
    expect(rgba[center], 0xFF, reason: 'red channel');
    expect(rgba[center + 1], 0x00, reason: 'green channel');
    expect(rgba[center + 2], 0x00, reason: 'blue channel');
  });

  testWidgets('Ink + overflowing Row still paints (tree-export shape)', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {},
          child: Ink(
            width: 80,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFF0000FF)),
            child: const Text('root'),
          ),
        ),
        // Overflows the 100px canvas by 2px, like the device log.
        Row(
          children: [
            Container(width: 102, height: 10, color: const Color(0xFF00FF00)),
          ],
        ),
      ],
    );

    // The 2px overflow is intentional; keep its warning from failing the test.
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (_) {};
    final bytes = await tester.runAsync(
      () => content.toPngBytes(ctx, width: 100),
    );
    FlutterError.onError = oldOnError;
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes!);
      return (await codec.getNextFrame()).image;
    });
    final data = await tester.runAsync(() => image!.toByteData());
    final rgba = data!.buffer.asUint8List();
    // Pixel inside the Ink card away from the text glyphs
    // (logical (70,35) of the 80x40 card → physical scale = ratio).
    final scale = image!.width / 100;
    final px = ((35 * scale).round() * image.width + (70 * scale).round()) * 4;
    expect(rgba[px + 2], 0xFF, reason: 'Ink card blue must be painted');
  });

  testWidgets('content that throws in build fails loud, not blank garbage', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    // Tooltip requires an Overlay the offscreen tree doesn't have. Without the
    // fail-loud guard this silently becomes a 100000x100000 ErrorWidget and a
    // garbage export.
    final result = await tester.runAsync(
      () async {
        try {
          await const Tooltip(
            message: 'x',
            child: SizedBox(width: 10, height: 10),
          ).toPngBytes(ctx, width: 100);
          return null;
        } on Object catch (e) {
          // Intentional catch-all: the test only cares that it throws.
          return e;
        }
      },
    );
    expect(result, isNotNull, reason: 'export must throw, not return bytes');
  });
}
