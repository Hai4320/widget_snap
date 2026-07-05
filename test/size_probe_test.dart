import 'dart:ui' as ui;

import 'package:widget_snap/widget_snap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('image width matches requested width, not content intrinsics', (
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

    // Mirrors the tree export view: Padding → Column(min) → fixed-width Ink
    // card + indented forest container.
    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {},
            child: Ink(
              width: 320,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF2A5BD7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'root',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 13, top: 4),
            padding: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFFC9D5EE), width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 2,
                      margin: const EdgeInsets.only(top: 18),
                      color: const Color(0xFFC9D5EE),
                    ),
                    Container(width: 320, height: 40, color: const Color(0xFFEEF2FB)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // The tick+node row overflows by 2px like the real screen; intentional.
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (_) {};
    final bytes = await tester.runAsync(
      () => content.toPngBytes(ctx, width: 387),
    );
    FlutterError.onError = oldOnError;
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes!);
      return (await codec.getNextFrame()).image;
    });
    debugPrint('IMAGE ${image!.width} x ${image.height}');
    expect(image.width, (387 * 2.5).round(), reason: 'requested width * ratio');
  });
}
