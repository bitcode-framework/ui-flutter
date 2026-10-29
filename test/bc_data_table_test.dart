import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_data_table.dart';

void main() {
  testWidgets('BcDataTable renders headers and rows', (tester) async {
    final rows = [
      {'name': 'Alice', 'age': 30},
      {'name': 'Bob', 'age': 25},
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcDataTable<Map<String, dynamic>>(
            columns: [
              BcDataColumn(
                label: 'Name',
                cellBuilder: (_, row) => Text(row['name'] as String),
              ),
              BcDataColumn(
                label: 'Age',
                numeric: true,
                cellBuilder: (_, row) => Text(row['age'].toString()),
              ),
            ],
            rows: rows,
          ),
        ),
      ),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
  });

  testWidgets('BcDataTable shows empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BcDataTable<Map<String, dynamic>>(
            columns: [
              BcDataColumn(
                label: 'Name',
                cellBuilder: (_, row) => Text(row['name'] as String),
              ),
            ],
            rows: const [],
            emptyState: const Center(child: Text('No data')),
          ),
        ),
      ),
    );

    expect(find.text('No data'), findsOneWidget);
  });
}
