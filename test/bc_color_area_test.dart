import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_color_area.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-042 — dragging SV area emits saturation + value with meta', () {
    testWidgets('dragging within the 2D area emits SV pair with input reason and pointer source',
        (tester) async {
      BcSvValue? captured;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcColorArea(
          hue: 210,
          width: 200,
          height: 200,
          onChange: (sv, meta) {
            captured = sv;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Drag from center to bottom-right
      await tester.timedDrag(
        find.byKey(const Key('bc_color_area')),
        const Offset(50, 50),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.saturation, greaterThanOrEqualTo(0));
      expect(captured!.saturation, lessThanOrEqualTo(100));
      expect(captured!.value, greaterThanOrEqualTo(0));
      expect(captured!.value, lessThanOrEqualTo(100));
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.input);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('horizontal axis maps to saturation 0-100', (tester) async {
      BcSvValue? captured;

      await tester.pumpWidget(harness(
        BcColorArea(
          hue: 0,
          width: 200,
          height: 200,
          onChange: (sv, meta) {
            captured = sv;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Drag from left to right to verify saturation increases
      await tester.timedDragFrom(
        tester.getCenter(find.byKey(const Key('bc_color_area'))) + const Offset(-80, 0),
        const Offset(160, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.saturation, greaterThan(50));
    });
  });

  group('VAL-M2-043 — disabled area ignores drag and clamps pointer to bounds', () {
    testWidgets('disabled area ignores drag and onChange never fires', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcColorArea(
          hue: 210,
          disabled: true,
          onChange: (sv, meta) {
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const Key('bc_color_area')),
        const Offset(50, 50),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('pointer dragged outside area bounds clamps to nearest edge',
        (tester) async {
      List<BcSvValue> captured = [];

      await tester.pumpWidget(harness(
        BcColorArea(
          hue: 0,
          width: 200,
          height: 200,
          onChange: (sv, meta) {
            captured.add(sv);
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Drag far beyond the right edge (saturation should clamp to 100)
      await tester.timedDragFrom(
        tester.getCenter(find.byKey(const Key('bc_color_area'))),
        const Offset(500, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotEmpty);
      expect(captured.last.saturation, lessThanOrEqualTo(100));
    });
  });
}
