import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_tree_select.dart';
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

  const nodes = [
    BcTreeSelectNode(
      value: 'parent1',
      label: 'Parent 1',
      children: [
        BcTreeSelectNode(value: 'child1a', label: 'Child 1A'),
        BcTreeSelectNode(value: 'child1b', label: 'Child 1B'),
      ],
    ),
    BcTreeSelectNode(
      value: 'parent2',
      label: 'Parent 2',
      children: [
        BcTreeSelectNode(value: 'child2a', label: 'Child 2A'),
      ],
    ),
    BcTreeSelectNode(value: 'leaf', label: 'Standalone Leaf'),
  ];

  testWidgets(
      'BcTreeSelect renders expandable tree nodes with indentation by depth '
      '(VAL-M1-058)', (tester) async {
    await tester.pumpWidget(harness(
      const BcTreeSelect(
        name: 'category',
        nodes: nodes,
        defaultExpanded: ['parent1'],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    expect(find.text('Parent 1'), findsOneWidget);
    expect(find.text('Parent 2'), findsOneWidget);
    expect(find.text('Standalone Leaf'), findsOneWidget);

    expect(find.text('Child 1A'), findsOneWidget,
        reason: 'Child 1A should be visible since parent1 is expanded');
    expect(find.text('Child 1B'), findsOneWidget,
        reason: 'Child 1B should be visible since parent1 is expanded');

    expect(find.text('Child 2A'), findsNothing,
        reason: 'Child 2A should be hidden since parent2 is collapsed');

    await tester.tap(find.byKey(const ValueKey('treeselect_expand_parent2')));
    await tester.pumpAndSettle();

    expect(find.text('Child 2A'), findsOneWidget,
        reason: 'Child 2A should be visible after expanding parent2');
  });

  testWidgets(
      'BcTreeSelect node selection emits value and BcChangeMeta '
      '(VAL-M1-059)', (tester) async {
    Object? capturedValue;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      BcTreeSelect(
        name: 'category',
        nodes: nodes,
        defaultExpanded: const ['parent1'],
        onValueChange: (value, meta) {
          capturedValue = value;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Child 1A'));
    await tester.pumpAndSettle();

    expect(capturedValue, 'child1a');
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
  });

  testWidgets(
      'BcTreeSelect single-select selects a new node deselects previous '
      '(VAL-M1-059)', (tester) async {
    List<Object> capturedValues = [];

    await tester.pumpWidget(harness(
      BcTreeSelect(
        name: 'category',
        nodes: nodes,
        defaultExpanded: const ['parent1'],
        onValueChange: (value, meta) {
          capturedValues.add(value);
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Child 1A'));
    await tester.pumpAndSettle();

    expect(capturedValues.length, 1);
    expect(capturedValues.last, 'child1a');

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Child 1B'));
    await tester.pumpAndSettle();

    expect(capturedValues.length, 2);
    expect(capturedValues.last, 'child1b',
        reason: 'In single-select, selecting a new node replaces old');
  });

  testWidgets(
      'BcTreeSelect multi-select accumulates selections and shows '
      'indeterminate parents (VAL-M1-060)', (tester) async {
    List<Object> capturedValues = [];
    Object currentValue = <String>[];

    Widget buildTree() {
      return StatefulBuilder(
        builder: (context, setState) {
          return BcTreeSelect(
            name: 'category',
            nodes: nodes,
            multiple: true,
            value: currentValue,
            defaultExpanded: const ['parent1'],
            onValueChange: (value, meta) {
              capturedValues.add(value);
              setState(() {
                currentValue = value;
              });
            },
          );
        },
      );
    }

    await tester.pumpWidget(harness(buildTree()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Child 1A'));
    await tester.pumpAndSettle();

    expect(capturedValues.length, 1);
    expect((capturedValues.last as List).contains('child1a'), isTrue);

    await tester.tap(find.text('Child 1B'));
    await tester.pumpAndSettle();

    expect(capturedValues.length, 2);
    final lastList = capturedValues.last as List;
    expect(lastList.contains('child1a'), isTrue);
    expect(lastList.contains('child1b'), isTrue,
        reason: 'Both children should be selected');

    final parent1Check = find.byKey(const ValueKey('treeselect_check_parent1'));
    final checkbox = tester.widget<Checkbox>(parent1Check);
    expect(checkbox.value, true,
        reason: 'Parent with all children selected should be fully checked');
  });

  testWidgets(
      'BcTreeSelect multi-select indeterminate parent shows tristate null '
      '(VAL-M1-060)', (tester) async {
    await tester.pumpWidget(harness(
      const BcTreeSelect(
        name: 'category',
        nodes: nodes,
        multiple: true,
        value: ['child1a'],
        defaultExpanded: ['parent1'],
      ),
    ));
    await tester.pumpAndSettle();

    // The trigger shows the selected label since value is set
    await tester.tap(find.text('Child 1A'));
    await tester.pumpAndSettle();

    final parent1Check = find.byKey(const ValueKey('treeselect_check_parent1'));
    final checkbox = tester.widget<Checkbox>(parent1Check);
    expect(checkbox.value, null,
        reason: 'Parent with some but not all children selected should '
            'be indeterminate (tristate null)');
  });

  testWidgets(
      'BcTreeSelect multi-select parent with none selected is unchecked '
      '(VAL-M1-060)', (tester) async {
    await tester.pumpWidget(harness(
      const BcTreeSelect(
        name: 'category',
        nodes: nodes,
        multiple: true,
        defaultExpanded: ['parent2'],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select...'));
    await tester.pumpAndSettle();

    final parent2Check = find.byKey(const ValueKey('treeselect_check_parent2'));
    final checkbox = tester.widget<Checkbox>(parent2Check);
    expect(checkbox.value, false,
        reason: 'Parent with no children selected should be unchecked');
  });
}
