import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_menubar.dart';

void main() {
  group('BcMenubar', () {
    testWidgets('renders root items horizontally (VAL-M3-009)',
        (tester) async {
      final menus = [
        const BcMenubarMenu(
          label: 'File',
          items: [
            BcMenubarItem(label: 'New', value: 'new'),
          ],
        ),
        const BcMenubarMenu(label: 'Help'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMenubar(menus: menus),
          ),
        ),
      );

      expect(find.text('File'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets(
        'submenu opens on tap and item click emits selection with meta (VAL-M3-010, VAL-M3-011)',
        (tester) async {
      final menus = [
        const BcMenubarMenu(
          label: 'File',
          items: [
            BcMenubarItem(label: 'New', value: 'new'),
            BcMenubarItem(label: 'Open', value: 'open'),
          ],
        ),
      ];

      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMenubar(
              menus: menus,
              onSelected: (value, meta) {
                capturedValue = value;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      expect(find.text('New'), findsOneWidget);

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      expect(capturedValue, 'new');
      expect(capturedMeta, isNotNull);

      expect(find.text('Open'), findsNothing);
    });

    testWidgets('disabled item is non-interactive (VAL-M3-012)',
        (tester) async {
      final menus = [
        const BcMenubarMenu(
          label: 'File',
          items: [
            BcMenubarItem(label: 'New', value: 'new', disabled: true),
            BcMenubarItem(label: 'Open', value: 'open'),
          ],
        ),
      ];

      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMenubar(
              menus: menus,
              onSelected: (_, __) => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
