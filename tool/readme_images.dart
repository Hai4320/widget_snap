// Generates the README/pub.dev images in doc/ using widget_snap itself:
//
//   flutter test tool/readme_images.dart
//
// Loads real Roboto + MaterialIcons from the Flutter SDK cache so text and
// icons render properly (the test environment's default font is blocky).
// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_snap/widget_snap.dart';

const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _faint = Color(0xFF94A3B8);
const _line = Color(0xFFE2E8F0);
const _indigo = Color(0xFF4F46E5);
const _violet = Color(0xFF7C3AED);

Future<void> _loadFonts() async {
  final dir =
      '${Platform.environment['FLUTTER_ROOT']}'
      '/bin/cache/artifacts/material_fonts';
  ByteData bytes(String file) =>
      ByteData.sublistView(File('$dir/$file').readAsBytesSync());

  final roboto = FontLoader('Roboto')
    ..addFont(Future.value(bytes('Roboto-Regular.ttf')))
    ..addFont(Future.value(bytes('Roboto-Medium.ttf')))
    ..addFont(Future.value(bytes('Roboto-Bold.ttf')));
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(bytes('MaterialIcons-Regular.otf')));
  await roboto.load();
  await icons.load();
}

void main() {
  testWidgets('generate README images', (tester) async {
    await tester.runAsync(_loadFonts);

    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    Directory('doc').createSync();
    await tester.runAsync(() async {
      final banner = await _banner().toPngBytes(ctx, width: 720, pixelRatio: 2);
      await File('doc/banner.png').writeAsBytes(banner);
      final tall = await _tallReport().toPngBytes(
        ctx,
        width: 420,
        pixelRatio: 2,
      );
      await File('doc/demo_tall.png').writeAsBytes(tall);
    });
  });
}

Widget _pill(String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: .16),
    borderRadius: BorderRadius.circular(999),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),
);

Widget _banner() => Container(
  padding: const EdgeInsets.fromLTRB(40, 36, 40, 36),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [_indigo, _violet],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: Row(
    children: [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.center_focus_strong,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'widget_snap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Turn any widget into a PNG. Rendered offscreen —\n'
              'even content larger than the screen.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .88),
                fontSize: 15.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill('zero deps'),
                _pill('pure Flutter pipeline'),
                _pill('Android · iOS · Web · Desktop'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 32),
      _receiptCard(),
    ],
  ),
);

Widget _receiptCard() {
  Widget item(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(label, style: TextStyle(color: _muted, fontSize: 12.5)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: _ink,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  return Container(
    width: 220,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .25),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_indigo, _violet]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.receipt_long, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Receipt',
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'PNG',
                style: TextStyle(
                  color: const Color(0xFF059669),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(height: 1, color: _line),
        const SizedBox(height: 8),
        item('Latte × 2', r'$9.00'),
        item('Croissant', r'$3.50'),
        item('Service', r'$1.20'),
        const SizedBox(height: 8),
        Container(height: 1, color: _line),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Total',
              style: TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              r'$13.70',
              style: TextStyle(
                color: _indigo,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _tallReport() {
  const dots = [
    Color(0xFF10B981),
    Color(0xFF4F46E5),
    Color(0xFFF59E0B),
    Color(0xFFF43F5E),
  ];
  const entries = [
    ('Morning run — riverside loop', 'Mon · 06:12 · easy pace', '48 min'),
    ('Strength: push day', 'Mon · 18:30 · gym', '55 min'),
    ('Interval sprints 8 × 400 m', 'Wed · 06:05 · track', '42 min'),
    ('Yoga & mobility', 'Thu · 07:00 · home', '30 min'),
    ('Long ride — coast road', 'Sat · 08:20 · 61 km', '2 h 10'),
    ('Recovery swim', 'Sun · 09:15 · pool', '35 min'),
  ];

  Widget stat(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: _muted, fontSize: 10.5)),
        ],
      ),
    ),
  );

  Widget entry(int i, (String, String, String) e) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: dots[i % dots.length],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.$1,
                style: TextStyle(
                  color: _ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(e.$2, style: TextStyle(color: _muted, fontSize: 11.5)),
            ],
          ),
        ),
        Text(
          e.$3,
          style: TextStyle(
            color: _indigo,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget week(int n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 18),
      Text(
        'WEEK $n',
        style: TextStyle(
          color: _faint,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 4),
      for (final (i, e) in entries.indexed) entry(i + n, e),
    ],
  );

  return Container(
    padding: const EdgeInsets.all(26),
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_indigo, _violet]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.insights, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity report',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'March 2026 · 24 sessions',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            stat('24', 'sessions'),
            const SizedBox(width: 10),
            stat('18 h 40 m', 'total time'),
            const SizedBox(width: 10),
            stat('312 km', 'distance'),
          ],
        ),
        for (var n = 1; n <= 4; n++) week(n),
        const SizedBox(height: 16),
        Container(height: 1, color: _line),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.center_focus_strong, color: _faint, size: 14),
            const SizedBox(width: 6),
            Text(
              'exported offscreen by widget_snap — one call',
              style: TextStyle(color: _faint, fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );
}
