// Charts demo - BcChart (bar, line, pie), BcSparkline (line, bar), BcProgress, BcKpi.
library charts_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class ChartsSection extends StatelessWidget {
  const ChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Charts',
          subtitle: 'ECharts-backed visualization (ADR-015), sparklines, progress, and KPI cards.',
        ),

        // -- BcChart (Bar) --
        DemoCard(
          title: 'BcChart - Bar',
          description: 'Multi-series bar chart with categories and legend.',
          child: BcChart(
            type: BcChartType.bar,
            chartTitle: 'Quarterly Revenue',
            height: 280,
            categories: const ['Q1', 'Q2', 'Q3', 'Q4'],
            series: const [
              BcChartSeries(name: '2024', data: [120, 180, 150, 200]),
              BcChartSeries(name: '2025', data: [150, 210, 190, 240]),
            ],
          ),
        ),

        // -- BcChart (Line) --
        DemoCard(
          title: 'BcChart - Line',
          description: 'Multi-series line chart for trend visualization.',
          child: BcChart(
            type: BcChartType.line,
            chartTitle: 'Monthly Active Users',
            height: 280,
            categories: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            series: const [
              BcChartSeries(name: 'Web', data: [820, 932, 901, 934, 1290, 1330]),
              BcChartSeries(name: 'Mobile', data: [620, 732, 701, 734, 1090, 1130]),
            ],
          ),
        ),

        // -- BcChart (Pie) --
        DemoCard(
          title: 'BcChart - Pie',
          description: 'Pie chart from single-series items.',
          child: BcChart(
            type: BcChartType.pie,
            chartTitle: 'Traffic Sources',
            height: 280,
            items: const [
              BcChartItem(name: 'Direct', value: 335),
              BcChartItem(name: 'Search', value: 679),
              BcChartItem(name: 'Social', value: 548),
              BcChartItem(name: 'Email', value: 214),
              BcChartItem(name: 'Other', value: 175),
            ],
          ),
        ),

        // -- BcSparkline --
        DemoCard(
          title: 'BcSparkline',
          description: 'Compact inline trend charts (line and bar variants).',
          child: BcYStack(
            gap: 16,
            children: [
              _sparklineRow(
                label: 'Line (default)',
                sparkline: const BcSparkline(
                  data: [4, 8, 6, 12, 9, 15, 11, 18],
                  width: 160,
                  height: 32,
                  type: BcSparklineType.line,
                  showDot: true,
                ),
              ),
              _sparklineRow(
                label: 'Line (colored)',
                sparkline: const BcSparkline(
                  data: [10, 4, 8, 6, 12, 9, 15, 11],
                  width: 160,
                  height: 32,
                  type: BcSparklineType.line,
                  color: BcTheme.success,
                ),
              ),
              _sparklineRow(
                label: 'Bar',
                sparkline: const BcSparkline(
                  data: [4, 8, 6, 12, 9, 15, 11, 18],
                  width: 160,
                  height: 32,
                  type: BcSparklineType.bar,
                ),
              ),
            ],
          ),
        ),
        // -- BcProgress --
        DemoCard(
          title: 'BcProgress',
          description: 'Deterministic progress bar with variants and label.',
          child: BcYStack(
            gap: 16,
            children: [
              const BcProgress(value: 40, max: 100, showLabel: true, label: 'Uploading'),
              const BcProgress(value: 75, max: 100, variant: BcProgressVariant.success),
              const BcProgress(value: 90, max: 100, variant: BcProgressVariant.warning, striped: true),
              const BcProgress(value: 30, max: 100, variant: BcProgressVariant.destructive, size: BcComponentSize.sm),
              const BcProgress(value: 60, max: 100, variant: BcProgressVariant.defaultVariant, size: BcComponentSize.lg),
            ],
          ),
        ),

        // -- BcKpi --
        DemoCard(
          title: 'BcKpi',
          description: 'Key performance indicator card with trend and icon.',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.start,
            children: [
              Expanded(
                child: const BcKpi(
                  title: 'Revenue',
                  value: 123456,
                  subtitle: 'vs last month',
                  trend: BcStatisticTrend.up,
                  trendValue: '+5.4%',
                  icon: Icons.trending_up,
                ),
              ),
              Expanded(
                child: const BcKpi(
                  title: 'Churn',
                  value: '2.1%',
                  trend: BcStatisticTrend.down,
                  trendValue: '-0.3%',
                  icon: Icons.trending_down,
                  color: BcTheme.destructive,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sparklineRow({required String label, required Widget sparkline}) {
    return BcXStack(
      gap: 16,
      crossAxisAlignment: BcXStackAlign.center,
      children: [
        SizedBox(width: 120, child: Text(label)),
        sparkline,
      ],
    );
  }
}