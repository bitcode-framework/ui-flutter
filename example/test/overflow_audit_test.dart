import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter_example/main.dart';

import 'helpers/fake_webview_platform.dart';

/// Audits every sidebar section for layout overflows.
///
/// The existing sweep in `widget_test.dart` only fails on `ErrorWidget`, so a
/// yellow/black overflow bar can ship unnoticed. Overflows are reported through
/// `FlutterError.onError`, not thrown, so they need explicit capture.
///
/// Run with: flutter test test/overflow_audit_test.dart
void main() {
  setUpAll(installFakeWebViewPlatform);

  const sections = <String>[
    'Forms', 'Overlays', 'Data', 'Display', 'Navigation', 'Layout',
    'Primitives', 'Feedback', 'Media', 'Social', 'Misc',
    'Input Extended', 'Print', 'Views', 'Native', 'Block Catalog', 'Builders',
  ];

  Future<void> audit(WidgetTester tester, Size surface) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) overflows.add(text);
    };

    try {
      await tester.pumpWidget(const BcUiDemoApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      for (final label in sections) {
        overflows.clear();
        final target = find.text(label);
        if (target.evaluate().isEmpty) continue;

        await tester.tap(target.first, warnIfMissed: false);
        // Bounded pump: some sections hold perpetual animations.
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        if (overflows.isNotEmpty) {
          // ignore: avoid_print
          print('OVERFLOW [$surface] "$label": '
              '${overflows.first.split('\n').first}');
        }
        expect(
          overflows,
          isEmpty,
          reason: 'Section "$label" overflowed at $surface: '
              '${overflows.join(" | ")}',
        );
      }
    } finally {
      FlutterError.onError = original;
    }
  }

  testWidgets('no section overflows at desktop width', (tester) async {
    await audit(tester, const Size(1400, 1000));
  });

  testWidgets('no section overflows at laptop width', (tester) async {
    await audit(tester, const Size(1024, 900));
  });

  testWidgets('no section overflows at tablet width', (tester) async {
    await audit(tester, const Size(800, 900));
  });

  testWidgets('no section overflows at narrow width', (tester) async {
    await audit(tester, const Size(600, 900));
  });
}
