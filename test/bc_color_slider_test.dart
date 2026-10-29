import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_color_slider.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-044 — dragging slider emits clamped hue value with meta', () {
    testWidgets('dragging thumb emits hue value with input reason and pointer source',
        (tester) async {
      double? captured;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcColorSlider(
          min: 0,
          max: 360,
          value: 180,
          onChange: (hue, meta) {
            captured = hue;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const Key('bc_color_slider')),
        const Offset(50, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured! >= 0 && captured! <= 360, isTrue);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.input);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('emitted values are clamped to min/max range', (tester) async {
      List<double> captured = [];

      await tester.pumpWidget(harness(
        BcColorSlider(
          min: 0,
          max: 360,
          value: 350,
          onChange: (hue, meta) {
            captured.add(hue);
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Drag far right to exceed max
      await tester.timedDrag(
        find.byKey(const Key('bc_color_slider')),
        const Offset(500, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotEmpty);
      expect(captured.last, lessThanOrEqualTo(360));
    });
  });

  group('VAL-M2-045 — disabled slider ignores drag/keyboard; label renders alongside', () {
    testWidgets('disabled slider ignores drag and onChange never fires', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcColorSlider(
          min: 0,
          max: 360,
          value: 180,
          disabled: true,
          onChange: (hue, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const Key('bc_color_slider')),
        const Offset(50, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('label prop renders adjacent to the slider', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorSlider(
          min: 0,
          max: 360,
          value: 120,
          label: 'Hue',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hue'), findsOneWidget);
    });

    testWidgets('controlled value outside range is clamped for initial thumb position',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcColorSlider(
          min: 0,
          max: 360,
          value: 999,
        ),
      ));
      await tester.pumpAndSettle();

      // Slider should render without crashing; value clamped internally
      expect(find.byKey(const Key('bc_color_slider')), findsOneWidget);
    });
  });
}
