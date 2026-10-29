import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_watermark.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: SizedBox(width: 300, height: 300, child: child)));

  group('VAL-M7-001 — BcWatermark renders overlaid text/pattern across content', () {
    testWidgets('renders child content with watermark overlay', (tester) async {
      await tester.pumpWidget(harness(
        const BcWatermark(
          text: 'CONFIDENTIAL',
          child: Text('content'),
        ),
      ));

      expect(find.byKey(const Key('bc_watermark')), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
      expect(find.byKey(const Key('bc_watermark_pattern')), findsOneWidget);
    });

    testWidgets('renders only child when text is null', (tester) async {
      await tester.pumpWidget(harness(
        const BcWatermark(
          child: Text('content'),
        ),
      ));

      expect(find.text('content'), findsOneWidget);
      expect(find.byKey(const Key('bc_watermark')), findsNothing);
      expect(find.byKey(const Key('bc_watermark_pattern')), findsNothing);
    });

    testWidgets('renders only child when text is empty', (tester) async {
      await tester.pumpWidget(harness(
        const BcWatermark(
          text: '',
          child: Text('content'),
        ),
      ));

      expect(find.text('content'), findsOneWidget);
      expect(find.byKey(const Key('bc_watermark_pattern')), findsNothing);
    });

    testWidgets('renders without child and with text', (tester) async {
      await tester.pumpWidget(harness(
        const BcWatermark(text: 'WATERMARK'),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_watermark')), findsOneWidget);
    });
  });

  group('VAL-M7-002 — BcWatermark angle and opacity are configurable', () {
    testWidgets('custom rotate and opacity update without throwing', (tester) async {
      await tester.pumpWidget(harness(
        const BcWatermark(
          text: 'DRAFT',
          rotate: -45,
          opacity: 0.5,
          child: Text('content'),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_watermark_pattern')), findsOneWidget);
    });

    testWidgets('changing rotate re-renders without error', (tester) async {
      double rotate = -22;

      await tester.pumpWidget(harness(
        BcWatermark(text: 'DRAFT', rotate: rotate, child: const Text('content')),
      ));
      await tester.pump();

      rotate = -45;
      await tester.pumpWidget(harness(
        BcWatermark(text: 'DRAFT', rotate: rotate, child: const Text('content')),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_watermark_pattern')), findsOneWidget);
    });

    testWidgets('changing opacity re-renders without error', (tester) async {
      double opacity = 0.15;

      await tester.pumpWidget(harness(
        BcWatermark(text: 'DRAFT', opacity: opacity, child: const Text('content')),
      ));
      await tester.pump();

      opacity = 0.8;
      await tester.pumpWidget(harness(
        BcWatermark(text: 'DRAFT', opacity: opacity, child: const Text('content')),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_watermark_pattern')), findsOneWidget);
    });
  });
}
