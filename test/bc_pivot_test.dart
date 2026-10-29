import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_pivot.dart';

void main() {
  group('BcPivot', () {
    BcPivotResult sampleResult() {
      return const BcPivotResult(
        rowHeaders: ['North', 'South'],
        colHeaders: ['Widget', 'Gadget'],
        cells: [
          [
            [150.0],
            [200.0],
          ],
          [
            [300.0],
            [150.0],
          ],
        ],
        rowTotals: [
          [350.0],
          [450.0],
        ],
        colTotals: [
          [450.0],
          [350.0],
        ],
        grandTotal: [800.0],
        valueFields: [
          BcPivotValueField(field: 'amount', agg: BcPivotAggFunc.sum),
        ],
      );
    }

    Widget buildHarness({
      BcPivotResult? result,
      String? title,
      bool showTotals = true,
      bool showGrandTotal = true,
      String noDataText = 'No data to display',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcPivot(
              rows: const ['region'],
              cols: const ['product'],
              values: const [
                BcPivotValueField(field: 'amount', agg: BcPivotAggFunc.sum),
              ],
              result: result,
              title: title,
              showTotals: showTotals,
              showGrandTotal: showGrandTotal,
              noDataText: noDataText,
            ),
          ),
        ),
      );
    }

    testWidgets('renders pivot table with data (VAL-PIVOT-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness(result: sampleResult()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-pivot-table')), findsOneWidget);
      expect(find.text('North'), findsWidgets);
      expect(find.text('South'), findsWidgets);
      expect(find.text('Widget'), findsWidgets);
      expect(find.text('Gadget'), findsWidgets);
    });

    testWidgets('shows no-data state when result is null (VAL-PIVOT-002)',
        (tester) async {
      await tester.pumpWidget(buildHarness(result: null));
      await tester.pumpAndSettle();

      expect(find.text('No data to display'), findsOneWidget);
    });

    testWidgets('shows no-data state when result is empty (VAL-PIVOT-003)',
        (tester) async {
      const emptyResult = BcPivotResult(
        rowHeaders: [],
        colHeaders: [],
        cells: [],
        rowTotals: [],
        colTotals: [],
        grandTotal: [],
        valueFields: [],
      );
      await tester.pumpWidget(buildHarness(result: emptyResult));
      await tester.pumpAndSettle();

      expect(find.text('No data to display'), findsOneWidget);
    });

    testWidgets('grand total row renders when showGrandTotal is true',
        (tester) async {
      await tester.pumpWidget(buildHarness(result: sampleResult()));
      await tester.pumpAndSettle();

      expect(find.text('Grand Total'), findsOneWidget);
    });

    testWidgets('grand total row hidden when showGrandTotal is false',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        result: sampleResult(),
        showGrandTotal: false,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Grand Total'), findsNothing);
    });

    testWidgets('title renders when provided', (tester) async {
      await tester.pumpWidget(buildHarness(
        result: sampleResult(),
        title: 'Sales Pivot',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sales Pivot'), findsOneWidget);
    });

    testWidgets('rows are expandable/collapsible on tap', (tester) async {
      await tester.pumpWidget(buildHarness(result: sampleResult()));
      await tester.pumpAndSettle();

      expect(find.text('150'), findsWidgets);

      await tester.tap(find.text('North'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsWidgets);

      await tester.tap(find.text('North'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsWidgets);
    });

    test('BcPivotResult.fromJson parses engine response', () {
      final json = {
        'rowHeaders': ['North', 'South'],
        'colHeaders': ['Widget'],
        'cells': [
          [
            [100.0]
          ],
          [
            [200.0]
          ],
        ],
        'rowTotals': [
          [100.0]
        ],
        'colTotals': [
          [300.0]
        ],
        'grandTotal': [300.0],
        'valueFields': [
          {'field': 'amount', 'agg': 'sum', 'alias': 'sum_amount'}
        ],
      };

      final result = BcPivotResult.fromJson(json);

      expect(result.rowHeaders, ['North', 'South']);
      expect(result.colHeaders, ['Widget']);
      expect(result.cells[0][0][0], 100.0);
      expect(result.cells[1][0][0], 200.0);
      expect(result.grandTotal[0], 300.0);
      expect(result.valueFields.length, 1);
      expect(result.valueFields[0].field, 'amount');
      expect(result.valueFields[0].agg, BcPivotAggFunc.sum);
      expect(result.valueFields[0].alias, 'sum_amount');
    });

    test('BcPivotValueField serializes to JSON', () {
      const vf = BcPivotValueField(
        field: 'qty',
        agg: BcPivotAggFunc.count,
        alias: 'count_qty',
      );
      final json = vf.toJson();

      expect(json['field'], 'qty');
      expect(json['agg'], 'count');
      expect(json['alias'], 'count_qty');
    });

    test('BcPivotAggFunc.fromString maps correctly', () {
      expect(BcPivotAggFunc.fromString('sum'), BcPivotAggFunc.sum);
      expect(BcPivotAggFunc.fromString('count'), BcPivotAggFunc.count);
      expect(BcPivotAggFunc.fromString('avg'), BcPivotAggFunc.avg);
      expect(BcPivotAggFunc.fromString('min'), BcPivotAggFunc.min);
      expect(BcPivotAggFunc.fromString('max'), BcPivotAggFunc.max);
      expect(BcPivotAggFunc.fromString('unknown'), BcPivotAggFunc.sum);
    });

    test('BcPivotResult.isEmpty is true for empty rows', () {
      const empty = BcPivotResult(
        rowHeaders: [],
        colHeaders: [],
        cells: [],
        rowTotals: [],
        colTotals: [],
        grandTotal: [],
        valueFields: [],
      );
      expect(empty.isEmpty, true);
    });

    test('BcPivotResult.isEmpty is false with data', () {
      expect(sampleResult().isEmpty, false);
    });
  });
}
