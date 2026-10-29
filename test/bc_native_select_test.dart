import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_select.dart';
import 'package:bc_ui_flutter/src/components/bc_native_select.dart';

void main() {
  group('BcNativeSelect (typedef alias to BcSelect)', () {
    const options = <BcSelectOption<String>>[
      BcSelectOption(value: 'a', label: 'Apple'),
      BcSelectOption(value: 'b', label: 'Banana'),
      BcSelectOption(value: 'c', label: 'Cherry'),
    ];

    Widget buildHarness({
      String? value,
      String? defaultValue,
      List<BcSelectOption<String>> opts = options,
      bool disabled = false,
      String? placeholder,
      BcChangeHandler<String>? onValueChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcSelect<String>(
              value: value,
              defaultValue: defaultValue,
              options: opts,
              disabled: disabled,
              placeholder: placeholder,
              onValueChange: onValueChange,
            ),
          ),
        ),
      );
    }

    testWidgets('typedef resolves to BcSelect (VAL-G-014)', (tester) async {
      // BcNativeSelect is a typedef of BcSelect; verify the type alias exists
      // and BcSelect renders.
      expect(BcNativeSelect, equals(BcSelect));
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byType(BcSelect<String>), findsOneWidget);
    });

    testWidgets('renders the selected option label (VAL-G-015)',
        (tester) async {
      await tester.pumpWidget(buildHarness(value: 'b'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('renders placeholder when nothing selected (VAL-G-016)',
        (tester) async {
      await tester.pumpWidget(buildHarness(placeholder: 'Pick one'));
      await tester.pumpAndSettle();
      expect(find.text('Pick one'), findsOneWidget);
    });

    testWidgets('select renders without error (VAL-G-017)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byType(BcSelect<String>), findsOneWidget);
    });

    testWidgets('disabled select renders (VAL-G-018)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        disabled: true,
        placeholder: 'Locked',
      ));
      await tester.pumpAndSettle();
      expect(find.text('Locked'), findsOneWidget);
    });
  });
}
