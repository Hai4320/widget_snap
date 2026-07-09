/// Widget → PNG export, as extension methods on `Widget` — or via the
/// `WidgetSnap` facade if you prefer a named entry point:
///
/// ```dart
/// final bytes = await myWidget.toPngBytes(context);           // core
/// final path  = await myWidget.toPngFile(context, filename: 'export.png');
///
/// final bytes = await WidgetSnap.pngBytes(myWidget, context);  // same thing
/// ```
///
/// Hard boundary: this package knows nothing about the host app — no models,
/// no i18n, no state management. `toPngBytes` is the core (pure capture, no
/// IO, works on every platform including web); `toPngFile` is a thin
/// `dart:io` convenience on top (IO platforms only). The app owns everything
/// after capture — share, download, upload. Everything app-specific arrives
/// as parameters.
library;

export 'src/capture.dart';
export 'src/facade.dart';
export 'src/save.dart';
