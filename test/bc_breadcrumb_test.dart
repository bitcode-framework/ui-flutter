import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_breadcrumb.dart';

void main() {
  group('BcBreadcrumb', () {
    testWidgets('renders items with separators between them (VAL-M3-001)',
        (tester) async {
      final items = [
        const BcBreadcrumbItem(label: 'Home', path: '/home'),
        const BcBreadcrumbItem(label: 'Settings', path: '/settings'),
        const BcBreadcrumbItem(label: 'Profile', path: '/settings/profile'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcBreadcrumb(items: items),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      expect(find.byKey(const Key('bc-breadcrumb-separator-1')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-breadcrumb-separator-2')),
          findsOneWidget);
    });

    testWidgets('click emits selected item path and meta (VAL-M3-002)',
        (tester) async {
      final items = [
        const BcBreadcrumbItem(label: 'Home', path: '/home'),
        const BcBreadcrumbItem(label: 'Settings', path: '/settings'),
      ];

      String? capturedPath;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcBreadcrumb(
              items: items,
              onSelected: (path, meta) {
                capturedPath = path;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(capturedPath, '/home');
      expect(capturedMeta, isNotNull);
    });

    testWidgets('disabled item is not tappable (VAL-M3-003)',
        (tester) async {
      final items = [
        const BcBreadcrumbItem(label: 'Home', path: '/home', disabled: true),
        const BcBreadcrumbItem(label: 'Settings', path: '/settings'),
      ];

      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcBreadcrumb(
              items: items,
              onSelected: (_, __) => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('renders empty list without error (VAL-M3-004)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcBreadcrumb(items: []),
          ),
        ),
      );

      expect(find.byType(BcBreadcrumb), findsOneWidget);
      expect(find.byKey(const Key('bc-breadcrumb-separator-1')),
          findsNothing);
    });
  });
}
