import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_range_slider.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 300, child: child))));

  group('VAL-M2-010 — both thumbs render and emit tuple on drag', () {
    testWidgets('renders slider with correct initial positions', (tester) async {
      await tester.pumpWidget(harness(
        const BcRangeSlider(
          min: 0,
          max: 100,
          value: BcRangeValue(min: 20, max: 80),
          showValues: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
    });

    testWidgets('dragging upper thumb emits updated range tuple with input meta', (tester) async {
      BcRangeValue? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcRangeSlider(
          min: 0,
          max: 100,
          step: 1,
          defaultValue: const BcRangeValue(min: 20, max: 80),
          onChange: (v, meta) {
            capturedValue = v;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(RangeSlider);
      final sliderBox = tester.getRect(sliderFinder);

      final upperThumbX = sliderBox.left + sliderBox.width * 0.8;
      final centerY = sliderBox.center.dy;

      await tester.timedDragFrom(
        Offset(upperThumbX, centerY),
        const Offset(30, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(capturedValue, isNotNull);
      expect(capturedValue!.min, 20);
      expect(capturedValue!.max, greaterThan(80));
      expect(capturedMeta!.reason, BcChangeReason.input);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });
  });

  group('VAL-M2-011 — thumbs cannot cross', () {
    testWidgets('lower thumb clamps below upper', (tester) async {
      BcRangeValue? capturedValue;

      await tester.pumpWidget(harness(
        BcRangeSlider(
          min: 0,
          max: 100,
          step: 1,
          defaultValue: const BcRangeValue(min: 40, max: 60),
          onChange: (v, _) => capturedValue = v,
        ),
      ));
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(RangeSlider);
      final sliderBox = tester.getRect(sliderFinder);

      final lowerThumbX = sliderBox.left + sliderBox.width * 0.4;
      final centerY = sliderBox.center.dy;

      await tester.timedDragFrom(
        Offset(lowerThumbX, centerY),
        const Offset(100, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(capturedValue, isNotNull);
      expect(capturedValue!.min, lessThanOrEqualTo(capturedValue!.max),
          reason: 'lo must be <= hi');
    });

    testWidgets('upper thumb clamps above lower', (tester) async {
      BcRangeValue? capturedValue;

      await tester.pumpWidget(harness(
        BcRangeSlider(
          min: 0,
          max: 100,
          step: 1,
          defaultValue: const BcRangeValue(min: 40, max: 60),
          onChange: (v, _) => capturedValue = v,
        ),
      ));
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(RangeSlider);
      final sliderBox = tester.getRect(sliderFinder);

      final upperThumbX = sliderBox.left + sliderBox.width * 0.6;
      final centerY = sliderBox.center.dy;

      await tester.timedDragFrom(
        Offset(upperThumbX, centerY),
        const Offset(-100, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(capturedValue, isNotNull);
      expect(capturedValue!.min, lessThanOrEqualTo(capturedValue!.max),
          reason: 'lo must be <= hi');
    });
  });

  group('VAL-M2-012 — disabled and showValues readout', () {
    testWidgets('showValues with unit renders both bounds', (tester) async {
      await tester.pumpWidget(harness(
        const BcRangeSlider(
          min: 0,
          max: 100,
          value: BcRangeValue(min: 20, max: 80),
          showValues: true,
          unit: 'px',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('20px'), findsOneWidget);
      expect(find.text('80px'), findsOneWidget);
    });

    testWidgets('disabled blocks both thumbs', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcRangeSlider(
          min: 0,
          max: 100,
          value: const BcRangeValue(min: 20, max: 80),
          disabled: true,
          onChange: (_, __) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      final sliderFinder = find.byType(RangeSlider);
      final sliderBox = tester.getRect(sliderFinder);

      await tester.timedDragFrom(
        Offset(sliderBox.left + sliderBox.width * 0.2, sliderBox.center.dy),
        const Offset(50, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      await tester.timedDragFrom(
        Offset(sliderBox.left + sliderBox.width * 0.8, sliderBox.center.dy),
        const Offset(-50, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
