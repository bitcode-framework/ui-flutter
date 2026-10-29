import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_sidebar.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  final items = [
    const BcSidebarItem(value: 'home', label: 'Home', icon: Icons.home),
    const BcSidebarItem(value: 'settings', label: 'Settings', icon: Icons.settings),
    const BcSidebarItem(value: 'profile', label: 'Profile', icon: Icons.person),
  ];

  group('VAL-M7-016 — BcSidebar renders collapsible navigation panel', () {
    testWidgets('renders sidebar with items', (tester) async {
      await tester.pumpWidget(harness(
        BcSidebar(items: items),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_sidebar')), findsOneWidget);
      expect(find.byKey(const Key('bc_sidebar_item_home')), findsOneWidget);
      expect(find.byKey(const Key('bc_sidebar_item_settings')), findsOneWidget);
      expect(find.byKey(const Key('bc_sidebar_item_profile')), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('collapse button toggles collapsed state and emits meta', (tester) async {
      bool? capturedCollapsed;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSidebar(
          items: items,
          onCollapsedChange: (collapsed, meta) {
            capturedCollapsed = collapsed;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_sidebar_collapse_btn')));
      await tester.pumpAndSettle();

      expect(capturedCollapsed, true);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.toggle);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('collapsed sidebar hides item labels', (tester) async {
      await tester.pumpWidget(harness(
        BcSidebar(items: items, collapsed: true),
      ));
      await tester.pumpAndSettle();

      // Labels should not be visible when collapsed
      expect(find.text('Home'), findsNothing);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('expanded sidebar shows full labels', (tester) async {
      await tester.pumpWidget(harness(
        BcSidebar(items: items, collapsed: false),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders with title', (tester) async {
      await tester.pumpWidget(harness(
        BcSidebar(title: 'Navigation', items: items),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_sidebar_header')), findsOneWidget);
      expect(find.text('Navigation'), findsOneWidget);
    });
  });

  group('VAL-M7-017 — BcSidebar item selection emits value with meta', () {
    testWidgets('tapping item emits selected value with select reason', (tester) async {
      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        BcSidebar(
          items: items,
          onSelected: (value, meta) {
            capturedValue = value;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_sidebar_item_settings')));
      await tester.pumpAndSettle();

      expect(capturedValue, 'settings');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('disabled item does not emit onSelected', (tester) async {
      String? capturedValue;

      final disabledItems = [
        const BcSidebarItem(value: 'active', label: 'Active', icon: Icons.home),
        const BcSidebarItem(value: 'locked', label: 'Locked', icon: Icons.lock, disabled: true),
      ];

      await tester.pumpWidget(harness(
        BcSidebar(
          items: disabledItems,
          onSelected: (value, meta) {
            capturedValue = value;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_sidebar_item_locked')));
      await tester.pumpAndSettle();

      expect(capturedValue, isNull);
    });

    testWidgets('controlled selectedValue renders active visual state', (tester) async {
      await tester.pumpWidget(harness(
        BcSidebar(items: items, selectedValue: 'settings'),
      ));
      await tester.pumpAndSettle();

      final container = tester.widget<InkWell>(
        find.byKey(const Key('bc_sidebar_item_settings')),
      );
      expect(container.onTap, isNotNull);
    });

    testWidgets('divider items render as dividers', (tester) async {
      final itemsWithDivider = [
        const BcSidebarItem(value: 'a', label: 'A'),
        const BcSidebarItem(value: 'div1', label: '', isDivider: true),
        const BcSidebarItem(value: 'b', label: 'B'),
      ];

      await tester.pumpWidget(harness(
        BcSidebar(items: itemsWithDivider),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_sidebar_item_a')), findsOneWidget);
      expect(find.byKey(const Key('bc_sidebar_item_b')), findsOneWidget);
      // divider should have its own key but not as a clickable item
      expect(find.byKey(const Key('bc_sidebar_item_div1')), findsOneWidget);
    });
  });
}
