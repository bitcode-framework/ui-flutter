import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_native_picker.dart';

void main() {
  group('BcNativePicker', () {
    const options = [
      BcNativePickerOption(label: 'Apple', value: 'a'),
      BcNativePickerOption(label: 'Banana', value: 'b'),
      BcNativePickerOption(label: 'Cherry', value: 'c'),
    ];

    Widget buildHarness({Widget? child}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
    }

    testWidgets('show() returns the selected value when an option is tapped '
        '(VAL-G-028)', (tester) async {
      String? result;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await BcNativePicker.show(
                  context: context,
                  options: options,
                  value: 'b',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // On Android (default test platform), a dialog with the list renders.
      expect(find.byKey(const Key('bc-native-picker-dialog')),
          findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);

      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();

      expect(result, 'c');
    });

    testWidgets('show() returns null when cancelled (VAL-G-029)',
        (tester) async {
      String? result = 'sentinel';
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await BcNativePicker.show(
                  context: context,
                  options: options,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-native-picker-cancel')));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('show() renders all option labels (VAL-G-030)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativePicker.show(
                context: context,
                options: options,
                title: 'Fruit',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Fruit'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('show() marks the current value with a check (VAL-G-031)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativePicker.show(
                context: context,
                options: options,
                value: 'b',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The check icon appears next to the selected option.
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('empty options list does not crash (VAL-G-032)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativePicker.show(
                context: context,
                options: const [],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-picker-dialog')),
          findsOneWidget);
    });
  });
}
