import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_tree_view.dart';

void main() {
  group('BcTreeView', () {
    const tree = [
      BcTreeViewNode(id: '1', label: 'Root', children: [
        BcTreeViewNode(id: '1-1', label: 'Child A'),
        BcTreeViewNode(id: '1-2', label: 'Child B'),
      ]),
      BcTreeViewNode(id: '2', label: 'Leaf'),
    ];

    Widget buildHarness({
      List<BcTreeViewNode> data = tree,
      Set<String>? defaultExpandedKeys,
      String? selectedKey,
      void Function(BcTreeViewNode node, dynamic meta)? onSelect,
      void Function(String key, bool expanded, dynamic meta)? onExpand,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcTreeView(
            data: data,
            defaultExpandedKeys: defaultExpandedKeys,
            selectedKey: selectedKey,
            onSelect: onSelect,
            onExpand: onExpand,
          ),
        ),
      );
    }

    testWidgets('renders root nodes (VAL-A3-001)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-tree-view')), findsOneWidget);
      expect(find.text('Root'), findsOneWidget);
      expect(find.text('Leaf'), findsOneWidget);
    });

    testWidgets('default expanded keys show children (VAL-A3-002)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        defaultExpandedKeys: {'1'},
      ));
      await tester.pumpAndSettle();
      expect(find.text('Child A'), findsOneWidget);
      expect(find.text('Child B'), findsOneWidget);
    });

    testWidgets('tap toggle expands node (VAL-A3-003)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.text('Child A'), findsNothing);
      await tester.tap(find.byKey(const Key('bc-tree-view-toggle-1')));
      await tester.pumpAndSettle();
      expect(find.text('Child A'), findsOneWidget);
    });

    testWidgets('tap row selects node (VAL-A3-004)', (tester) async {
      String? selectedId;
      await tester.pumpWidget(buildHarness(
        onSelect: (node, meta) => selectedId = node.id,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-tree-view-node-2')));
      await tester.pumpAndSettle();
      expect(selectedId, '2');
    });

    testWidgets('rows have min 44px touch target (VAL-A3-005)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      final rowBox = tester.getSize(find.byKey(const Key('bc-tree-view-node-1')));
      expect(rowBox.height, greaterThanOrEqualTo(44.0));
    });
  });
}
