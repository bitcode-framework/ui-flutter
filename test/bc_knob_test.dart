import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_knob.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcKnob child}) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  group('BcKnob — VAL-M2-040', () {
    testWidgets('Dragging the knob emits a clamped value in [min, max]', (tester) async {
      double? emittedValue;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcKnob(
          min: 0,
          max: 100,
          value: 50,
          onChange: (v, m) {
            emittedValue = v;
            meta = m;
          },
        ),
      ));

      await tester.timedDrag(
        find.byKey(const Key('bc_knob_gesture')),
        const Offset(60, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(emittedValue, isNotNull);
      expect(emittedValue!, greaterThanOrEqualTo(0));
      expect(emittedValue!, lessThanOrEqualTo(100));
      expect(meta!.reason, BcChangeReason.input);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('Clamps to max when dragging beyond max arc', (tester) async {
      double? emittedValue;

      await tester.pumpWidget(harness(
        child: BcKnob(
          min: 0,
          max: 100,
          value: 50,
          onChange: (v, _) => emittedValue = v,
        ),
      ));

      await tester.timedDrag(
        find.byKey(const Key('bc_knob_gesture')),
        const Offset(500, -500),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(emittedValue, lessThanOrEqualTo(100));
      expect(emittedValue, greaterThanOrEqualTo(0));
    });
  });

  group('BcKnob — VAL-M2-041', () {
    testWidgets('Disabled knob ignores drag', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        child: BcKnob(
          min: 0,
          max: 100,
          value: 50,
          disabled: true,
          onChange: (_, __) => callCount++,
        ),
      ));

      await tester.timedDrag(
        find.byKey(const Key('bc_knob_gesture')),
        const Offset(60, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('Size sets dial diameter and label renders', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKnob(
          min: 0,
          max: 100,
          value: 50,
          size: 120,
          label: 'Volume',
        ),
      ));

      expect(find.text('50'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);

      final container = tester.getSize(find.byKey(const Key('bc_knob_gesture')));
      expect(container.width, closeTo(120, 1));
      expect(container.height, closeTo(120, 1));
    });

    testWidgets('Controlled value outside [min, max] clamps for angle', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKnob(
          min: 0,
          max: 100,
          value: 250,
          size: 100,
        ),
      ));

      expect(find.text('100'), findsOneWidget);
    });
  });
}
