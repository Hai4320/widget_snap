// Size-limit probe — intentionally pushes the renderer until it breaks.
// No `_test` suffix, so plain `flutter test` (make check) skips it; run
// explicitly:
//
//   flutter test test/stress_probe.dart
//   flutter test --platform chrome test/stress_probe.dart
//
// Prints one line per milestone: `OK <WxH> <ms> <bytes>` or `FAIL <error>`.
//
// Measured 2026-07 (Flutter stable, macOS): VM passes every milestone up to
// 131072px tall and 16384x16384. Chrome passes 131072px tall / 65536px wide
// (skinny) but dies on total area: 13312^2 OK, 14336^2 fails ('Unable to
// convert read pixels from SkImage'), 16384^2 aborts the wasm runtime. The
// square test is EXPECTED to fail its last milestone on Chrome.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_snap/widget_snap.dart';

int _be32(Uint8List b, int o) =>
    (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

void main() {
  late BuildContext ctx;

  Future<void> host(WidgetTester tester) async {
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
  }

  Future<String> probe(
    WidgetTester tester,
    Widget content, {
    double? width,
    double? height,
  }) async {
    final sw = Stopwatch()..start();
    // runAsync returns null when its closure throws (the error only goes to
    // the test log) — so catch INSIDE the closure and carry the real error
    // message out as a value. Catch Object: the ceiling throws Errors too.
    final outcome = await tester.runAsync<Object>(() async {
      try {
        return await content.toPngBytes(
          ctx,
          width: width,
          height: height,
          pixelRatio: 1,
        );
      } on Object catch (e) {
        return 'FAIL: $e';
      }
    });
    sw.stop();
    if (outcome is! Uint8List) {
      return '${outcome ?? "FAIL: runAsync returned null"} '
          '(${sw.elapsedMilliseconds}ms)';
    }
    // PNG IHDR carries width/height at bytes 16/20 — no decode needed.
    final w = _be32(outcome, 16);
    final h = _be32(outcome, 20);
    return 'OK ${w}x$h ${sw.elapsedMilliseconds}ms ${outcome.length} bytes';
  }

  // Striped column with text: realistic-ish content, height = h exactly.
  Widget stripes(int h) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < h ~/ 512; i++)
        Container(
          width: 400,
          height: 512,
          color: i.isEven ? Colors.indigo : Colors.amber,
          child: Text('stripe $i'),
        ),
    ],
  );

  testWidgets('grow axis: tall content, width pinned at 400', (tester) async {
    await host(tester);
    for (final h in [4096, 8192, 16384, 32768, 65536, 131072]) {
      final r = await probe(tester, stripes(h), width: 400);
      debugPrint('GROW height=$h -> $r');
    }
  });

  testWidgets('pinned axis over the cap: ratio floors to 1', (tester) async {
    await host(tester);
    for (final w in [4096, 8192, 16384, 32768, 65536]) {
      final content = SizedBox(
        width: w.toDouble(),
        height: 64,
        child: const ColoredBox(color: Colors.teal),
      );
      final r = await probe(tester, content, width: w.toDouble());
      debugPrint('PINNED width=$w -> $r');
    }
  });

  testWidgets('square: both axes pinned', (tester) async {
    await host(tester);
    for (final s in [4096, 8192, 16384]) {
      const content = ColoredBox(color: Colors.deepOrange);
      final r = await probe(
        tester,
        content,
        width: s.toDouble(),
        height: s.toDouble(),
      );
      debugPrint('SQUARE ${s}x$s -> $r');
    }
  });
}
