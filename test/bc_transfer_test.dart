import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_transfer.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: child,
        ),
      ),
    );
  }

  const items = [
    BcTransferItem(key: 'a', label: 'Apple'),
    BcTransferItem(key: 'b', label: 'Banana'),
    BcTransferItem(key: 'c', label: 'Cherry'),
    BcTransferItem(key: 'd', label: 'Date'),
  ];

  testWidgets(
      'BcTransfer renders left and right panels with source data '
      '(VAL-M1-050)', (tester) async {
    await tester.pumpWidget(harness(
      const BcTransfer(
        items: items,
        targetKeys: ['c'],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);

    expect(find.text('Apple'), findsOneWidget,
        reason: 'Apple is in source (not in targetKeys)');
    expect(find.text('Banana'), findsOneWidget,
        reason: 'Banana is in source');
    expect(find.text('Date'), findsOneWidget,
        reason: 'Date is in source');

    expect(find.text('Cherry'), findsOneWidget,
        reason: 'Cherry is in target panel');

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Cherry'), findsOneWidget);
  });

  testWidgets(
      'BcTransfer moving items emits onValueChange with new list and '
      'BcChangeMeta (VAL-M1-051)', (tester) async {
    List<String>? capturedValue;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      BcTransfer(
        items: items,
        targetKeys: const ['c'],
        onValueChange: (value, meta) {
          capturedValue = value;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final sourceCheckApple = find.byKey(const ValueKey('transfer_source_check_a'));
    await tester.tap(sourceCheckApple);
    await tester.pumpAndSettle();

    final moveRight = find.byKey(const ValueKey('transfer_move_right'));
    await tester.tap(moveRight);
    await tester.pumpAndSettle();

    expect(capturedValue, isNotNull);
    expect(capturedValue!.contains('c'), isTrue);
    expect(capturedValue!.contains('a'), isTrue);
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
  });

  testWidgets(
      'BcTransfer moving items back removes them and fires onValueChange '
      '(VAL-M1-051)', (tester) async {
    List<String>? capturedValue;

    await tester.pumpWidget(harness(
      BcTransfer(
        items: items,
        targetKeys: const ['c', 'd'],
        onValueChange: (value, meta) {
          capturedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final targetCheckC = find.byKey(const ValueKey('transfer_target_check_c'));
    await tester.tap(targetCheckC);
    await tester.pumpAndSettle();

    final moveLeft = find.byKey(const ValueKey('transfer_move_left'));
    await tester.tap(moveLeft);
    await tester.pumpAndSettle();

    expect(capturedValue, isNotNull);
    expect(capturedValue!.contains('c'), isFalse,
        reason: 'c should be removed from targetKeys');
    expect(capturedValue!.contains('d'), isTrue,
        reason: 'd should remain in targetKeys');
  });

  testWidgets(
      'BcTransfer search filters the left panel options (VAL-M1-052)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcTransfer(
        items: items,
        targetKeys: [],
        searchable: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);

    final searchField = find.byKey(const ValueKey('transfer_search_source'));
    await tester.enterText(searchField, 'ban');
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing,
        reason: 'Apple should be filtered out by search "ban"');
    expect(find.text('Banana'), findsOneWidget,
        reason: 'Banana should remain visible matching search "ban"');

    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget,
        reason: 'Clearing search should restore all options');
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets(
      'BcTransfer disabled state blocks all moves (VAL-M1-053)',
      (tester) async {
    List<String>? capturedValue;

    await tester.pumpWidget(harness(
      BcTransfer(
        items: items,
        targetKeys: const [],
        disabled: true,
        onValueChange: (value, meta) {
          capturedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final sourceCheckA = find.byKey(const ValueKey('transfer_source_check_a'));
    await tester.tap(sourceCheckA, warnIfMissed: false);
    await tester.pumpAndSettle();

    final moveRight = find.byKey(const ValueKey('transfer_move_right'));
    await tester.tap(moveRight, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(capturedValue, isNull,
        reason: 'No onValueChange should fire when disabled');
  });

  testWidgets(
      'BcTransfer per-item disabled blocks checking that item',
      (tester) async {
    List<String>? capturedValue;

    await tester.pumpWidget(harness(
      BcTransfer(
        items: const [
          BcTransferItem(key: 'a', label: 'Apple'),
          BcTransferItem(key: 'b', label: 'Banana', disabled: true),
        ],
        targetKeys: const [],
        onValueChange: (value, meta) {
          capturedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final disabledCheck =
        find.byKey(const ValueKey('transfer_source_check_b'));
    await tester.tap(disabledCheck, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(capturedValue, isNull,
        reason: 'Disabled item should not be checkable');
  });
}
