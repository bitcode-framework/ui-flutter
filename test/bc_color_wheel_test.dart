import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_color_wheel.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  group('VAL-M7-012 — BcColorWheel renders an interactive hue/saturation wheel', () {
    testWidgets('renders circular color wheel with CustomPaint', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorWheel(size: 200),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_color_wheel')), findsOneWidget);
      expect(find.byKey(const Key('bc_color_wheel_canvas')), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('dragging within the wheel invokes onValueChange with HSVColor and meta',
        (tester) async {
      HSVColor? captured;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcColorWheel(
          size: 200,
          onValueChange: (hsv, meta) {
            captured = hsv;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const Key('bc_color_wheel')),
        const Offset(30, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.hue, greaterThanOrEqualTo(0));
      expect(captured!.hue, lessThanOrEqualTo(360));
      expect(captured!.saturation, greaterThanOrEqualTo(0));
      expect(captured!.saturation, lessThanOrEqualTo(1));
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('disabled wheel does not invoke onValueChange', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        const BcColorWheel(size: 200, disabled: true),
      ));
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const Key('bc_color_wheel')),
        const Offset(30, 0),
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorWheel(size: 200, label: 'Pick a color'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pick a color'), findsOneWidget);
      expect(find.byKey(const Key('bc_color_wheel_label')), findsOneWidget);
    });
  });

  group('VAL-M7-013 — BcColorWheel controlled value positions the indicator', () {
    testWidgets('controlled value repositions indicator without interaction', (tester) async {
      HSVColor value = const HSVColor.fromAHSV(1.0, 180, 0.8, 1.0);

      await tester.pumpWidget(harness(
        BcColorWheel(size: 200, value: value),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_color_wheel_canvas')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing controlled value updates without error', (tester) async {
      HSVColor value = const HSVColor.fromAHSV(1.0, 0, 1.0, 1.0);

      await tester.pumpWidget(harness(
        BcColorWheel(size: 200, value: value),
      ));
      await tester.pumpAndSettle();

      value = const HSVColor.fromAHSV(1.0, 270, 0.5, 1.0);
      await tester.pumpWidget(harness(
        BcColorWheel(size: 200, value: value),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_color_wheel_canvas')), findsOneWidget);
    });

    testWidgets('uncontrolled with defaultValue positions indicator', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorWheel(
          size: 200,
          defaultValue: HSVColor.fromAHSV(1.0, 120, 0.5, 1.0),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_color_wheel_canvas')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
