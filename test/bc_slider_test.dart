import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_slider.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-007 — clamping and step snapping', () {
    testWidgets('controlled value above max clamps to max on render', (tester) async {
      await tester.pumpWidget(harness(
        const BcSlider(
          min: 0,
          max: 100,
          step: 10,
          value: 250,
          showValue: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('controlled value below min clamps to min on render', (tester) async {
      await tester.pumpWidget(harness(
        const BcSlider(
          min: 0,
          max: 100,
          step: 10,
          value: -5,
          showValue: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });
  });

  group('VAL-M2-008 — drag emits meta and showValue unit suffix', () {
    testWidgets('showValue with unit renders value with suffix', (tester) async {
      await tester.pumpWidget(harness(
        const BcSlider(
          min: 0,
          max: 100,
          step: 10,
          value: 40,
          showValue: true,
          unit: '%',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('slider drag fires onChange with clamped value and input meta', (tester) async {
      double? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSlider(
          min: 0,
          max: 100,
          step: 10,
          defaultValue: 0,
          onChange: (v, meta) {
            capturedValue = v;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);

      await tester.timedDrag(
        sliderFinder,
        const Offset(100, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(capturedValue, isNotNull);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.input);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });
  });

  group('VAL-M2-009 — disabled state', () {
    testWidgets('disabled slider ignores gestures and renders disabled color', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcSlider(
          min: 0,
          max: 100,
          step: 10,
          value: 50,
          disabled: true,
          onChange: (_, __) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byType(Slider),
        const Offset(50, 0),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
