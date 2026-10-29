import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_checkbox.dart';

void main() {
  testWidgets('BcCheckbox toggles on tap', (tester) async {
    bool? checked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcCheckbox(
            value: false,
            onValueChange: (v, _) => checked = v,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BcCheckbox));
    await tester.pump();
    expect(checked, true);
  });

  testWidgets('BcCheckbox disabled does not toggle', (tester) async {
    var toggled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcCheckbox(
            value: false,
            disabled: true,
            onValueChange: (v, _) => toggled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BcCheckbox));
    await tester.pump();
    expect(toggled, isFalse);
  });

  testWidgets('BcCheckbox shows label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BcCheckbox(value: false, label: 'Accept terms'),
        ),
      ),
    );

    expect(find.text('Accept terms'), findsOneWidget);
  });
}
