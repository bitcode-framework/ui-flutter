import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_kpi.dart';
import 'package:bc_ui_flutter/src/components/bc_statistic.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: Center(child: child),
        ),
      ),
    );
  }

  testWidgets('BcKpi renders title and value', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Revenue',
      value: 12345,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('12345'), findsOneWidget);
  });

  testWidgets('BcKpi renders subtitle as statistic caption', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Revenue',
      value: '1.2K',
      subtitle: 'vs last month',
    )));
    await tester.pumpAndSettle();

    expect(find.text('vs last month'), findsOneWidget);
  });

  testWidgets('BcKpi renders trendValue with trend glyph and color', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Sales',
      value: 100,
      trend: BcStatisticTrend.up,
      trendValue: '+5.4%',
    )));
    await tester.pumpAndSettle();

    expect(find.text('+5.4%'), findsOneWidget);
    final trendText = tester.widget<Text>(find.byKey(const Key('bc-kpi-trend')));
    expect(trendText.style?.color, BcTheme.success,
        reason: 'up trend should be success colored');
  });

  testWidgets('BcKpi down trend is destructive colored', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Sales',
      value: 100,
      trend: BcStatisticTrend.down,
      trendValue: '-2.1%',
    )));
    await tester.pumpAndSettle();

    final trendText = tester.widget<Text>(find.byKey(const Key('bc-kpi-trend')));
    expect(trendText.style?.color, BcTheme.destructive);
  });

  testWidgets('BcKpi neutral trend is muted colored', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Sales',
      value: 100,
      trend: BcStatisticTrend.neutral,
      trendValue: '0%',
    )));
    await tester.pumpAndSettle();

    final trendText = tester.widget<Text>(find.byKey(const Key('bc-kpi-trend')));
    expect(trendText.style?.color, BcTheme.mutedForeground);
  });

  testWidgets('BcKpi renders icon chip with tinted background', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Revenue',
      value: 100,
      icon: Icons.trending_up,
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc-kpi-icon')), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });

  testWidgets('BcKpi does not render icon chip when icon null', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Revenue',
      value: 100,
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc-kpi-icon')), findsNothing);
  });

  testWidgets('BcKpi renders inside a card frame (key present)', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Revenue',
      value: 100,
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc-kpi')), findsOneWidget);
  });

  testWidgets('BcKpi composes BcStatistic internally', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Revenue',
      value: 99,
    )));
    await tester.pumpAndSettle();

    expect(find.byType(BcStatistic), findsOneWidget,
        reason: 'BcKpi should compose BcStatistic for value rendering');
  });

  testWidgets('BcKpi renders with only value (minimal props)', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(value: 42)));
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BcKpi exposes merged semantics label', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(
      title: 'Revenue',
      value: 100,
      trendValue: '+5%',
    )));
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(find.byType(BcKpi));
    expect(semantics.label, contains('Revenue'));
    expect(semantics.label, contains('100'));
    expect(semantics.label, contains('+5%'));
  });

  testWidgets('BcKpi renders empty value without assertion', (tester) async {
    await tester.pumpWidget(harness(const BcKpi(title: 'Empty')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Empty'), findsOneWidget);
  });
}