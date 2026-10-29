import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_slot.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('BcSlot renders single child verbatim without extra containers (VAL-M1-001)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSlot(child: Text('x')),
    ));

    expect(find.text('x'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);

    await tester.pumpWidget(harness(
      const BcSlot(
        children: [
          Text('a'),
          Text('b'),
          Text('c'),
        ],
      ),
    ));

    expect(find.byType(Text), findsNWidgets(3));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
  });

  testWidgets('BcSlot passes through empty and null child sets without error (VAL-M1-002)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSlot(),
    ));
    await tester.pump();
    expect(find.byType(Text), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(harness(
      const BcSlot(children: []),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('BcSlot updates dynamically when children list changes (VAL-M1-003)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSlot(
        children: [
          Text('a'),
          Text('b'),
        ],
      ),
    ));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsNothing);

    await tester.pumpWidget(harness(
      const BcSlot(
        key: ValueKey('slot'),
        children: [
          Text('b'),
          Text('c'),
          Text('d'),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('a'), findsNothing, reason: 'stale child should be removed');
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
    expect(find.text('d'), findsOneWidget);
  });
}
