import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_actionsheet.dart';

void main() {
  group('BcActionsheet', () {
    const testItems = [
      BcActionsheetItem(label: 'Edit', value: 'edit'),
      BcActionsheetItem(label: 'Delete', value: 'delete', destructive: true),
      BcActionsheetItem(label: 'Share', value: 'share', disabled: true),
    ];

    Widget buildHarness({
      bool? open,
      bool defaultOpen = false,
      String? title,
      String? description,
      List<BcActionsheetItem> items = const [],
      String cancelLabel = 'Cancel',
      void Function(BcActionsheetItem, BcChangeMeta)? onSelect,
      BcChangeHandler<void>? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 400,
            child: BcActionsheet(
              open: open,
              defaultOpen: defaultOpen,
              title: title,
              description: description,
              items: items.isNotEmpty ? items : testItems,
              cancelLabel: cancelLabel,
              onSelect: onSelect,
              onCancel: onCancel,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'slides up from bottom and renders all action items plus cancel '
        '(VAL-M4-012)', (tester) async {
      await tester.pumpWidget(buildHarness(defaultOpen: true));
      await tester.pump();

      expect(find.byKey(const Key('bc-actionsheet-sheet')), findsOneWidget);
      expect(find.byKey(const Key('bc-actionsheet-scrim')), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      final sheetFinder = find.byKey(const Key('bc-actionsheet-sheet'));
      expect(sheetFinder, findsOneWidget);

      expect(find.byKey(const Key('bc-actionsheet-cancel')), findsOneWidget);
      expect(
        find.byKey(const Key('bc-actionsheet-item-edit')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('bc-actionsheet-item-delete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('bc-actionsheet-item-share')),
        findsOneWidget,
      );
    });

    testWidgets(
        'selecting an action emits the action value and BcChangeMeta then '
        'dismisses (VAL-M4-013)', (tester) async {
      BcActionsheetItem? capturedItem;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(buildHarness(
        defaultOpen: true,
        onSelect: (item, meta) {
          capturedItem = item;
          capturedMeta = meta;
          callCount++;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedItem, isNotNull);
      expect(capturedItem!.value, 'edit');
      expect(capturedItem!.label, 'Edit');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-actionsheet-sheet')), findsNothing);
    });

    testWidgets(
        'backdrop/scrim dismisses without emitting an action selection '
        '(VAL-M4-014)', (tester) async {
      BcActionsheetItem? capturedItem;
      BcChangeMeta? capturedCancelMeta;
      int selectCount = 0;
      int cancelCount = 0;

      await tester.pumpWidget(buildHarness(
        defaultOpen: true,
        onSelect: (item, meta) {
          capturedItem = item;
          selectCount++;
        },
        onCancel: (_, meta) {
          capturedCancelMeta = meta;
          cancelCount++;
        },
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-actionsheet-scrim')), findsOneWidget);

      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();

      expect(selectCount, 0);
      expect(capturedItem, isNull);
      expect(cancelCount, greaterThanOrEqualTo(1));
      expect(capturedCancelMeta, isNotNull);
      expect(capturedCancelMeta!.source, BcEventSource.pointer);
      expect(capturedCancelMeta!.reason, BcChangeReason.overlayClick);
    });

    testWidgets(
        'cancel button dismisses without emitting an action selection '
        '(VAL-M4-014)', (tester) async {
      BcActionsheetItem? capturedItem;
      BcChangeMeta? capturedCancelMeta;
      int selectCount = 0;
      int cancelCount = 0;

      await tester.pumpWidget(buildHarness(
        defaultOpen: true,
        onSelect: (item, meta) {
          capturedItem = item;
          selectCount++;
        },
        onCancel: (_, meta) {
          capturedCancelMeta = meta;
          cancelCount++;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-actionsheet-cancel')));
      await tester.pumpAndSettle();

      expect(selectCount, 0);
      expect(capturedItem, isNull);
      expect(cancelCount, greaterThanOrEqualTo(1));
      expect(capturedCancelMeta, isNotNull);
      expect(capturedCancelMeta!.reason, BcChangeReason.cancel);
    });

    testWidgets(
        'disabled action item is not selectable and renders with disabled '
        'styling (VAL-M4-014)', (tester) async {
      BcActionsheetItem? capturedItem;
      int selectCount = 0;

      await tester.pumpWidget(buildHarness(
        defaultOpen: true,
        onSelect: (item, meta) {
          capturedItem = item;
          selectCount++;
        },
      ));
      await tester.pumpAndSettle();

      final disabledFinder =
          find.byKey(const Key('bc-actionsheet-item-share'));
      expect(disabledFinder, findsOneWidget);

      await tester.tap(disabledFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(selectCount, 0);
      expect(capturedItem, isNull);

      expect(find.byKey(const Key('bc-actionsheet-sheet')), findsOneWidget);
    });
  });
}
