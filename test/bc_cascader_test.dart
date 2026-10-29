import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_cascader.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  const options = [
    BcCascaderOption(
      value: 'a',
      label: 'Level A',
      children: [
        BcCascaderOption(
          value: 'a1',
          label: 'A1',
          children: [
            BcCascaderOption(value: 'a1x', label: 'A1X'),
          ],
        ),
        BcCascaderOption(value: 'a2', label: 'A2'),
      ],
    ),
    BcCascaderOption(
      value: 'b',
      label: 'Level B',
      children: [
        BcCascaderOption(value: 'b1', label: 'B1'),
      ],
    ),
    BcCascaderOption(value: 'c', label: 'Leaf C'),
  ];

  testWidgets(
      'BcCascader renders drill-down levels from data (VAL-M1-054)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcCascader(name: 'region', options: options),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Select...'), findsOneWidget);

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    expect(find.text('Level A'), findsOneWidget);
    expect(find.text('Level B'), findsOneWidget);
    expect(find.text('Leaf C'), findsOneWidget);

    await tester.tap(find.text('Level A'));
    await tester.pumpAndSettle();

    expect(find.text('A1'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);

    await tester.tap(find.text('A1'));
    await tester.pumpAndSettle();

    expect(find.text('A1X'), findsOneWidget);
  });

  testWidgets(
      'BcCascader selecting a leaf emits the full path with BcChangeMeta '
      '(VAL-M1-055)', (tester) async {
    List<String>? capturedValue;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      BcCascader(
        name: 'region',
        options: options,
        onValueChange: (value, meta) {
          capturedValue = value;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Level A'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A1'));
    await tester.pumpAndSettle();

    final a1x = find.text('A1X');
    await tester.tap(a1x);
    await tester.pumpAndSettle();

    expect(capturedValue, isNotNull);
    expect(capturedValue!, containsAll(['a', 'a1', 'a1x']));
    expect(capturedValue!.length, 3);
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
  });

  testWidgets(
      'BcCascader selecting a non-leaf drills into next level without '
      'emitting value (VAL-M1-055)', (tester) async {
    int callCount = 0;

    await tester.pumpWidget(harness(
      BcCascader(
        name: 'region',
        options: options,
        onValueChange: (value, meta) {
          callCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Level A'));
    await tester.pumpAndSettle();

    expect(callCount, 0,
        reason: 'Selecting a non-leaf should not emit onValueChange');
  });

  testWidgets(
      'BcCascader controlled value preselects the path levels (VAL-M1-056)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcCascader(
        name: 'region',
        options: options,
        value: ['a', 'a1'],
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Level A / A1'), findsOneWidget);

    await tester.tap(find.text('Level A / A1'));
    await tester.pumpAndSettle();

    final levelAOption = find.byKey(const ValueKey('cascader_col0_a'));
    expect(levelAOption, findsOneWidget,
        reason: 'Level A should be present in first column');

    final a1Option = find.byKey(const ValueKey('cascader_col1_a1'));
    expect(a1Option, findsOneWidget,
        reason: 'A1 should be present in second column');

    expect(find.text('A1X'), findsOneWidget,
        reason: 'A1X should be visible since A1 has children and '
            'controlled value pre-expands to level 2');
  });

  testWidgets(
      'BcCascader disabled prevents selection changes (VAL-M1-057)',
      (tester) async {
    List<String>? capturedValue;

    await tester.pumpWidget(harness(
      BcCascader(
        name: 'region',
        options: options,
        disabled: true,
        onValueChange: (value, meta) {
          capturedValue = value;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Level A'), findsNothing,
        reason: 'Dropdown should not open when disabled');

    expect(capturedValue, isNull,
        reason: 'No onValueChange should fire when disabled');
  });
}
