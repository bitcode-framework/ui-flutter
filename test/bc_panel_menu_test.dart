import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_panel_menu.dart';

void main() {
  group('BcPanelMenu', () {
    List<BcPanelMenuItem> sampleItems() => [
          const BcPanelMenuItem(
            key: 'group1',
            label: 'Group 1',
            children: [
              BcPanelMenuItem(key: 'child1', label: 'Child 1'),
              BcPanelMenuItem(key: 'child2', label: 'Child 2'),
            ],
          ),
          const BcPanelMenuItem(
            key: 'group2',
            label: 'Group 2',
            children: [
              BcPanelMenuItem(key: 'child3', label: 'Child 3'),
            ],
          ),
        ];

    testWidgets('expands and collapses groups with chevron (VAL-M3-037)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcPanelMenu(
              items: sampleItems(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Group 1'), findsOneWidget);
      expect(find.text('Child 1'), findsNothing);

      await tester.tap(find.text('Group 1'));
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);

      await tester.tap(find.text('Group 1'));
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsNothing);
      expect(find.text('Child 2'), findsNothing);
    });

    testWidgets('child selection emits value with meta (VAL-M3-038)',
        (tester) async {
      BcPanelMenuItem? capturedItem;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcPanelMenu(
              items: sampleItems(),
              onSelected: (item, meta) {
                capturedItem = item;
                capturedMeta = meta;
                callCount++;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Group 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Child 1'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedItem, isNotNull);
      expect(capturedItem!.key, 'child1');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
      expect(capturedMeta!.reason, BcChangeReason.select);
    });

    testWidgets('collapsed group children are not selectable (VAL-M3-039)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcPanelMenu(
              items: sampleItems(),
              onSelected: (_, __) => callCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsNothing);
      expect(find.text('Child 2'), findsNothing);

      await tester.tap(find.text('Group 1'));
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);

      await tester.tap(find.text('Child 2'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });

    testWidgets('controlled expansion overrides internal state (VAL-M3-040)',
        (tester) async {
      String? capturedKey;
      bool? capturedExpanded;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      late void Function(void Function()) setStateProxy;
      List<String> externalExpanded = [];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateProxy = setState;
            return MaterialApp(
              home: Scaffold(
                body: BcPanelMenu(
                  items: sampleItems(),
                  expandedKeys: externalExpanded,
                  onGroupToggle: (key, expanded, meta) {
                    capturedKey = key;
                    capturedExpanded = expanded;
                    capturedMeta = meta;
                    callCount++;
                  },
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsNothing);

      await tester.tap(find.text('Group 1'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedKey, 'group1');
      expect(capturedExpanded, isTrue);
      expect(capturedMeta, isNotNull);

      expect(find.text('Child 1'), findsNothing);

      setStateProxy(() {
        externalExpanded = ['group1'];
      });
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsOneWidget);
    });

    testWidgets('disabled group header does not toggle', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcPanelMenu(
              items: const [
                BcPanelMenuItem(
                  key: 'disabled-group',
                  label: 'Disabled Group',
                  disabled: true,
                  children: [
                    BcPanelMenuItem(key: 'dc1', label: 'DC1'),
                  ],
                ),
              ],
              onGroupToggle: (_, __, ___) => callCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disabled Group'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
      expect(find.text('DC1'), findsNothing);
    });
  });
}
