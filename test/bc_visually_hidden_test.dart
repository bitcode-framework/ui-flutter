import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_visually_hidden.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: Align(
            alignment: Alignment.topLeft,
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets(
      'BcVisuallyHidden keeps child in semantics tree but off-screen visually '
      '(VAL-M1-017)', (tester) async {
    await tester.pumpWidget(harness(
      const BcVisuallyHidden(
        child: Text('Screen reader only'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Screen reader only'), findsOneWidget,
        reason: 'child must be present in the widget tree');

    expect(find.byType(Semantics), findsWidgets,
        reason: 'semantics must be present for the hidden content');

    final textFinder = find.text('Screen reader only');
    final textOffset = tester.getTopLeft(textFinder);
    expect(textOffset.dx, isNot(closeTo(0, 100)),
        reason: 'text should be positioned off-screen horizontally');
  });

  testWidgets('BcVisuallyHidden does not consume layout space (VAL-M1-018)',
      (tester) async {
    const hiddenKey = ValueKey('hidden');
    const siblingKey = ValueKey('sibling');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BcVisuallyHidden(
                    key: hiddenKey,
                    child: Text('hidden content'),
                  ),
                  Text('sibling', key: siblingKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hiddenSize = tester.getSize(find.byKey(hiddenKey));
    expect(hiddenSize.width, lessThanOrEqualTo(1),
        reason: 'hidden widget should occupy zero or negligible width');
    expect(hiddenSize.height, lessThanOrEqualTo(1),
        reason: 'hidden widget should occupy zero or negligible height');

    final siblingRect = tester.getRect(find.byKey(siblingKey));
    expect(siblingRect.top, lessThan(10),
        reason: 'sibling should start at the top (hidden content takes no space)');
  });

  testWidgets('BcVisuallyHidden empty child renders without error (VAL-M1-019)',
      (tester) async {
    await tester.pumpWidget(harness(const BcVisuallyHidden()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(BcVisuallyHidden), findsOneWidget);
  });
}
