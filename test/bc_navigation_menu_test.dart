import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_navigation_menu.dart';

void main() {
  group('BcNavigationMenu', () {
    testWidgets(
        'renders root items and content panels, selecting root shows its panel '
        '(VAL-M3-017)', (tester) async {
      final items = [
        const BcNavigationMenuItem(
          value: 'home',
          label: 'Home',
          panel: Text('Home Content'),
        ),
        const BcNavigationMenuItem(
          value: 'settings',
          label: 'Settings',
          panel: Text('Settings Content'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcNavigationMenu(
              items: items,
              defaultValue: 'home',
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Home Content'), findsOneWidget);
      expect(find.text('Settings Content'), findsNothing);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings Content'), findsOneWidget);
      expect(find.text('Home Content'), findsNothing);
    });

    testWidgets(
        'root selection emits value with meta (VAL-M3-018)', (tester) async {
      final items = [
        const BcNavigationMenuItem(
          value: 'home',
          label: 'Home',
          panel: Text('Home Content'),
        ),
        const BcNavigationMenuItem(
          value: 'settings',
          label: 'Settings',
          panel: Text('Settings Content'),
        ),
      ];

      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcNavigationMenu(
              items: items,
              defaultValue: 'home',
              onSelected: (value, meta) {
                capturedValue = value;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(capturedValue, 'settings');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets(
        'controlled selection overrides internal state (VAL-M3-019)',
        (tester) async {
      final items = [
        const BcNavigationMenuItem(
          value: 'home',
          label: 'Home',
          panel: Text('Home Content'),
        ),
        const BcNavigationMenuItem(
          value: 'settings',
          label: 'Settings',
          panel: Text('Settings Content'),
        ),
      ];

      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcNavigationMenu(
              items: items,
              value: 'home',
              onSelected: (value, meta) {
                capturedValue = value;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );

      expect(find.text('Home Content'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(capturedValue, 'settings');
      expect(capturedMeta, isNotNull);

      expect(find.text('Home Content'), findsOneWidget);
      expect(find.text('Settings Content'), findsNothing);
    });

    testWidgets(
        'disabled root item is non-interactive (VAL-M3-020)', (tester) async {
      final items = [
        const BcNavigationMenuItem(
          value: 'home',
          label: 'Home',
          panel: Text('Home Content'),
        ),
        const BcNavigationMenuItem(
          value: 'disabled',
          label: 'Disabled',
          panel: Text('Disabled Content'),
          disabled: true,
        ),
      ];

      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcNavigationMenu(
              items: items,
              defaultValue: 'home',
              onSelected: (_, __) => callCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
      expect(find.text('Disabled Content'), findsNothing);
      expect(find.text('Home Content'), findsOneWidget);
    });
  });
}
