import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_virtual_scroller.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  List<BcVirtualScrollerItem> smallItems() => List.generate(
        5,
        (i) => BcVirtualScrollerItem(
          id: 'item-$i',
          label: 'Item $i',
          description: 'Description $i',
        ),
      );

  List<BcVirtualScrollerItem> largeItems(int n) => List.generate(
        n,
        (i) => BcVirtualScrollerItem(id: 'item-$i', label: 'Item $i'),
      );

  group('VAL-M5-033: Only visible window rendered for large datasets', () {
    testWidgets('renders bounded count of item nodes for large dataset',
        (tester) async {
      const largeN = 10000;
      final items = largeItems(largeN);

      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: items,
          height: 200,
          itemHeight: 48,
        ),
      ));
      await tester.pumpAndSettle();

      final renderedItems = find
          .byKey(const ValueKey<String>('vs-empty'))
          .evaluate()
          .isEmpty
          ? tester
              .widgetList<Container>(find.byType(Container))
              .where((c) =>
                  c.key is ValueKey<String> &&
                  (c.key as ValueKey<String>).value.startsWith('vs-item-'))
              .length
          : 0;

      expect(renderedItems, lessThan(largeN));
      expect(renderedItems, greaterThan(0));
    });

    testWidgets('renders all items when dataset fits the viewport',
        (tester) async {
      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: smallItems(),
          height: 400,
          itemHeight: 48,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });
  });

  group('VAL-M5-034: Scrolling updates visible window with correct content', () {
    testWidgets('item labels match their underlying data index',
        (tester) async {
      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: smallItems(),
          height: 200,
          itemHeight: 48,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('descriptions render for items with description', (tester) async {
      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: smallItems(),
          height: 200,
          itemHeight: 48,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Description 0'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
    });

    testWidgets('scrolling reveals later items', (tester) async {
      final items = largeItems(20);

      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: items,
          height: 100,
          itemHeight: 48,
        ),
      ));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
          tester.getCenter(find.byType(Scrollable)));
      await gesture.moveBy(const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsNothing);
      expect(find.text('Item 10'), findsOneWidget);
    });
  });

  group('VAL-M5-035: scroll-to-index API positions target item', () {
    testWidgets('controller.scrollToIndex brings target into view',
        (tester) async {
      final controller = BcVirtualScrollerController();
      final items = largeItems(30);

      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: items,
          height: 100,
          itemHeight: 48,
          controller: controller,
        ),
      ));
      await tester.pumpAndSettle();

      controller.scrollToIndex(10);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Item 0'), findsNothing);
      expect(find.text('Item 10'), findsOneWidget);
    });

    testWidgets('out-of-range index clamps without RangeError', (tester) async {
      final controller = BcVirtualScrollerController();
      final items = largeItems(5);

      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: items,
          height: 100,
          itemHeight: 48,
          controller: controller,
        ),
      ));
      await tester.pumpAndSettle();

      controller.scrollToIndex(9999);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.takeException(), isNull);
    });

    testWidgets('scrollToIndex on empty dataset is a no-op', (tester) async {
      final controller = BcVirtualScrollerController();

      await tester.pumpWidget(harness(
        BcVirtualScroller(
          items: const [],
          height: 100,
          itemHeight: 48,
          controller: controller,
        ),
      ));
      await tester.pumpAndSettle();

      controller.scrollToIndex(0);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('VAL-M5-036: Empty dataset renders empty state without error', () {
    testWidgets('renders empty state for empty list', (tester) async {
      await tester.pumpWidget(harness(
        const BcVirtualScroller(
          items: [],
          height: 200,
          emptyText: 'Nothing here',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('vs-empty')), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('renders no item nodes for empty list', (tester) async {
      await tester.pumpWidget(harness(
        const BcVirtualScroller(items: [], height: 200),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('empty state does not throw', (tester) async {
      await tester.pumpWidget(harness(
        const BcVirtualScroller(items: [], height: 200),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses default empty text when not provided', (tester) async {
      await tester.pumpWidget(harness(
        const BcVirtualScroller(items: [], height: 200),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No items'), findsOneWidget);
    });
  });
}
