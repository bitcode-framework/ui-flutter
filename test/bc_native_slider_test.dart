import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_slider.dart';
import 'package:bc_ui_flutter/src/components/bc_native_slider.dart';

void main() {
  group('BcNativeSlider (typedef alias to BcSlider)', () {
    Widget buildHarness({
      double? value,
      double? defaultValue,
      double min = 0,
      double max = 100,
      double step = 1,
      bool disabled = false,
      bool showValue = false,
      String? label,
      BcChangeHandler<double>? onChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcNativeSlider(
              value: value,
              defaultValue: defaultValue,
              min: min,
              max: max,
              step: step,
              disabled: disabled,
              showValue: showValue,
              label: label,
              onChange: onChange,
            ),
          ),
        ),
      );
    }

    testWidgets('typedef resolves to BcSlider (VAL-G-023)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byType(BcSlider), findsOneWidget);
    });

    testWidgets('renders the Slider widget (VAL-G-024)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc_slider')), findsOneWidget);
    });

    testWidgets('renders label + value when showValue (VAL-G-025)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        value: 42,
        label: 'Volume',
        showValue: true,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('onChange fires with meta when dragged (VAL-G-026)',
        (tester) async {
      double? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        value: 50,
        onChange: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();

      // Simulate a drag on the slider thumb.
      final center = tester.getCenter(find.byKey(const Key('bc_slider')));
      await tester.timedDrag(
        find.byKey(const Key('bc_slider')),
        const Offset(40, 0),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();
      expect(center, isNotNull);
      expect(meta, isNotNull);
      expect(meta!.reason, BcChangeReason.input);
    });

    testWidgets('disabled slider ignores input (VAL-G-027)', (tester) async {
      await tester.pumpWidget(buildHarness(disabled: true, value: 30));
      await tester.pumpAndSettle();
      final slider = tester.widget<Slider>(find.byKey(const Key('bc_slider')));
      expect(slider.onChanged, isNull);
    });
  });
}
