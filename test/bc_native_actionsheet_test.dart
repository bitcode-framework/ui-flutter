import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_native_actionsheet.dart';

void main() {
  group('BcNativeActionSheet', () {
    const items = [
      BcNativeActionSheetItem(label: 'Edit', value: 'edit'),
      BcNativeActionSheetItem(label: 'Share', value: 'share'),
      BcNativeActionSheetItem(
          label: 'Delete', value: 'delete', destructive: true),
      BcNativeActionSheetItem(
          label: 'Archive', value: 'archive', disabled: true),
    ];

    Widget buildHarness({Widget? child}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
    }

    testWidgets('show() returns the selected item value (VAL-G-039)',
        (tester) async {
      String? result;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await BcNativeActionSheet.show(
                  context: context,
                  items: items,
                  title: 'Actions',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-native-actionsheet-bottomsheet')),
          findsOneWidget);
      expect(find.text('Edit'), findsWidgets);
      expect(find.text('Share'), findsWidgets);

      await tester.tap(find.text('Share').first);
      await tester.pumpAndSettle();

      expect(result, 'share');
    });

    testWidgets('show() renders title and cancel (VAL-G-040)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeActionSheet.show(
                context: context,
                items: items,
                title: 'Document Actions',
                cancelLabel: 'Close',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Document Actions'), findsOneWidget);
      expect(find.byKey(const Key('bc-native-actionsheet-cancel')),
          findsOneWidget);
    });

    testWidgets('show() returns null on cancel (VAL-G-041)',
        (tester) async {
      String? result = 'sentinel';
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await BcNativeActionSheet.show(
                  context: context,
                  items: items,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-native-actionsheet-cancel')));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('showWithCallbacks fires onSelect with meta (VAL-G-042)',
        (tester) async {
      BcNativeActionSheetItem? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeActionSheet.showWithCallbacks(
                context: context,
                items: items,
                onSelect: (item, m) {
                  captured = item;
                  meta = m;
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.value, 'edit');
      expect(meta!.reason, BcChangeReason.select);
    });

    testWidgets('showWithCallbacks fires onCancel (VAL-G-043)',
        (tester) async {
      BcChangeMeta? meta;
      bool cancelled = false;
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeActionSheet.showWithCallbacks(
                context: context,
                items: items,
                cancelLabel: 'Cancel',
                onCancel: (_, m) {
                  meta = m;
                  cancelled = true;
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-native-actionsheet-cancel')));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
      expect(meta!.reason, BcChangeReason.cancel);
    });

    testWidgets('all items render including disabled (VAL-G-044)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BcNativeActionSheet.show(
                context: context,
                items: items,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // All four items render (disabled item still shows but is not tappable).
      expect(find.text('Edit'), findsWidgets);
      expect(find.text('Share'), findsWidgets);
      expect(find.text('Delete'), findsWidgets);
      expect(find.text('Archive'), findsWidgets);
    });
  });
}
