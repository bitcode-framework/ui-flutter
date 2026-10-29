import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_flex.dart';

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
      'BcFlex direction lays out children along the correct main axis (VAL-M4-037)',
      (tester) async {
    // row: children laid out left-to-right (horizontal main axis).
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        gap: 0,
        children: [
          SizedBox(key: ValueKey('a'), width: 40, height: 40),
          SizedBox(key: ValueKey('b'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aRow = tester.getRect(find.byKey(const ValueKey('a')));
    final bRow = tester.getRect(find.byKey(const ValueKey('b')));
    expect(aRow.left < bRow.left, isTrue,
        reason: 'row direction should lay children out horizontally');
    expect(aRow.top, closeTo(bRow.top, 0.5),
        reason: 'row children share the same top');

    // column: children laid out top-to-bottom (vertical main axis).
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.column,
        gap: 0,
        children: [
          SizedBox(key: ValueKey('a'), width: 40, height: 40),
          SizedBox(key: ValueKey('b'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aCol = tester.getRect(find.byKey(const ValueKey('a')));
    final bCol = tester.getRect(find.byKey(const ValueKey('b')));
    expect(aCol.top < bCol.top, isTrue,
        reason: 'column direction should lay children out vertically');
    expect(aCol.left, closeTo(bCol.left, 0.5),
        reason: 'column children share the same left');

    // row-reverse: children laid out right-to-left.
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.rowReverse,
        gap: 0,
        children: [
          SizedBox(key: ValueKey('a'), width: 40, height: 40),
          SizedBox(key: ValueKey('b'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aRev = tester.getRect(find.byKey(const ValueKey('a')));
    final bRev = tester.getRect(find.byKey(const ValueKey('b')));
    expect(aRev.left > bRev.left, isTrue,
        reason: 'row-reverse should reverse horizontal order');
  });

  testWidgets(
      'BcFlex align and justify distribute children per the contract values (VAL-M4-038)',
      (tester) async {
    // justify=center: children grouped at the main-axis center.
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        justify: BcFlexJustify.center,
        gap: 0,
        children: [
          SizedBox(key: ValueKey('a'), width: 40, height: 40),
          SizedBox(key: ValueKey('b'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aRect = tester.getRect(find.byKey(const ValueKey('a')));
    final bRect = tester.getRect(find.byKey(const ValueKey('b')));
    final groupCenter = (aRect.left + bRect.right) / 2;
    // Parent is 400 wide centered at 200.
    expect(groupCenter, closeTo(200, 1.0),
        reason: 'justify=center should center the group on the main axis');

    // justify=between: first at start, last at end.
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        justify: BcFlexJustify.between,
        gap: 0,
        children: [
          SizedBox(key: ValueKey('a'), width: 40, height: 40),
          SizedBox(key: ValueKey('b'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aBetween = tester.getRect(find.byKey(const ValueKey('a')));
    final bBetween = tester.getRect(find.byKey(const ValueKey('b')));
    expect(aBetween.left, closeTo(0, 1.0),
        reason: 'justify=between should place first child at the start');
    expect(bBetween.right, closeTo(400, 1.0),
        reason: 'justify=between should place last child at the end');

    // align=center: cross-axis centering of a short child among tall ones.
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        align: BcFlexAlign.center,
        gap: 0,
        children: [
          SizedBox(key: ValueKey('tall'), width: 40, height: 120),
          SizedBox(key: ValueKey('short'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final tallRect = tester.getRect(find.byKey(const ValueKey('tall')));
    final shortRect = tester.getRect(find.byKey(const ValueKey('short')));
    final tallCenter = (tallRect.top + tallRect.bottom) / 2;
    final shortCenter = (shortRect.top + shortRect.bottom) / 2;
    expect(shortCenter, closeTo(tallCenter, 1.0),
        reason: 'align=center should vertically center the short child');
  });

  testWidgets(
      'BcFlex per-child flex factors override natural sizing along the main axis (VAL-M4-039)',
      (tester) async {
    // Two BcFlexItem children with equal flex in a 400-wide container:
    // each should occupy half the width regardless of natural child size.
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        gap: 0,
        children: [
          BcFlexItem(
            key: ValueKey('flex-a'),
            flex: 1,
            child: SizedBox(key: ValueKey('a'), width: 10, height: 40),
          ),
          BcFlexItem(
            key: ValueKey('flex-b'),
            flex: 1,
            child: SizedBox(key: ValueKey('b'), width: 10, height: 40),
          ),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aRect = tester.getRect(find.byKey(const ValueKey('a')));
    final bRect = tester.getRect(find.byKey(const ValueKey('b')));
    // Each flex item should get ~200px (half of 400), overriding the
    // natural 10px width.
    expect(aRect.width, closeTo(200, 1.0),
        reason: 'flex=1 child should expand to half the main axis');
    expect(bRect.width, closeTo(200, 1.0),
        reason: 'flex=1 child should expand to half the main axis');
    expect(aRect.right, closeTo(bRect.left, 1.0),
        reason: 'flex children should be adjacent');

    // Unequal flex factors (2:1) should split 400 into ~266:133.
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        gap: 0,
        children: [
          BcFlexItem(
            key: ValueKey('flex-a'),
            flex: 2,
            child: SizedBox(key: ValueKey('a'), width: 10, height: 40),
          ),
          BcFlexItem(
            key: ValueKey('flex-b'),
            flex: 1,
            child: SizedBox(key: ValueKey('b'), width: 10, height: 40),
          ),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aUneven = tester.getRect(find.byKey(const ValueKey('a')));
    final bUneven = tester.getRect(find.byKey(const ValueKey('b')));
    expect(aUneven.width, closeTo(400 * 2 / 3, 1.0),
        reason: 'flex=2 should get 2/3 of the main axis');
    expect(bUneven.width, closeTo(400 * 1 / 3, 1.0),
        reason: 'flex=1 should get 1/3 of the main axis');
  });

  testWidgets('BcFlex gap inserts uniform spacing between children', (tester) async {
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        gap: 4, // 4 * 4px = 16px
        children: [
          SizedBox(key: ValueKey('a'), width: 40, height: 40),
          SizedBox(key: ValueKey('b'), width: 40, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aRect = tester.getRect(find.byKey(const ValueKey('a')));
    final bRect = tester.getRect(find.byKey(const ValueKey('b')));
    final gap = bRect.left - aRect.right;
    expect(gap, closeTo(16, 0.5),
        reason: 'gap=4 should map to 16px via the 4px multiplier');
  });

  testWidgets('BcFlex inline shrinks the container along the main axis', (tester) async {
    // inline (MainAxisSize.min) only shrinks when the parent grants loose
    // main-axis constraints; an Align inside a bounded SizedBox gives the
    // Flex loose (0..400) constraints so it can shrink to its children.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: Align(
              alignment: Alignment.topLeft,
              child: BcFlex(
                direction: BcFlexDirection.row,
                inline: true,
                align: BcFlexAlign.start,
                gap: 0,
                children: [
                  SizedBox(key: ValueKey('a'), width: 50, height: 50),
                  SizedBox(key: ValueKey('b'), width: 50, height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final flexSize = tester.getSize(find.byType(BcFlex));
    expect(flexSize.width, closeTo(100, 1.0),
        reason: 'inline should shrink to children width (MainAxisSize.min)');
  });

  testWidgets('BcFlex wrap moves overflow children to a new line', (tester) async {
    await tester.pumpWidget(harness(
      const BcFlex(
        direction: BcFlexDirection.row,
        wrap: BcFlexWrap.wrap,
        gap: 0,
        children: [
          SizedBox(key: ValueKey('a'), width: 250, height: 40),
          SizedBox(key: ValueKey('b'), width: 250, height: 40),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    final aRect = tester.getRect(find.byKey(const ValueKey('a')));
    final bRect = tester.getRect(find.byKey(const ValueKey('b')));
    expect(aRect.top < bRect.top, isTrue,
        reason: 'wrap should move the second child to a new line');
  });
}
