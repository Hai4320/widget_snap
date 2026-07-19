// toPngFile is IO-only (the web stub throws UnsupportedError for
// everything), so this file runs on the VM only — it is deliberately not in
// the `make test-web` target.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_snap/widget_snap.dart';

void main() {
  testWidgets('toPngFile rejects a filename with path separators', (
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

    await expectLater(
      const SizedBox(
        width: 10,
        height: 10,
      ).toPngFile(ctx, filename: 'nested/dir.png'),
      throwsArgumentError,
    );
    await expectLater(
      const SizedBox(
        width: 10,
        height: 10,
      ).toPngFile(ctx, filename: r'nested\dir.png'),
      throwsArgumentError,
    );
  });
}
