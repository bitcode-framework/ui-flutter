import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_view_activity.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  final entries = [
    BcViewActivityEntry(
      id: 'a1',
      actor: 'Alice',
      action: 'created the record',
      timestamp: DateTime(2024, 1, 1, 10, 0),
      detail: 'Initial creation',
    ),
    BcViewActivityEntry(
      id: 'a2',
      actor: 'Bob',
      action: 'updated the title',
      timestamp: DateTime(2024, 1, 2, 14, 30),
    ),
    BcViewActivityEntry(
      id: 'a3',
      actor: 'Carol',
      action: 'approved the request',
      timestamp: DateTime(2024, 1, 3, 9, 15),
      detail: 'Approved with comments',
    ),
  ];

  group('VAL-M5-030: Items render in chronological order newest-first', () {
    testWidgets('renders all entries', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('newest entry renders first', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      final carolY =
          tester.getTopLeft(find.byKey(const ValueKey<String>('activity-item-a3')));
      final bobY =
          tester.getTopLeft(find.byKey(const ValueKey<String>('activity-item-a2')));
      final aliceY =
          tester.getTopLeft(find.byKey(const ValueKey<String>('activity-item-a1')));

      expect(carolY.dy, lessThan(bobY.dy));
      expect(bobY.dy, lessThan(aliceY.dy));
    });

    testWidgets('identical timestamps preserve input order (stable sort)',
        (tester) async {
      final same = [
        BcViewActivityEntry(
          id: 's1',
          actor: 'First',
          action: 'x',
          timestamp: DateTime(2024, 1, 1),
        ),
        BcViewActivityEntry(
          id: 's2',
          actor: 'Second',
          action: 'x',
          timestamp: DateTime(2024, 1, 1),
        ),
      ];

      await tester.pumpWidget(harness(
        BcViewActivity(entries: same),
      ));
      await tester.pumpAndSettle();

      final firstY = tester.getTopLeft(
          find.byKey(const ValueKey<String>('activity-item-s1')));
      final secondY = tester.getTopLeft(
          find.byKey(const ValueKey<String>('activity-item-s2')));
      expect(firstY.dy, lessThan(secondY.dy));
    });

    testWidgets('renders empty state for no entries', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewActivity(entries: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('activity-empty')), findsOneWidget);
      expect(find.text('No activity'), findsOneWidget);
    });
  });

  group('VAL-M5-031: Each item renders actor, action, timestamp, content', () {
    testWidgets('renders actor name', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('activity-actor-a1')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('activity-actor-a2')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('activity-actor-a3')),
          findsOneWidget);
    });

    testWidgets('renders action label', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('activity-action-a1')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('activity-action-a2')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('activity-action-a3')),
          findsOneWidget);
    });

    testWidgets('renders formatted timestamp', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('activity-timestamp-a1')),
          findsOneWidget);
      expect(find.text('2024-01-01 10:00'), findsOneWidget);
      expect(find.text('2024-01-02 14:30'), findsOneWidget);
      expect(find.text('2024-01-03 09:15'), findsOneWidget);
    });

    testWidgets('renders optional detail body when present', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Initial creation'), findsOneWidget);
      expect(find.text('Approved with comments'), findsOneWidget);
    });

    testWidgets('renders item without detail without crashing',
        (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('activity-detail-a2')),
          findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('VAL-M5-032: Item interaction emits selection with id and meta', () {
    testWidgets('tapping an item fires onItemSelect with id and meta',
        (tester) async {
      String? capturedId;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(harness(
        BcViewActivity(
          entries: entries,
          onItemSelect: (id, meta) {
            capturedId = id;
            capturedMeta = meta;
            callCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(
          find.byKey(const ValueKey<String>('activity-item-a3')));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedId, 'a3');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
      expect(capturedMeta!.reason, BcChangeReason.select);
    });

    testWidgets('selected item reflects selected visual state', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(
          entries: entries,
          selectedId: 'a3',
        ),
      ));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.descendant(
        of: find.byKey(const ValueKey<String>('activity-item-a3')),
        matching: find.byType(Container),
      ).first);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('in single-select, previously selected item is deselected',
        (tester) async {
      late void Function(void Function()) setStateProxy;
      String? currentSelected;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateProxy = setState;
            return harness(
              BcViewActivity(
                entries: entries,
                selectedId: currentSelected,
                onItemSelect: (id, meta) {
                  setStateProxy(() {
                    currentSelected = id;
                  });
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
          find.byKey(const ValueKey<String>('activity-item-a1')));
      await tester.pumpAndSettle();
      expect(currentSelected, 'a1');

      await tester.tap(
          find.byKey(const ValueKey<String>('activity-item-a2')));
      await tester.pumpAndSettle();
      expect(currentSelected, 'a2');
    });

    testWidgets('uncontrolled selection updates internal state', (tester) async {
      await tester.pumpWidget(harness(
        BcViewActivity(entries: entries),
      ));
      await tester.pumpAndSettle();

      await tester.tap(
          find.byKey(const ValueKey<String>('activity-item-a1')));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.descendant(
        of: find.byKey(const ValueKey<String>('activity-item-a1')),
        matching: find.byType(Container),
      ).first);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });
  });
}
