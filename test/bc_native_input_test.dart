import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_input.dart';
import 'package:bc_ui_flutter/src/components/bc_native_input.dart';

void main() {
  group('BcNativeInput (typedef alias to BcInput)', () {
    Widget buildHarness({
      String? value,
      String? defaultValue,
      String? placeholder,
      String? label,
      bool disabled = false,
      bool obscureText = false,
      BcChangeHandler<String>? onValueChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcNativeInput(
            value: value,
            defaultValue: defaultValue,
            placeholder: placeholder,
            label: label,
            disabled: disabled,
            obscureText: obscureText,
            onValueChange: onValueChange,
          ),
        ),
      );
    }

    testWidgets('typedef resolves to BcInput (VAL-G-009)', (tester) async {
      await tester.pumpWidget(buildHarness(placeholder: 'Test'));
      await tester.pumpAndSettle();
      expect(find.byType(BcInput), findsOneWidget);
    });

    testWidgets('renders label and placeholder (VAL-G-010)', (tester) async {
      await tester.pumpWidget(buildHarness(
        label: 'Username',
        placeholder: 'Enter name',
      ));
      await tester.pumpAndSettle();
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('onValueChange fires with meta on input (VAL-G-011)',
        (tester) async {
      BcChangeMeta? meta;
      String? captured;
      await tester.pumpWidget(buildHarness(
        onValueChange: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(BcInput), 'hello');
      await tester.pumpAndSettle();

      expect(captured, 'hello');
      expect(meta, isNotNull);
      expect(meta!.reason, BcChangeReason.input);
    });

    testWidgets('disabled input cannot be edited (VAL-G-012)', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(buildHarness(
        disabled: true,
        onValueChange: (_, __) => callCount++,
      ));
      await tester.pumpAndSettle();

      // Disabled TextField has onChanged as null, so typing won't fire.
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('controlled value syncs into the field (VAL-G-013)',
        (tester) async {
      await tester.pumpWidget(buildHarness(value: 'preset'));
      await tester.pumpAndSettle();
      final controller = tester.widget<TextField>(
        find.byType(TextField),
      ).controller;
      expect(controller?.text, 'preset');
    });
  });
}
