import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter_example/sections/block_catalog_section.dart';

import 'helpers/fake_webview_platform.dart';

/// Regression guard for the Block Catalog demo section.
///
/// This section was the only demo section without test coverage, and it was
/// exactly where two renderer bugs surfaced as red blocks and yellow overflow
/// bars:
///
///   1. `TypeError: "2026-06-18": type 'String' is not a subtype of
///      type 'DateTime?'` — the schema supplies `'orderDate': '2026-06-18'`
///      (a JSON date string, per the shared schema contract) while the field
///      builder hard-cast to `DateTime?`.
///   2. `A RenderFlex overflowed` — `grid(2)` held two `detail` blocks whose
///      content was taller than the fixed `childAspectRatio: 3.0` cell.
///
/// Both are fixed at the renderer seam; this test fails if either returns.
void main() {
  setUpAll(installFakeWebViewPlatform);

  testWidgets('Block Catalog section renders without ErrorWidget',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: BlockCatalogSection()),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.byType(ErrorWidget),
      findsNothing,
      reason: 'Block Catalog section rendered an ErrorWidget (crash)',
    );
  });

  testWidgets('Block Catalog section raises no TypeError from JSON values',
      (tester) async {
    final errors = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details.exceptionAsString());

    tester.view.physicalSize = const Size(1280, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: BlockCatalogSection()),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } finally {
      FlutterError.onError = original;
    }

    final typeErrors = errors
        .where((e) => e.contains('is not a subtype of type'))
        .toList();
    expect(typeErrors, isEmpty,
        reason: 'Field builder hard-cast a JSON value: $typeErrors');
  });

  testWidgets('Block Catalog grid does not overflow', (tester) async {
    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) overflows.add(text);
    };

    tester.view.physicalSize = const Size(1280, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: BlockCatalogSection()),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } finally {
      FlutterError.onError = original;
    }

    expect(overflows, isEmpty, reason: 'Layout overflowed: $overflows');
  });

  testWidgets('Sales Order values render into the detail fields',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: BlockCatalogSection()),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Values supplied as JSON scalars must survive coercion into the widgets.
    expect(find.text('Sarah Chen'), findsWidgets);
    expect(find.text('2026-06-18'), findsWidgets);
    expect(find.text('SO-2026-0481'), findsWidgets);
  });
}
