import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_tiered_menu.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  List<BcTieredMenuItem> sampleItems() => [
        const BcTieredMenuItem(
          key: 'file',
          label: 'File',
          children: [
            BcTieredMenuItem(
              key: 'new',
              label: 'New',
              children: [
                BcTieredMenuItem(key: 'project', label: 'Project'),
                BcTieredMenuItem(key: 'file-leaf', label: 'File'),
              ],
            ),
            BcTieredMenuItem(key: 'open', label: 'Open'),
          ],
        ),
        const BcTieredMenuItem(key: 'save', label: 'Save'),
      ];

  group('VAL-M5-037: Root items render and submenu opens revealing nested items',
      () {
    testWidgets('renders all root items', (tester) async {
      await tester.pumpWidget(harness(
        BcTieredMenu(items: sampleItems()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('root item with children does not show submenu initially',
        (tester) async {
      await tester.pumpWidget(harness(
        BcTieredMenu(items: sampleItems()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsNothing);
      expect(find.text('Open'), findsNothing);
    });

    testWidgets('tapping a root item with children reveals the submenu',
        (tester) async {
      await tester.pumpWidget(harness(
        BcTieredMenu(items: sampleItems()),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('root leaf item fires onSelect directly', (tester) async {
      BcTieredMenuItem? capturedItem;
      List<String>? capturedPath;
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcTieredMenu(
          items: sampleItems(),
          onSelect: (item, path) {
            capturedItem = item;
            capturedPath = path;
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedItem, isNotNull);
      expect(capturedItem!.key, 'save');
      expect(capturedPath, ['save']);
    });
  });

  group('VAL-M5-038: Nested submenus cascade and deep selection emits leaf', () {
    testWidgets('opening nested submenu reveals further children', (tester) async {
      await tester.pumpWidget(harness(
        BcTieredMenu(items: sampleItems()),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsOneWidget);

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      expect(find.text('Project'), findsOneWidget);
      expect(find.text('File'), findsNWidgets(2));
    });

    testWidgets('selecting a deep leaf fires onSelect with full path',
        (tester) async {
      BcTieredMenuItem? capturedItem;
      List<String>? capturedPath;
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcTieredMenu(
          items: sampleItems(),
          onSelect: (item, path) {
            capturedItem = item;
            capturedPath = path;
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Project'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedItem, isNotNull);
      expect(capturedItem!.key, 'project');
      expect(capturedPath, ['file', 'new', 'project']);
    });

    testWidgets('selecting a shallow leaf fires onSelect with path',
        (tester) async {
      BcTieredMenuItem? capturedItem;
      List<String>? capturedPath;

      await tester.pumpWidget(harness(
        BcTieredMenu(
          items: sampleItems(),
          onSelect: (item, path) {
            capturedItem = item;
            capturedPath = path;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(capturedItem, isNotNull);
      expect(capturedItem!.key, 'open');
      expect(capturedPath, ['file', 'open']);
    });
  });

  group('VAL-M5-039: Focus-away closes open submenus', () {
    testWidgets('focus away resets open submenus', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(harness(
        BcTieredMenu(items: sampleItems(), focusNode: focusNode),
      ));
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsOneWidget);

      focusNode.unfocus();
      await tester.pumpAndSettle();

      expect(find.text('New'), findsNothing);
    });

    testWidgets('collapsing a parent closes its descendants', (tester) async {
      await tester.pumpWidget(harness(
        BcTieredMenu(items: sampleItems()),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('tm-row-file')));
      await tester.pumpAndSettle();
      expect(find.text('New'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('tm-row-new')));
      await tester.pumpAndSettle();
      expect(find.text('Project'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('tm-row-file')));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsNothing);
      expect(find.text('Project'), findsNothing);
    });
  });

  group('VAL-M5-040: Disabled menu items are non-interactive', () {
    testWidgets('disabled item does not open submenu', (tester) async {
      final items = [
        const BcTieredMenuItem(
          key: 'disabled-root',
          label: 'Disabled Root',
          disabled: true,
          children: [
            BcTieredMenuItem(key: 'child', label: 'Child'),
          ],
        ),
      ];

      await tester.pumpWidget(harness(
        BcTieredMenu(items: items),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disabled Root'));
      await tester.pumpAndSettle();

      expect(find.text('Child'), findsNothing);
    });

    testWidgets('disabled item does not fire onSelect', (tester) async {
      int callCount = 0;

      final items = [
        const BcTieredMenuItem(
          key: 'ok',
          label: 'OK',
        ),
        const BcTieredMenuItem(
          key: 'disabled-leaf',
          label: 'Disabled Leaf',
          disabled: true,
        ),
      ];

      await tester.pumpWidget(harness(
        BcTieredMenu(
          items: items,
          onSelect: (item, path) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disabled Leaf'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('disabled item renders with disabled visual state',
        (tester) async {
      final items = [
        const BcTieredMenuItem(
          key: 'disabled-item',
          label: 'Disabled Item',
          disabled: true,
        ),
      ];

      await tester.pumpWidget(harness(
        BcTieredMenu(items: items),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Disabled Item'), findsOneWidget);

      final text = tester.widget<Text>(
          find.byKey(const ValueKey<String>('tm-label-disabled-item')));
      expect(text.style!.color, isNotNull);
    });

    testWidgets('adjacent enabled items remain interactive', (tester) async {
      int callCount = 0;

      final items = [
        const BcTieredMenuItem(
          key: 'disabled-item',
          label: 'Disabled',
          disabled: true,
        ),
        const BcTieredMenuItem(key: 'enabled-item', label: 'Enabled'),
      ];

      await tester.pumpWidget(harness(
        BcTieredMenu(
          items: items,
          onSelect: (item, path) => callCount++,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enabled'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });
  });
}
