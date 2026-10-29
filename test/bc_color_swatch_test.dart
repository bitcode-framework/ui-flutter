import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_color_swatch.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M7-010 — BcColorSwatch renders a grid of selectable color chips', () {
    testWidgets('renders N color chips from colors list', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorSwatch(
          colors: ['#FF0000', '#00FF00', '#0000FF'],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_color_swatch')), findsOneWidget);
      expect(find.byKey(const Key('bc_color_swatch_chip_0')), findsOneWidget);
      expect(find.byKey(const Key('bc_color_swatch_chip_1')), findsOneWidget);
      expect(find.byKey(const Key('bc_color_swatch_chip_2')), findsOneWidget);
    });

    testWidgets('tapping a chip selects it and invokes onValueChange with meta', (tester) async {
      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcColorSwatch(
          colors: const ['#FF0000', '#00FF00'],
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_color_swatch_chip_1')));
      await tester.pumpAndSettle();

      expect(capturedValue, '#00FF00');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('selected chip shows checkmark indicator', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorSwatch(
          colors: ['#FF0000', '#00FF00'],
          defaultValue: '#FF0000',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('controlled value shows selected state', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorSwatch(
          colors: ['#FF0000', '#00FF00', '#0000FF'],
          value: '#0000FF',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('VAL-M7-011 — BcColorSwatch disabled state prevents selection', () {
    testWidgets('disabled prevents onValueChange from firing', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        const BcColorSwatch(
          colors: ['#FF0000', '#00FF00'],
          disabled: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_color_swatch_chip_0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_color_swatch_chip_1')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('disabled renders with muted visual state', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorSwatch(
          colors: ['#FF0000'],
          disabled: true,
        ),
      ));
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.4);
    });

    testWidgets('disabled with onValueChange does not fire', (tester) async {
      String? capturedValue;

      await tester.pumpWidget(harness(
        const BcColorSwatch(
          colors: ['#FF0000', '#00FF00'],
          disabled: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_color_swatch_chip_0')));
      await tester.pumpAndSettle();

      expect(capturedValue, isNull);
    });
  });
}
