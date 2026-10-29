import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_statistic.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 200,
          child: child,
        ),
      ),
    );
  }

  testWidgets(
      'BcStatistic renders title, value, prefix, and suffix '
      '(VAL-M1-036)', (tester) async {
    await tester.pumpWidget(harness(
      const BcStatistic(
        title: 'Sales',
        value: '1234',
        prefix: '\$',
        suffix: 'USD',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sales'), findsOneWidget,
        reason: 'title should render');
    expect(find.text('1234'), findsOneWidget,
        reason: 'value should render');
    expect(find.text('\$'), findsOneWidget,
        reason: 'prefix should render');
    expect(find.text('USD'), findsOneWidget,
        reason: 'suffix should render');
  });

  testWidgets('BcStatistic updates value reactively (VAL-M1-037)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcStatistic(title: 'Sales', value: '1234'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('1234'), findsOneWidget);

    await tester.pumpWidget(harness(
      const BcStatistic(title: 'Sales', value: '5678'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('5678'), findsOneWidget,
        reason: 'new value should render');
    expect(find.text('1234'), findsNothing,
        reason: 'old value should be gone');
    expect(find.text('Sales'), findsOneWidget,
        reason: 'title should still render');
  });

  testWidgets(
      'BcStatistic renders with omitted optional parts '
      '(VAL-M1-038)', (tester) async {
    await tester.pumpWidget(harness(
      const BcStatistic(title: 'Sales', value: '1234'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);
    expect(find.text('\$'), findsNothing,
        reason: 'no prefix widget should render');
    expect(find.text('USD'), findsNothing,
        reason: 'no suffix widget should render');
  });
}
