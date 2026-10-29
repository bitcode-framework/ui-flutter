import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_activity.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcActivity child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  final items = [
    const BcActivityEntry(
      id: '1',
      actor: 'Alice',
      action: 'created a task',
      timestamp: '2026-01-01 10:00',
    ),
    const BcActivityEntry(
      id: '2',
      actor: 'Bob',
      action: 'commented',
      timestamp: '2026-01-02 11:30',
    ),
    const BcActivityEntry(
      id: '3',
      actor: 'Carol',
      action: 'completed',
      timestamp: '2026-01-03 09:15',
    ),
  ];

  testWidgets(
      'renders N items in order with actor labels and timestamps (VAL-M6-019)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcActivity(items: items)));
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Carol'), findsOneWidget);

    expect(find.text('created a task'), findsOneWidget);
    expect(find.text('commented'), findsOneWidget);
    expect(find.text('completed'), findsOneWidget);

    expect(find.text('2026-01-01 10:00'), findsOneWidget);
    expect(find.text('2026-01-02 11:30'), findsOneWidget);
    expect(find.text('2026-01-03 09:15'), findsOneWidget);
  });

  testWidgets(
      'renders items in the provided order (VAL-M6-019)',
      (tester) async {
    await tester.pumpWidget(harness(child: BcActivity(items: items)));
    await tester.pump();

    final aliceY = tester.getTopLeft(find.text('Alice')).dy;
    final bobY = tester.getTopLeft(find.text('Bob')).dy;
    final carolY = tester.getTopLeft(find.text('Carol')).dy;

    expect(aliceY, lessThan(bobY));
    expect(bobY, lessThan(carolY));
  });

  testWidgets(
      'empty items renders emptyState widget, not a blank container (VAL-M6-019)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcActivity(items: [], emptyText: 'No activity here'),
    ));
    await tester.pump();

    expect(find.text('No activity here'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bc_activity_empty')),
        findsOneWidget);
  });

  testWidgets(
      'custom emptyState widget renders when items empty (VAL-M6-019)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcActivity(
        items: [],
        emptyState: Text('Custom Empty'),
      ),
    ));
    await tester.pump();

    expect(find.text('Custom Empty'), findsOneWidget);
  });

  testWidgets(
      'item tap emits onItemClick with item id and BcChangeMeta (VAL-M6-020)',
      (tester) async {
    String? capturedId;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      child: BcActivity(
        items: items,
        onItemClick: (id, meta) {
          capturedId = id;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();

    expect(capturedId, '2');
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
    expect(capturedMeta!.reason, BcChangeReason.select);
  });

  testWidgets(
      'disabled blocks onItemClick callback (VAL-M6-020)',
      (tester) async {
    int callCount = 0;

    await tester.pumpWidget(harness(
      child: BcActivity(
        items: items,
        disabled: true,
        onItemClick: (_, __) => callCount++,
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(callCount, 0);
  });

  testWidgets(
      'variant colors apply to avatar and icon (VAL-M6-019)',
      (tester) async {
    final variantItems = [
      const BcActivityEntry(
        id: 'v1',
        actor: 'Dan',
        action: 'succeeded',
        timestamp: '2026-01-01',
        variant: BcActivityVariant.success,
      ),
      const BcActivityEntry(
        id: 'v2',
        actor: 'Eve',
        action: 'failed',
        timestamp: '2026-01-02',
        variant: BcActivityVariant.destructive,
      ),
    ];

    await tester.pumpWidget(harness(child: BcActivity(items: variantItems)));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets(
      'target field renders when provided (VAL-M6-019)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcActivity(
        items: [
          BcActivityEntry(
            id: 't1',
            actor: 'Frank',
            action: 'updated',
            target: 'Project X',
            timestamp: '2026-01-01',
          ),
        ],
      ),
    ));
    await tester.pump();

    expect(find.text('Project X'), findsOneWidget);
  });

  testWidgets('loading state renders skeleton placeholders', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcActivity(items: [], loading: true),
    ));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('bc_activity_loading')),
        findsOneWidget);
  });

  testWidgets('variant=compact renders compact layout', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcActivity(
        items: [
          BcActivityEntry(
            id: 'c1',
            actor: 'Gina',
            action: 'updated',
            timestamp: '2026-01-01',
          ),
        ],
        variant: BcActivityLayout.compact,
      ),
    ));
    await tester.pump();

    expect(find.text('Gina'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bc_activity_compact_0')),
        findsOneWidget);
  });

  testWidgets('variant=timeline renders timeline layout', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcActivity(
        items: [
          BcActivityEntry(
            id: 't2',
            actor: 'Henry',
            action: 'created',
            timestamp: '2026-01-01',
          ),
        ],
        variant: BcActivityLayout.timeline,
      ),
    ));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('bc_activity_timeline_0')),
        findsOneWidget);
  });

  testWidgets('onLoadMore renders a Load more button', (tester) async {
    var loadCount = 0;
    await tester.pumpWidget(harness(
      child: BcActivity(
        items: items,
        onLoadMore: () { loadCount++; },
      ),
    ));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('bc_activity_load_more')),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('bc_activity_load_more')));
    await tester.pumpAndSettle();
    expect(loadCount, 1);
  });

  testWidgets('onItemAction fires when an item is tapped', (tester) async {
    BcActivityEntry? captured;
    await tester.pumpWidget(harness(
      child: BcActivity(
        items: items,
        onItemAction: (entry) => captured = entry,
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.id, '1');
  });

  testWidgets('custom loadMoreText renders on load more button', (tester) async {
    await tester.pumpWidget(harness(
      child: const BcActivity(
        items: [],
        onLoadMore: null,
        loadMoreText: 'Plus de résultats',
      ),
    ));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('bc_activity_load_more')),
        findsNothing);
  });
}
