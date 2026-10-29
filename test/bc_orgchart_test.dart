import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_orgchart.dart';

void main() {
  const tree = BcOrgNode(
    id: 'root',
    label: 'CEO',
    title: 'Chief Executive',
    children: [
      BcOrgNode(
        id: 'vp1',
        label: 'VP Engineering',
        children: [
          BcOrgNode(id: 'lead1', label: 'Tech Lead'),
        ],
      ),
      BcOrgNode(id: 'vp2', label: 'VP Sales'),
    ],
  );

  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets(
      'BcOrgChart renders root and children with depth indentation '
      '(VAL-M5-005)', (tester) async {
    await tester.pumpWidget(harness(
      const BcOrgChart(root: tree, defaultExpanded: ['root', 'vp1']),
    ));
    await tester.pumpAndSettle();

    expect(find.text('CEO'), findsOneWidget);
    expect(find.text('VP Engineering'), findsOneWidget);
    expect(find.text('Tech Lead'), findsOneWidget);
    expect(find.text('VP Sales'), findsOneWidget);

    expect(find.byKey(const Key('bc_orgchart_node_root')), findsOneWidget);
    expect(find.byKey(const Key('bc_orgchart_node_vp1')), findsOneWidget);
    expect(find.byKey(const Key('bc_orgchart_node_lead1')), findsOneWidget);
    expect(find.byKey(const Key('bc_orgchart_node_vp2')), findsOneWidget);
  });

  testWidgets(
      'BcOrgChart collapsed by default hides children '
      '(VAL-M5-005)', (tester) async {
    await tester.pumpWidget(harness(
      const BcOrgChart(root: tree),
    ));
    await tester.pumpAndSettle();

    expect(find.text('CEO'), findsOneWidget);
    expect(find.text('VP Engineering'), findsNothing,
        reason: 'Children should be hidden when root is collapsed');
  });

  testWidgets(
      'BcOrgChart expand/collapse toggles subtree independently '
      '(VAL-M5-006)', (tester) async {
    const treeWithSiblings = BcOrgNode(
      id: 'root',
      label: 'CEO',
      children: [
        BcOrgNode(
          id: 'vp1',
          label: 'VP Engineering',
          children: [
            BcOrgNode(id: 'lead1', label: 'Tech Lead'),
          ],
        ),
        BcOrgNode(
          id: 'vp2',
          label: 'VP Sales',
          children: [
            BcOrgNode(id: 'rep1', label: 'Sales Rep'),
          ],
        ),
      ],
    );

    await tester.pumpWidget(harness(
      const BcOrgChart(root: treeWithSiblings, defaultExpanded: ['root']),
    ));
    await tester.pumpAndSettle();

    expect(find.text('VP Engineering'), findsOneWidget);
    expect(find.text('VP Sales'), findsOneWidget);
    expect(find.text('Tech Lead'), findsNothing,
        reason: 'vp1 is collapsed, so Tech Lead should be hidden');
    expect(find.text('Sales Rep'), findsNothing,
        reason: 'vp2 is collapsed, so Sales Rep should be hidden');

    await tester.tap(find.byKey(const Key('bc_orgchart_expand_vp1')));
    await tester.pumpAndSettle();

    expect(find.text('Tech Lead'), findsOneWidget,
        reason: 'After expanding vp1, Tech Lead should be visible');
    expect(find.text('Sales Rep'), findsNothing,
        reason: 'vp2 is still collapsed, Sales Rep should still be hidden');

    await tester.tap(find.byKey(const Key('bc_orgchart_expand_vp2')));
    await tester.pumpAndSettle();

    expect(find.text('Tech Lead'), findsOneWidget,
        reason: 'Toggling vp2 should not affect vp1 subtree');
    expect(find.text('Sales Rep'), findsOneWidget,
        reason: 'After expanding vp2, Sales Rep should be visible');

    await tester.tap(find.byKey(const Key('bc_orgchart_expand_vp1')));
    await tester.pumpAndSettle();

    expect(find.text('Tech Lead'), findsNothing,
        reason: 'Collapsing vp1 hides Tech Lead');
    expect(find.text('Sales Rep'), findsOneWidget,
        reason: 'Collapsing vp1 does not affect vp2 subtree');
  });

  testWidgets(
      'BcOrgChart collapse hides children and expand shows them '
      '(VAL-M5-006)', (tester) async {
    await tester.pumpWidget(harness(
      const BcOrgChart(root: tree, defaultExpanded: ['root']),
    ));
    await tester.pumpAndSettle();

    expect(find.text('VP Engineering'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bc_orgchart_expand_root')));
    await tester.pumpAndSettle();

    expect(find.text('VP Engineering'), findsNothing,
        reason: 'After collapsing root, children should be hidden');
    expect(find.text('VP Sales'), findsNothing);

    await tester.tap(find.byKey(const Key('bc_orgchart_expand_root')));
    await tester.pumpAndSettle();

    expect(find.text('VP Engineering'), findsOneWidget,
        reason: 'After re-expanding root, children should reappear');
  });

  testWidgets(
      'BcOrgChart node click emits selection with node value and meta '
      '(VAL-M5-007)', (tester) async {
    BcOrgNode? selectedNode;
    var metaCount = 0;

    await tester.pumpWidget(harness(
      BcOrgChart(
        root: tree,
        defaultExpanded: const ['root'],
        onNodeSelect: (node, meta) {
          selectedNode = node;
          metaCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_orgchart_node_vp1')));
    await tester.pumpAndSettle();

    expect(selectedNode, isNotNull);
    expect(selectedNode!.id, 'vp1');
    expect(metaCount, 1);
  });

  testWidgets(
      'BcOrgChart expand button does not trigger node selection '
      '(VAL-M5-007)', (tester) async {
    BcOrgNode? selectedNode;

    await tester.pumpWidget(harness(
      BcOrgChart(
        root: tree,
        defaultExpanded: const ['root'],
        onNodeSelect: (node, meta) {
          selectedNode = node;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_orgchart_expand_root')));
    await tester.pumpAndSettle();

    expect(selectedNode, isNull,
        reason: 'Tapping expand button should not fire node selection');
  });
}
