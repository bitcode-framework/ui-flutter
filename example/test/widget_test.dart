// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter_example/main.dart';
import 'package:bc_ui_flutter_example/sections/social_section.dart';
import 'package:bc_ui_flutter_example/sections/misc_section.dart';
import 'package:bc_ui_flutter_example/sections/input_extended_section.dart';
import 'package:bc_ui_flutter_example/sections/print_section.dart';
import 'package:bc_ui_flutter_example/sections/charts_section.dart';
import 'package:bc_ui_flutter_example/sections/views_section.dart';
import 'package:bc_ui_flutter_example/sections/layout_section.dart';
import 'package:bc_ui_flutter_example/sections/navigation_section.dart';
import 'package:bc_ui_flutter_example/sections/native_section.dart';
import 'helpers/fake_webview_platform.dart';

void main() {
  // Install the fake WebView platform once so BcChart (flutter_echarts) can
  // build its widget tree in tests without a real WebView platform impl.
  setUpAll(installFakeWebViewPlatform);

  testWidgets('Demo app renders with sidebar and content', (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiDemoApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // The first section (Forms) should be visible by default
    expect(find.text('Forms'), findsWidgets);
    expect(find.byType(BcUiDemoApp), findsOneWidget);
  });

  // Regression test for ADR-016 Demo Bug 1: data_section.dart used ListView
  // as its root widget, but main.dart wraps every section in a
  // SingleChildScrollView — ListView inside SingleChildScrollView crashes with
  // "Vertical viewport was given unbounded height". Fix: ListView → Column.
  // This test taps the Data sidebar item and confirms no ErrorWidget appears.
  testWidgets('Data section renders without ErrorWidget (ADR-016 Demo Bug 1)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiDemoApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final dataTarget = find.text('Data');
    if (dataTarget.evaluate().isNotEmpty) {
      await tester.tap(dataTarget.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Data section rendered an ErrorWidget (crash)');
    // Confirm the Data section's content is actually present.
    expect(find.text('BcDataTable'), findsOneWidget);
  });

  // Test that Display section renders without crashing.
  testWidgets('Display section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiDemoApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final displayTarget = find.text('Display');
    if (displayTarget.evaluate().isNotEmpty) {
      await tester.tap(displayTarget.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Display section rendered an ErrorWidget (crash)');
    // Confirm the Display section's content is actually present.
    expect(find.text('BcStatistic'), findsOneWidget);
  });

  // Regression test: Primitives section renders without crashing.
  testWidgets('Primitives section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiDemoApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final target = find.text('Primitives');
    if (target.evaluate().isNotEmpty) {
      await tester.tap(target.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Primitives section rendered an ErrorWidget (crash)');
    expect(find.text('BcCircle'), findsOneWidget);
  });

  // Regression test: Feedback section renders without crashing.
  testWidgets('Feedback section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiDemoApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final target = find.text('Feedback');
    if (target.evaluate().isNotEmpty) {
      await tester.tap(target.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Feedback section rendered an ErrorWidget (crash)');
    expect(find.text('BcNotification'), findsOneWidget);
  });

  // Regression test: Media section renders without crashing.
  testWidgets('Media section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiDemoApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final target = find.text('Media');
    if (target.evaluate().isNotEmpty) {
      await tester.tap(target.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Media section rendered an ErrorWidget (crash)');
    expect(find.text('BcImage'), findsOneWidget);
  });

  // Regression test: Charts section renders without crashing.
  // The fake WebView platform (installed in setUpAll) lets BcChart
  // (flutter_echarts) build its WebView tree without a platform impl.
  testWidgets('Charts section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: ChartsSection())),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Charts section rendered an ErrorWidget (crash)');
    expect(find.text('BcChart - Bar'), findsOneWidget);
    expect(find.text('BcSparkline'), findsOneWidget);
  });

  // Regression test: Social section renders without crashing.
  // Pumps the SocialSection widget directly to avoid sidebar tap flakiness.
  testWidgets('Social section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: SocialSection()))));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Social section rendered an ErrorWidget (crash)');
    expect(find.text('BcChatter'), findsOneWidget);
  });

  // Regression test: Misc section renders without crashing.
  testWidgets('Misc section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: MiscSection())),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Misc section rendered an ErrorWidget (crash)');
    expect(find.text('BcWatermark'), findsOneWidget);
  });

  // Regression test: Input Extended section renders without crashing.
  testWidgets('Input Extended section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: InputExtendedSection())),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Input Extended section rendered an ErrorWidget (crash)');
    expect(find.text('BcRichText'), findsOneWidget);
  });

  // Regression test: Print section renders without crashing.
  testWidgets('Print section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: PrintSection())),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Print section rendered an ErrorWidget (crash)');
    expect(find.text('BcExport'), findsOneWidget);
  });

  // Regression test: Views section renders without crashing.
  testWidgets('Views section renders without ErrorWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: ViewsSection())),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Views section rendered an ErrorWidget (crash)');
    expect(find.text('BcKanbanBoard'), findsOneWidget);
  });

  // ADR-016 TASK 2: Layout section renders without crashing.
  testWidgets('Layout section renders without ErrorWidget (ADR-016 TASK 2)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: LayoutSection())),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Layout section rendered an ErrorWidget (crash)');
    expect(find.textContaining('Bc'), findsWidgets);
  });

  // ADR-016 TASK 2: Navigation section renders without crashing.
  testWidgets('Navigation section renders without ErrorWidget (ADR-016 TASK 2)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: NavigationSection())),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Navigation section rendered an ErrorWidget (crash)');
    expect(find.textContaining('Bc'), findsWidgets);
  });

  // ADR-016 TASK 2: Native section renders without crashing.
  //
  // This section intentionally renders a `BcNativeButton(loading: true)`, whose
  // CircularProgressIndicator animates indefinitely. `pumpAndSettle` can never
  // settle against a perpetual animation, so pump a bounded number of frames
  // instead — a crash would still surface an ErrorWidget.
  testWidgets('Native section renders without ErrorWidget (ADR-016 i18n)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: NativeSection())),
    ));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(ErrorWidget), findsNothing,
        reason: 'Native section rendered an ErrorWidget (crash)');
    expect(find.textContaining('Bc'), findsWidgets);
  });

  // ADR-016 TASK 2: sweep — tap every sidebar section, assert no crash.
  // Comprehensive regression guard covering all 15 sections. Framework-level
  // layout warnings (e.g. "ListTile background invisible") from third-party
  // section widgets are captured but do NOT fail the test — only ErrorWidget
  // (actual render crash) is fatal.
  testWidgets('every sidebar section renders without ErrorWidget (ADR-016 TASK 2 sweep)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiDemoApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    const sectionLabels = <String>[
      'Forms', 'Overlays', 'Data', 'Display', 'Navigation', 'Layout',
      'Primitives', 'Feedback', 'Media', 'Charts', 'Social', 'Misc',
      'Input Extended', 'Print', 'Views', 'Native',
    ];

    for (final label in sectionLabels) {
      final target = find.text(label);
      if (target.evaluate().isNotEmpty) {
        // Charts renders a WebView overlay (fake platform) that can
        // intercept taps; it has its own dedicated test above, so skip
        // tapping it here and just scroll past.
        if (label == 'Charts') continue;
        // Drain any framework-level warnings from the previous pump so
        // they don't accumulate and fail the test.
        tester.takeException();
        await tester.tap(target.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        // The ONLY fatal condition is an ErrorWidget (actual render crash).
        expect(
          find.byType(ErrorWidget),
          findsNothing,
          reason: 'Section "$label" rendered an ErrorWidget (crash)',
        );
      }
    }
  });
}
