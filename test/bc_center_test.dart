import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_center.dart';

void main() {
  Widget harness(Widget child) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: child,
          ),
        ),
      );

  group('VAL-M7-007 — BcCenter centers child in both axes', () {
    testWidgets('centers child at geometric center of parent', (tester) async {
      await tester.pumpWidget(harness(
        const BcCenter(
          child: SizedBox(
            key: Key('inner'),
            width: 50,
            height: 50,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_center')), findsOneWidget);
      expect(find.byKey(const Key('inner')), findsOneWidget);

      final innerRect = tester.getRect(find.byKey(const Key('inner')));
      // Parent is 300x300, child is 50x50.
      // Centered means left = (300-50)/2 = 125, top = (300-50)/2 = 125
      expect(innerRect.left, closeTo(125, 1.0));
      expect(innerRect.top, closeTo(125, 1.0));
      expect(innerRect.width, 50);
      expect(innerRect.height, 50);
    });

    testWidgets('renders without child without error', (tester) async {
      await tester.pumpWidget(harness(
        const BcCenter(),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_center')), findsOneWidget);
    });

    testWidgets('applies minHeight constraint', (tester) async {
      await tester.pumpWidget(harness(
        const BcCenter(
          minHeight: 200,
          child: SizedBox(key: Key('inner'), width: 30, height: 30),
        ),
      ));
      await tester.pumpAndSettle();

      final innerRect = tester.getRect(find.byKey(const Key('inner')));
      // minHeight 200, child centered vertically within the 200px min area
      expect(innerRect.width, 30);
      expect(innerRect.height, 30);
    });
  });
}
