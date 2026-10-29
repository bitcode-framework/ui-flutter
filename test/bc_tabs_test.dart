import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_tabs.dart';

void main() {
  testWidgets('BcTabs renders all tab labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BcTabs(
            tabs: [
              BcTabItem(label: 'Tab 1', child: Text('Content 1')),
              BcTabItem(label: 'Tab 2', child: Text('Content 2')),
              BcTabItem(label: 'Tab 3', child: Text('Content 3')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsOneWidget);
    expect(find.text('Tab 3'), findsOneWidget);
  });

  testWidgets('BcTabs switches content on tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: BcTabs(
              tabs: [
                BcTabItem(label: 'First', child: Text('First content')),
                BcTabItem(label: 'Second', child: Text('Second content')),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('First content'), findsOneWidget);
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(find.text('Second content'), findsOneWidget);
  });
}
