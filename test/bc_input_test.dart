import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_input.dart';

void main() {
  testWidgets('BcInput renders and accepts text', (tester) async {
    String? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcInput(
            placeholder: 'Enter name',
            onValueChange: (value, _) => changed = value,
          ),
        ),
      ),
    );

    expect(find.text('Enter name'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'John');
    await tester.pump();
    expect(changed, 'John');
  });

  testWidgets('BcInput disabled does not accept input', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BcInput(
            disabled: true,
            placeholder: 'Locked',
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);
  });

  testWidgets('BcInput shows label and error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BcInput(
            label: 'Email',
            errorText: 'Invalid email',
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Invalid email'), findsOneWidget);
  });
}
