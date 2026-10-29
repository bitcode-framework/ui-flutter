import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_select.dart';

void main() {
  testWidgets('BcSelect renders with selected value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BcSelect<String>(
            value: 'apple',
            options: [
              BcSelectOption(value: 'apple', label: 'Apple'),
              BcSelectOption(value: 'banana', label: 'Banana'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('BcSelect shows placeholder when no value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BcSelect<String>(
            placeholder: 'Pick a fruit',
            options: [
              BcSelectOption(value: 'apple', label: 'Apple'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Pick a fruit'), findsOneWidget);
  });
}
