import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_dashboard.dart';

void main() {
  group('BcDashboard', () {
    Widget buildHarness({
      List<BcDashboardWidget> widgets = const [],
      int columns = 3,
      bool loading = false,
      String emptyText = 'No widgets',
      Widget Function(BcDashboardWidget)? renderWidget,
      void Function(BcDashboardWidget, dynamic)? onWidgetClick,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BcDashboard(
              widgets: widgets,
              columns: columns,
              loading: loading,
              emptyText: emptyText,
              renderWidget: renderWidget,
              onWidgetClick: onWidgetClick,
            ),
          ),
        ),
      );
    }

    testWidgets('renders widgets in grid (VAL-A6-001)', (tester) async {
      await tester.pumpWidget(buildHarness(
        widgets: [
          const BcDashboardWidget(id: 'w1', kind: BcDashboardWidgetKind.stat, title: 'Revenue'),
          const BcDashboardWidget(id: 'w2', kind: BcDashboardWidgetKind.chart, title: 'Sales'),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-dashboard')), findsOneWidget);
      expect(find.byKey(const Key('bc-dashboard-widget-w1')), findsOneWidget);
      expect(find.byKey(const Key('bc-dashboard-widget-w2')), findsOneWidget);
    });

    testWidgets('empty state renders emptyText (VAL-A6-002)', (tester) async {
      await tester.pumpWidget(buildHarness(
        emptyText: 'No data available',
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-dashboard-empty')), findsOneWidget);
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('loading state renders skeleton (VAL-A6-003)', (tester) async {
      await tester.pumpWidget(buildHarness(loading: true));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-dashboard-loading')), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('default placeholder shows kind + title (VAL-A6-004)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        widgets: [
          const BcDashboardWidget(id: 'w1', kind: BcDashboardWidgetKind.stat, title: 'KPI'),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-dashboard-widget-body-w1')), findsOneWidget);
      expect(find.textContaining('[stat]'), findsOneWidget);
    });

    testWidgets('widget tap forwards onWidgetClick (VAL-A6-005)', (tester) async {
      String? clickedId;
      await tester.pumpWidget(buildHarness(
        widgets: [
          const BcDashboardWidget(id: 'w1', kind: BcDashboardWidgetKind.stat, title: 'X'),
        ],
        onWidgetClick: (widget, meta) => clickedId = widget.id,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-dashboard-widget-w1')));
      await tester.pumpAndSettle();
      expect(clickedId, 'w1');
    });

    testWidgets('custom renderWidget overrides placeholder (VAL-A6-006)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        widgets: [
          const BcDashboardWidget(id: 'w1', kind: BcDashboardWidgetKind.custom),
        ],
        renderWidget: (w) => const Text('Custom Widget Body'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Custom Widget Body'), findsOneWidget);
    });
  });
}
