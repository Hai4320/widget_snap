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
  Uint8List? _bytes;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final b = await _content().toPngBytes(context, width: 320);
        if (mounted) setState(() => _bytes = b);
      } catch (e) {
        if (mounted) setState(() => _error = e);
      }
    });
  }

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
          const Text('CAPTURED:'),
          if (_error != null) Text('ERROR: $_error'),
          if (_bytes == null && _error == null) const Text('capturing…'),
          if (_bytes != null)
            Container(
              color: const Color(0xFFEEEEEE),
              // Show at the captured logical width for a 1:1 comparison.
              child: Image.memory(_bytes!, width: 320),
            ),
        ],
      ),
    ),
  );
}
