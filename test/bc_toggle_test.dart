import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_toggle.dart';

void main() {
  testWidgets('BcToggle renders with label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BcToggle(value: false, label: 'Notifications'),
        ),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('BcToggle toggles on tap', (tester) async {
    bool? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcToggle(
            value: false,
            onValueChange: (v, _) => value = v,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value, true);
  });
}
