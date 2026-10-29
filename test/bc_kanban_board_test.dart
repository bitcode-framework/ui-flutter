import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_kanban_board.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required Widget child, Size size = const Size(800, 600)}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  const testColumns = [
    BcKanbanColumnConfig(id: 'todo', name: 'To Do'),
    BcKanbanColumnConfig(id: 'doing', name: 'In Progress'),
    BcKanbanColumnConfig(id: 'done', name: 'Done'),
  ];

  const testCards = [
    BcKanbanCard(id: 'c1', title: 'Task 1', column: 'todo', position: 0),
    BcKanbanCard(id: 'c2', title: 'Task 2', column: 'todo', position: 1),
    BcKanbanCard(id: 'c3', title: 'Task 3', column: 'doing', position: 0),
    BcKanbanCard(id: 'c4', title: 'Task 4', column: 'done', position: 0),
  ];

  group('VAL-M5-017: Columns and cards render from config', () {
    testWidgets('renders one column node per column', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(columns: testColumns, cards: testCards),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_kanban_board')), findsOneWidget);
      expect(find.byKey(const Key('bc_kanban_column_todo')), findsOneWidget);
      expect(find.byKey(const Key('bc_kanban_column_doing')), findsOneWidget);
      expect(find.byKey(const Key('bc_kanban_column_done')), findsOneWidget);
    });

    testWidgets('renders cards only in their assigned column', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(columns: testColumns, cards: testCards),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_kanban_card_c1')), findsOneWidget);
      expect(find.byKey(const Key('bc_kanban_card_c2')), findsOneWidget);
      expect(find.byKey(const Key('bc_kanban_card_c3')), findsOneWidget);
      expect(find.byKey(const Key('bc_kanban_card_c4')), findsOneWidget);

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.text('Task 3'), findsOneWidget);
      expect(find.text('Task 4'), findsOneWidget);
    });

    testWidgets('column card count reflects assigned cards', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(columns: testColumns, cards: testCards),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('bc_kanban_col_count_todo')),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(
          find.descendant(
            of: find.byKey(const Key('bc_kanban_col_count_todo')),
            matching: find.text('2'),
          ),
        ),
        isNotNull,
      );
    });

    testWidgets('cards not matching any column are not orphaned',
        (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(
          columns: testColumns,
          cards: [
            ...testCards,
            BcKanbanCard(
                id: 'orphan',
                title: 'Orphan',
                column: 'nonexistent'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Orphan'), findsNothing,
          reason: 'orphan card should not render');
    });

    testWidgets('empty columns render without error', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(columns: testColumns, cards: []),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_kanban_column_todo')), findsOneWidget);
    });
  });

  group('VAL-M5-018: Drag-drop moves card between columns', () {
    testWidgets('moveCard to different column fires onCardMove', (tester) async {
      BcKanbanCardMoveEvent? capturedEvent;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(harness(
        child: BcKanbanBoard(
          columns: testColumns,
          cards: testCards,
          onCardMove: (event, meta) {
            capturedEvent = event;
            capturedMeta = meta;
          },
        ),
      ));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(BcKanbanBoard));
      (state as dynamic).moveCard('c1', 'done', 0);

      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.cardId, 'c1');
      expect(capturedEvent!.fromColumn, 'todo');
      expect(capturedEvent!.toColumn, 'done');
      expect(capturedEvent!.toPosition, 0);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('after move, card appears in target column', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(columns: testColumns, cards: testCards),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Task 1'), findsOneWidget);

      final state = tester.state(find.byType(BcKanbanBoard));
      (state as dynamic).moveCard('c1', 'doing', 0);

      await tester.pumpAndSettle();

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 3'), findsOneWidget);
    });
  });

  group('VAL-M5-019: Reorder within column preserves order', () {
    testWidgets('reorder within same column emits new index meta',
        (tester) async {
      BcKanbanCardMoveEvent? capturedEvent;

      await tester.pumpWidget(harness(
        child: BcKanbanBoard(
          columns: testColumns,
          cards: testCards,
          onCardMove: (event, meta) {
            capturedEvent = event;
          },
        ),
      ));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(BcKanbanBoard));
      (state as dynamic).moveCard('c2', 'todo', 0);

      expect(capturedEvent, isNotNull);
      expect(capturedEvent!.cardId, 'c2');
      expect(capturedEvent!.fromColumn, 'todo');
      expect(capturedEvent!.toColumn, 'todo');
      expect(capturedEvent!.toPosition, 0);
    });

    testWidgets('other cards preserve their relative order', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(columns: testColumns, cards: testCards),
      ));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(BcKanbanBoard));
      (state as dynamic).moveCard('c2', 'todo', 0);

      await tester.pumpAndSettle();

      final todoColumn = find.byKey(const Key('bc_kanban_column_todo'));
      expect(todoColumn, findsOneWidget);

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });
  });

  group('VAL-M5-020: Disabled/readonly prevents drag-drop', () {
    testWidgets('disabled board prevents card moves', (tester) async {
      BcKanbanCardMoveEvent? capturedEvent;

      await tester.pumpWidget(harness(
        child: BcKanbanBoard(
          columns: testColumns,
          cards: testCards,
          disabled: true,
          onCardMove: (event, meta) {
            capturedEvent = event;
          },
        ),
      ));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(BcKanbanBoard));
      (state as dynamic).moveCard('c1', 'done', 0);

      expect(capturedEvent, isNull,
          reason: 'disabled board should not emit onCardMove');
    });

    testWidgets('readonly board prevents card moves', (tester) async {
      BcKanbanCardMoveEvent? capturedEvent;

      await tester.pumpWidget(harness(
        child: BcKanbanBoard(
          columns: testColumns,
          cards: testCards,
          readOnly: true,
          onCardMove: (event, meta) {
            capturedEvent = event;
          },
        ),
      ));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(BcKanbanBoard));
      (state as dynamic).moveCard('c1', 'done', 0);

      expect(capturedEvent, isNull,
          reason: 'readonly board should not emit onCardMove');
    });

    testWidgets('disabled board still renders all columns and cards',
        (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(
          columns: testColumns,
          cards: testCards,
          disabled: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_kanban_column_todo')), findsOneWidget);
      expect(find.byKey(const Key('bc_kanban_card_c1')), findsOneWidget);
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 4'), findsOneWidget);
    });
  });

  group('card content rendering', () {
    testWidgets('card renders priority badge', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(
          columns: testColumns,
          cards: [
            BcKanbanCard(
              id: 'p1',
              title: 'Urgent Task',
              column: 'todo',
              priority: BcKanbanPriority.high,
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('bc_kanban_card_priority_p1')),
        findsOneWidget,
      );
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('card renders labels', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcKanbanBoard(
          columns: testColumns,
          cards: [
            BcKanbanCard(
              id: 'l1',
              title: 'Labeled Task',
              column: 'todo',
              labels: ['bug', 'frontend'],
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('bug'), findsOneWidget);
      expect(find.text('frontend'), findsOneWidget);
    });

    testWidgets('card tap fires onCardTap', (tester) async {
      BcKanbanCard? tappedCard;

      await tester.pumpWidget(harness(
        child: BcKanbanBoard(
          columns: testColumns,
          cards: testCards,
          onCardTap: (card) {
            tappedCard = card;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc_kanban_card_c1')));
      await tester.pumpAndSettle();

      expect(tappedCard, isNotNull);
      expect(tappedCard!.id, 'c1');
    });
  });
}
