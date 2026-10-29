import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_accordion.dart';

void main() {
  testWidgets('BcAccordion renders all items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BcAccordion(
              items: [
                BcAccordionItem(title: 'Section 1', child: Text('Content 1')),
                BcAccordionItem(title: 'Section 2', child: Text('Content 2')),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Section 1'), findsOneWidget);
    expect(find.text('Section 2'), findsOneWidget);
  });

  testWidgets('BcAccordion expands on tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BcAccordion(
              items: [
                BcAccordionItem(title: 'Expandable', child: Text('Hidden content')),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hidden content'), findsNothing);
    await tester.tap(find.text('Expandable'));
    await tester.pumpAndSettle();
    expect(find.text('Hidden content'), findsOneWidget);
  });
}
