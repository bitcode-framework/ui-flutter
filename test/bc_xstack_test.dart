import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_xstack.dart';

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

  testWidgets('BcXStack lays out children horizontally with the specified gap (VAL-M1-007)', (tester) async {
    await tester.pumpWidget(harness(
      const BcXStack(
        gap: 8,
        children: [
          SizedBox(key: ValueKey('a'), width: 40, height: 40),
          SizedBox(key: ValueKey('b'), width: 40, height: 40),
          SizedBox(key: ValueKey('c'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aRect = tester.getRect(find.byKey(const ValueKey('a')));
    final bRect = tester.getRect(find.byKey(const ValueKey('b')));
    final cRect = tester.getRect(find.byKey(const ValueKey('c')));

    expect(aRect.left < bRect.left, isTrue);
    expect(bRect.left < cRect.left, isTrue);

    final gapAB = bRect.left - aRect.right;
    final gapBC = cRect.left - bRect.right;
    expect(gapAB, closeTo(8.0, 0.5));
    expect(gapBC, closeTo(8.0, 0.5));

    final totalWidth = cRect.right - aRect.left;
    expect(totalWidth, closeTo(40 * 3 + 8 * 2, 1.0));
  });

  testWidgets('BcXStack alignment controls cross-axis positioning of children (VAL-M1-008)', (tester) async {
    await tester.pumpWidget(harness(
      const BcXStack(
        gap: 0,
        crossAxisAlignment: BcXStackAlign.center,
        children: [
          SizedBox(key: ValueKey('tall'), width: 40, height: 80),
          SizedBox(key: ValueKey('short'), width: 40, height: 20),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final tallRect = tester.getRect(find.byKey(const ValueKey('tall')));
    final shortRect = tester.getRect(find.byKey(const ValueKey('short')));

    final rowCenter = (tallRect.top + tallRect.bottom) / 2;
    final shortCenter = (shortRect.top + shortRect.bottom) / 2;
    expect(shortCenter, closeTo(rowCenter, 1.0),
        reason: 'center alignment should vertically center short child');

    await tester.pumpWidget(harness(
      const BcXStack(
        gap: 0,
        crossAxisAlignment: BcXStackAlign.start,
        children: [
          SizedBox(key: ValueKey('tall'), width: 40, height: 80),
          SizedBox(key: ValueKey('short'), width: 40, height: 20),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final tallRect2 = tester.getRect(find.byKey(const ValueKey('tall')));
    final shortRect2 = tester.getRect(find.byKey(const ValueKey('short')));
    expect(shortRect2.top, closeTo(tallRect2.top, 1.0),
        reason: 'start alignment should align children to the top');
  });

  testWidgets('BcXStack mainAxisSize controls whether it expands (VAL-M1-009)', (tester) async {
    Widget looseHarness(Widget child) {
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

    await tester.pumpWidget(looseHarness(
      const BcXStack(
        gap: 0,
        mainAxisSize: BcXStackMainAxisSize.min,
        children: [
          SizedBox(key: ValueKey('a'), width: 50, height: 50),
          SizedBox(key: ValueKey('b'), width: 50, height: 50),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final stackFinder = find.byType(Row);
    final stackSize = tester.getSize(stackFinder);
    expect(stackSize.width, closeTo(100, 1.0),
        reason: 'min should not expand beyond children width');

    await tester.pumpWidget(harness(
      const BcXStack(
        gap: 0,
        mainAxisSize: BcXStackMainAxisSize.max,
        children: [
          SizedBox(key: ValueKey('a'), width: 50, height: 50),
          SizedBox(key: ValueKey('b'), width: 50, height: 50),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final stackSizeMax = tester.getSize(find.byType(Row));
    expect(stackSizeMax.width, closeTo(400, 1.0),
        reason: 'max should fill the parent width');
  });
}
