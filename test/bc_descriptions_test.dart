import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_descriptions.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  testWidgets(
      'BcDescriptions renders label/value pairs from data '
      '(VAL-M1-028)', (tester) async {
    await tester.pumpWidget(harness(
      const BcDescriptions(
        data: {'Name': 'Alice', 'Age': '30'},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Name'), findsOneWidget,
        reason: 'label "Name" should render');
    expect(find.text('Alice'), findsOneWidget,
        reason: 'value "Alice" should render');
    expect(find.text('Age'), findsOneWidget,
        reason: 'label "Age" should render');
    expect(find.text('30'), findsOneWidget,
        reason: 'value "30" should render');
  });

  testWidgets('BcDescriptions updates when data changes (VAL-M1-029)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcDescriptions(
        data: {'Name': 'Alice', 'Age': '30'},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('City'), findsNothing);

    await tester.pumpWidget(harness(
      const BcDescriptions(
        data: {'Name': 'Bob', 'City': 'NYC'},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bob'), findsOneWidget,
        reason: 'updated value should render');
    expect(find.text('Alice'), findsNothing,
        reason: 'old value should be removed');
    expect(find.text('City'), findsOneWidget,
        reason: 'new key should appear');
    expect(find.text('NYC'), findsOneWidget);
    expect(find.text('Age'), findsNothing,
        reason: 'removed key should disappear');
  });

  testWidgets(
      'BcDescriptions renders empty state for empty data '
      '(VAL-M1-030)', (tester) async {
    await tester.pumpWidget(harness(
      const BcDescriptions(data: {}),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(BcDescriptions), findsOneWidget,
        reason: 'widget should not crash with empty data');

    await tester.pumpWidget(harness(
      const BcDescriptions(data: null),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(BcDescriptions), findsOneWidget,
        reason: 'widget should not crash with null data');
  });

  testWidgets(
      'BcDescriptions column layout respects labelWidth config '
      '(VAL-M1-031)', (tester) async {
    await tester.pumpWidget(harness(
      const BcDescriptions(
        data: {'Name': 'Alice'},
        labelWidth: 120,
      ),
    ));
    await tester.pumpAndSettle();

    final labelFinder = find.text('Name');
    final valueFinder = find.text('Alice');
    expect(labelFinder, findsOneWidget);
    expect(valueFinder, findsOneWidget);

    final labelBox = tester.getRect(labelFinder);
    final valueBox = tester.getRect(valueFinder);

    expect(labelBox.width, lessThanOrEqualTo(120),
        reason: 'label column should be constrained to labelWidth');
    expect(valueBox.left, greaterThanOrEqualTo(labelBox.left),
        reason: 'value should be to the right of the label');
  });
}
