import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_empty.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: child,
        ),
      ),
    );
  }

  testWidgets(
      'BcEmpty renders icon, message, and action (VAL-M1-039)',
      (tester) async {
    int actionTapCount = 0;

    await tester.pumpWidget(harness(
      BcEmpty(
        icon: const Icon(Icons.inbox),
        message: 'No data',
        action: GestureDetector(
          onTap: () => actionTapCount++,
          child: const Text('Add item'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.inbox), findsOneWidget,
        reason: 'icon should render');
    expect(find.text('No data'), findsOneWidget,
        reason: 'message should render');
    expect(find.text('Add item'), findsOneWidget,
        reason: 'action should render');
    expect(actionTapCount, 0);

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    expect(actionTapCount, 1,
        reason: 'action widget should be interactive');
  });

  testWidgets('BcEmpty action tap fires its callback (VAL-M1-040)',
      (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(harness(
      BcEmpty(
        message: 'Empty',
        action: GestureDetector(
          onTap: () => tapCount++,
          child: const Text('Retry'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(tapCount, 1,
        reason: 'action onTap should fire exactly once');
  });

  testWidgets(
      'BcEmpty renders with message only (icon/action optional) '
      '(VAL-M1-041)', (tester) async {
    await tester.pumpWidget(harness(
      const BcEmpty(message: 'Just a message'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Just a message'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsNothing,
        reason: 'no default icon should clutter when only message given');
  });
}
