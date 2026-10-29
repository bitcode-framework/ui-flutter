import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_ystack.dart';

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

  testWidgets('BcYStack lays out children vertically with the specified gap (VAL-M1-010)', (tester) async {
    await tester.pumpWidget(harness(
      const BcYStack(
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

    expect(aRect.top < bRect.top, isTrue);
    expect(bRect.top < cRect.top, isTrue);

    final gapAB = bRect.top - aRect.bottom;
    final gapBC = cRect.top - bRect.bottom;
    expect(gapAB, closeTo(8.0, 0.5));
    expect(gapBC, closeTo(8.0, 0.5));

    final totalHeight = cRect.bottom - aRect.top;
    expect(totalHeight, closeTo(40 * 3 + 8 * 2, 1.0));
  });

  testWidgets('BcYStack crossAxisAlignment controls horizontal positioning (VAL-M1-011)', (tester) async {
    await tester.pumpWidget(harness(
      const BcYStack(
        gap: 0,
        crossAxisAlignment: BcYStackAlign.center,
        children: [
          SizedBox(key: ValueKey('wide'), width: 80, height: 40),
          SizedBox(key: ValueKey('narrow'), width: 20, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final wideRect = tester.getRect(find.byKey(const ValueKey('wide')));
    final narrowRect = tester.getRect(find.byKey(const ValueKey('narrow')));

    final wideCenter = (wideRect.left + wideRect.right) / 2;
    final narrowCenter = (narrowRect.left + narrowRect.right) / 2;
    expect(narrowCenter, closeTo(wideCenter, 1.0),
        reason: 'center alignment should horizontally center narrow child');

    await tester.pumpWidget(harness(
      const BcYStack(
        gap: 0,
        crossAxisAlignment: BcYStackAlign.end,
        children: [
          SizedBox(key: ValueKey('wide'), width: 80, height: 40),
          SizedBox(key: ValueKey('narrow'), width: 20, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final wideRect2 = tester.getRect(find.byKey(const ValueKey('wide')));
    final narrowRect2 = tester.getRect(find.byKey(const ValueKey('narrow')));
    expect(narrowRect2.right, closeTo(wideRect2.right, 1.0),
        reason: 'end alignment should align children to the right edge in LTR');
  });

  testWidgets('BcYStack reverses order when reverse is true (VAL-M1-012)', (tester) async {
    final children = [
      Container(key: const ValueKey('first'), width: 40, height: 40, color: const Color(0xFFFF0000)),
      Container(key: const ValueKey('second'), width: 40, height: 40, color: const Color(0xFF00FF00)),
      Container(key: const ValueKey('third'), width: 40, height: 40, color: const Color(0xFF0000FF)),
    ];

    await tester.pumpWidget(harness(
      BcYStack(
        gap: 0,
        reverse: false,
        children: children,
      ),
    ));
    await tester.pumpAndSettle();

    final firstRectNormal = tester.getRect(find.byKey(const ValueKey('first')));
    final thirdRectNormal = tester.getRect(find.byKey(const ValueKey('third')));
    expect(firstRectNormal.top < thirdRectNormal.top, isTrue,
        reason: 'normal order: first child should be above third child');

    await tester.pumpWidget(harness(
      BcYStack(
        gap: 0,
        reverse: true,
        children: children,
      ),
    ));
    await tester.pumpAndSettle();

    final firstRectReversed = tester.getRect(find.byKey(const ValueKey('first')));
    final thirdRectReversed = tester.getRect(find.byKey(const ValueKey('third')));
    expect(firstRectReversed.top > thirdRectReversed.top, isTrue,
        reason: 'reversed order: first child should appear below third child');
  });
}
