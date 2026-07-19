import 'dart:typed_data';

import 'package:widget_snap/widget_snap.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: DemoScreen(), debugShowCheckedModeBanner: false);
}

/// Captures an Ink-heavy widget offscreen on first frame and shows the result
/// side by side with a live copy, so a blank capture is immediately visible.
class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});
  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  Uint8List? _bytes; // width-pinned: tall, narrow content
  Uint8List? _wideBytes; // height-pinned: wide, short content
  Uint8List? _transparentBytes; // transparent backgroundColor → alpha channel
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Pin one axis; the other grows to fit the content.
        //   width + height together → fixed box (content clips if larger)
        //   neither      → defaults to the current view's width
        // pixelRatio (default 2.5) is the raster scale, clamped so the pinned
        // axis stays under the ~4096px GPU cap. delay: lets async images
        // (network/asset) resolve before capture. backgroundColor (default
        // white) fills behind bare content — use Colors.transparent for alpha.

        // Tall + narrow → pin the width, height auto-fits.
        final b = await _content().toPngBytes(context, width: 320);
        if (!mounted) return;
        // Wide + short (a chart) → pin the height, width auto-fits.
        // Tint the canvas so the bare bars read against a card, not white.
        final w = await _wideContent().toPngBytes(
          context,
          height: 140,
          backgroundColor: const Color(0xFFF2F4FF),
        );
        if (!mounted) return;
        // Transparent canvas → PNG with an alpha channel, so whatever it's
        // composited over shows through (proven below by the orange backdrop).
        final t = await _content().toPngBytes(
          context,
          width: 320,
          backgroundColor: Colors.transparent,
        );
        if (!mounted) return;
        setState(() {
          _bytes = b;
          _wideBytes = w;
          _transparentBytes = t;
        });
      } catch (e) {
        if (mounted) setState(() => _error = e);
      }
    });
  }

  /// Wide, short content: a bar chart with no intrinsic width constraint —
  /// the case that motivated pinning height instead of width.
  Widget _wideContent() => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      for (final h in const [50.0, 95.0, 65.0, 110.0, 40.0, 85.0, 70.0, 100.0])
        Container(
          width: 28,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: const Color(0xFF2A5BD7),
        ),
    ],
  );

  Widget _content() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InkWell(
        onTap: () {},
        child: Ink(
          width: 280,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A5BD7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Ink card — blue box, white text',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Container(width: 280, height: 12, color: const Color(0xFF23A047)),
      const SizedBox(height: 10),
      Container(width: 120, height: 40, color: const Color(0xFFCC3344)),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('widget_snap demo')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LIVE:'),
          _content(),
          const Divider(height: 32),
          const Text('CAPTURED (width: 320 — height grows):'),
          if (_error != null) Text('ERROR: $_error'),
          if (_bytes == null && _error == null) const Text('capturing…'),
          if (_bytes != null)
            Container(
              color: const Color(0xFFEEEEEE),
              // Show at the captured logical width for a 1:1 comparison.
              child: Image.memory(_bytes!, width: 320),
            ),
          const Divider(height: 32),
          const Text('CAPTURED (height: 140 — width grows):'),
          if (_wideBytes != null)
            // Wide capture: scroll horizontally; show at captured logical height.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                color: const Color(0xFFEEEEEE),
                child: Image.memory(_wideBytes!, height: 140),
              ),
            ),
          const Divider(height: 32),
          const Text('CAPTURED (backgroundColor: transparent):'),
          if (_transparentBytes != null)
            // Orange backdrop shows through the transparent PNG's alpha.
            Container(
              color: const Color(0xFFFF8A34),
              padding: const EdgeInsets.all(12),
              child: Image.memory(_transparentBytes!, width: 320),
            ),
        ],
      ),
    ),
  );
}
