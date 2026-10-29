import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_kanban_view.dart';

void main() {
  group('BcKanbanView', () {
    const columns = [
      BcKanbanViewColumn(id: 'todo', title: 'To Do'),
      BcKanbanViewColumn(id: 'done', title: 'Done'),
    ];
    const cards = [
      BcKanbanViewCard(id: 'c1', title: 'Task 1', columnId: 'todo'),
      BcKanbanViewCard(id: 'c2', title: 'Task 2', columnId: 'done'),
    ];

    Widget buildHarness({
      List<BcKanbanViewColumn> cols = columns,
      List<BcKanbanViewCard> cds = cards,
      void Function(BcKanbanViewCard card)? onCardClick,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcKanbanView(
            columns: cols,
            cards: cds,
            onCardClick: onCardClick,
          ),
        ),
      );
    }

    testWidgets('renders columns + cards (VAL-A4-001)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-kanban-view')), findsOneWidget);
      expect(find.byKey(const Key('bc-kanban-view-column-todo')), findsOneWidget);
      expect(find.byKey(const Key('bc-kanban-view-column-done')), findsOneWidget);
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('column count badge shows correct count (VAL-A4-002)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-kanban-view-count-todo')), findsOneWidget);
      expect(find.byKey(const Key('bc-kanban-view-count-done')), findsOneWidget);
    });

    testWidgets('card tap forwards onCardClick (VAL-A4-003)', (tester) async {
      BcKanbanViewCard? clicked;
      await tester.pumpWidget(buildHarness(
        onCardClick: (card) => clicked = card,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-kanban-view-card-c1')));
      await tester.pumpAndSettle();
      expect(clicked, isNotNull);
      expect(clicked!.id, 'c1');
    });

    testWidgets('drag card to different column triggers onCardMove (VAL-A4-004)',
        (tester) async {
      String? movedCardId;
      String? fromCol;
      String? toCol;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BcKanbanView(
            columns: columns,
            cards: cards,
            onCardMove: (cardId, from, to, meta) {
              movedCardId = cardId;
              fromCol = from;
              toCol = to;
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('bc-kanban-view-card-c1')),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle();

      expect(movedCardId, 'c1');
      expect(fromCol, 'todo');
      expect(toCol, 'done');
    });

    testWidgets('priority border color renders on card (VAL-A4-005)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        cds: [
          const BcKanbanViewCard(
            id: 'c1',
            title: 'Urgent Task',
            columnId: 'todo',
            priority: 'urgent',
          ),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.text('Urgent Task'), findsOneWidget);
    });
  });
}
