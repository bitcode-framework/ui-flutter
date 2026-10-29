import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_grid_view.dart';

void main() {
  group('BcGridView', () {
    Widget buildHarness({
      List<BcGridViewColumn>? columns,
      List<Map<String, dynamic>>? rows,
      String emptyText = 'No data',
      void Function(Map<String, dynamic> row, int index)? onRowSelect,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcGridView(
            columns: columns ?? const [
              BcGridViewColumn(key: 'name', label: 'Name'),
              BcGridViewColumn(key: 'age', label: 'Age'),
            ],
            rows: rows ?? const [],
            emptyText: emptyText,
            onRowSelect: onRowSelect,
          ),
        ),
      );
    }

    testWidgets('renders header + rows when data present (VAL-A2-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        rows: [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-grid-view')), findsOneWidget);
      expect(find.byKey(const Key('bc-grid-view-header')), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('empty state renders emptyText (VAL-A2-002)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        emptyText: 'No records',
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-grid-view-empty')), findsOneWidget);
      expect(find.text('No records'), findsOneWidget);
    });

    testWidgets('row tap forwards onRowSelect with row + index (VAL-A2-003)',
        (tester) async {
      Map<String, dynamic>? selectedRow;
      int? selectedIndex;
      await tester.pumpWidget(buildHarness(
        rows: [
          {'name': 'Alice', 'age': 30},
        ],
        onRowSelect: (row, index) {
          selectedRow = row;
          selectedIndex = index;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-grid-view-row-0')));
      await tester.pumpAndSettle();
      expect(selectedRow, isNotNull);
      expect(selectedRow!['name'], 'Alice');
      expect(selectedIndex, 0);
    });

    testWidgets('rows have min 44px touch target (VAL-A2-004)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        rows: [{'name': 'A', 'age': 1}],
      ));
      await tester.pumpAndSettle();
      final rowBox = tester.getSize(find.byKey(const Key('bc-grid-view-row-0')));
      expect(rowBox.height, greaterThanOrEqualTo(44.0));
    });
  });
}
