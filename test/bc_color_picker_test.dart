import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_color_picker.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('VAL-M2-001 — controlled value and onChange meta', () {
    testWidgets('renders swatch and hex readout for controlled value', (tester) async {
      await tester.pumpWidget(harness(
        const BcColorPicker(value: '#3b82f6', name: 'color'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('#3B82F6'), findsOneWidget);

      final swatch = tester.widget<Container>(
        find.byKey(const Key('bc_color_picker_swatch')),
      );
      final boxDeco = swatch.decoration as BoxDecoration;
      expect(boxDeco.color, const Color(0xFF3B82F6));
    });

    testWidgets('tapping swatch opens platform color dialog and confirming emits meta', (tester) async {
      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcColorPicker(
          value: '#3b82f6',
          name: 'color',
          onValueChange: (v, meta) {
            capturedValue = v;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_color_picker_swatch')));
      await tester.pumpAndSettle();

      expect(capturedValue, isNotNull);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
      expect(capturedMeta!.reason, BcChangeReason.input);
    });
  });

  group('VAL-M2-002 — preset swatch click', () {
    testWidgets('renders preset chips and tapping emits preset hex with select reason', (tester) async {
      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcColorPicker(
          defaultValue: '#3b82f6',
          name: 'color',
          presets: const ['#ff0000', '#00ff00', '#0000ff'],
          onValueChange: (v, meta) {
            capturedValue = v;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_color_preset_#00ff00')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc_color_preset_#00ff00')));
      await tester.pumpAndSettle();

      expect(capturedValue, '#00ff00');
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);

      final swatch = tester.widget<Container>(
        find.byKey(const Key('bc_color_picker_swatch')),
      );
      final boxDeco = swatch.decoration as BoxDecoration;
      expect(boxDeco.color, const Color(0xFF00FF00));
    });
  });

  group('VAL-M2-003 — disabled state', () {
    testWidgets('disabled ignores interaction and renders dimmed', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcColorPicker(
          value: '#3b82f6',
          disabled: true,
          presets: const ['#ff0000', '#00ff00'],
          onValueChange: (_, __) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('#3B82F6'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc_color_picker_swatch')));
      await tester.pumpAndSettle();
      expect(callCount, 0);

      await tester.tap(find.byKey(const Key('bc_color_preset_#ff0000')));
      await tester.pumpAndSettle();
      expect(callCount, 0);

      final opacityFinder = find.descendant(
        of: find.byType(BcColorPicker),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsWidgets);
      final opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, lessThan(1.0));
    });
  });
}
