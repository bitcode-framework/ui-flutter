import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_megamenu.dart';

void main() {
  group('BcMegaMenu', () {
    testWidgets(
        'opens full-width dropdown panel and closes on re-activate (VAL-M3-013)',
        (tester) async {
      final items = [
        const BcMegaMenuItem(
          label: 'Products',
          columns: [
            BcMegaMenuColumn(
              title: 'Software',
              links: [
                BcMegaMenuLink(label: 'App', value: 'app'),
              ],
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMegaMenu(items: items),
          ),
        ),
      );

      expect(find.text('Software'), findsNothing);

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.text('Software'), findsOneWidget);

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.text('Software'), findsNothing);
    });

    testWidgets('categorizes items into panels (VAL-M3-014)',
        (tester) async {
      final items = [
        const BcMegaMenuItem(
          label: 'Products',
          columns: [
            BcMegaMenuColumn(
              title: 'Software',
              links: [
                BcMegaMenuLink(label: 'App', value: 'app'),
              ],
            ),
            BcMegaMenuColumn(
              title: 'Hardware',
              links: [
                BcMegaMenuLink(label: 'Mouse', value: 'mouse'),
              ],
            ),
            BcMegaMenuColumn(links: []),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMegaMenu(items: items),
          ),
        ),
      );

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.text('Software'), findsOneWidget);
      expect(find.text('Hardware'), findsOneWidget);
      expect(find.text('App'), findsOneWidget);
      expect(find.text('Mouse'), findsOneWidget);
    });

    testWidgets(
        'item click emits selection with meta and closes (VAL-M3-015)',
        (tester) async {
      final items = [
        const BcMegaMenuItem(
          label: 'Products',
          columns: [
            BcMegaMenuColumn(
              title: 'Software',
              links: [
                BcMegaMenuLink(label: 'App', value: 'app'),
              ],
            ),
          ],
        ),
      ];

      String? capturedValue;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMegaMenu(
              items: items,
              onSelected: (value, meta) {
                capturedValue = value;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('App'));
      await tester.pumpAndSettle();

      expect(capturedValue, 'app');
      expect(capturedMeta, isNotNull);
      expect(find.text('Software'), findsNothing);
    });

    testWidgets('closes on outside tap (VAL-M3-016)', (tester) async {
      final items = [
        const BcMegaMenuItem(
          label: 'Products',
          columns: [
            BcMegaMenuColumn(
              title: 'Software',
              links: [
                BcMegaMenuLink(label: 'App', value: 'app'),
              ],
            ),
          ],
        ),
      ];

      bool closedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapRegionSurface(
              child: Column(
                children: [
                  BcMegaMenu(
                    items: items,
                    onClose: () => closedCalled = true,
                  ),
                  const Expanded(
                    child: ColoredBox(
                      color: Colors.red,
                      child: Center(child: Text('outside area')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.text('Software'), findsOneWidget);

      await tester.tap(find.text('outside area'));
      await tester.pumpAndSettle();

      expect(closedCalled, isTrue);
      expect(find.text('Software'), findsNothing);
    });
  });
}
