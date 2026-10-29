// Golden-fixture parity tests for the Dart chart-option factory.
//
// These tests load `test/fixtures/chart-options/golden-fixtures.json` (captured
// from the TypeScript `buildChartOption()` in
// `packages/ui/src/contracts/chart-option/factory.ts`) and assert that the Dart
// port produces structurally identical ECharts option JSON for the same inputs.
//
// Per the chart-parity skill:
// - Key ordering does NOT matter (DeepCollectionEquality is order-insensitive
//   for maps).
// - `undefined` keys on the TS side are ABSENT in the Dart output (never
//   `null`), so a key present in one and absent in the other fails the
//   comparison — exactly what we want.
//
// The factory is a pure function (no Flutter/widget deps), so these run as
// plain `test()` blocks — no widget binding required (XS-002).
import 'dart:convert';
import 'dart:io';

import 'package:bc_ui_flutter/src/core/chart/chart_contract.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deep, order-insensitive equality for nested maps/lists.
const _eq = DeepCollectionEquality();

/// Standard single-series items used by most fixtures.
const List<Map<String, Object?>> _items = [
  {'name': 'A', 'value': 10},
  {'name': 'B', 'value': 20},
  {'name': 'C', 'value': 30},
];

/// Multi-series payload used by stacked / multiseries / mixed fixtures.
Map<String, Object?> _multiSeriesData() {
  return {
    'categories': ['Q1', 'Q2', 'Q3'],
    'series': [
      {
        'name': 'S1',
        'data': [10, 20, 30],
      },
      {
        'name': 'S2',
        'data': [15, 25, 35],
      },
    ],
  };
}

/// The canonical default context for "basic" fixtures.
BuildOptionContext _ctx(
  BcChartType type, {
  Object? data,
  String? chartTitle = 'Chart',
  bool legend = true,
  bool tooltipEnabled = true,
  bool animate = true,
  bool toolbox = false,
  bool dataZoom = false,
  List<String>? colors,
  Map<String, Object?>? options,
}) {
  return BuildOptionContext(
    type: type,
    data: data ?? _items,
    colors: colors ?? DEFAULT_PALETTE,
    chartTitle: chartTitle,
    legend: legend,
    tooltipEnabled: tooltipEnabled,
    animate: animate,
    toolbox: toolbox,
    dataZoom: dataZoom,
    options: options,
  );
}

/// Loads the golden fixtures map: `{ fixtureId: expectedOption }`.
Map<String, dynamic> _loadFixtures() {
  final file = File('test/fixtures/chart-options/golden-fixtures.json');
  final raw = file.readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

void main() {
  final fixtures = _loadFixtures();

  /// Asserts the Dart factory output for [ctx] deep-equals the golden
  /// [expected] map. Produces a readable diff-style failure message.
  void expectParity(String id, BuildOptionContext ctx) {
    final expected = fixtures[id] as Map<String, dynamic>;
    final actual = buildChartOption(ctx);
    expect(
      _eq.equals(actual, expected),
      isTrue,
      reason: [
        'Fixture "$id" parity failure.',
        '--- expected (TS) ---',
        const JsonEncoder.withIndent('  ').convert(expected),
        '--- actual (Dart) ---',
        const JsonEncoder.withIndent('  ').convert(actual),
      ].join('\n'),
    );
  }

  group('BC_CHART_TYPES', () {
    test('contains exactly 26 unified chart variants', () {
      expect(BcChartType.bcChartTypes.length, 26);
    });

    test('matches the TS canonical list (order + names)', () {
      final expected = <String>[
        'area',
        'bar',
        'boxplot',
        'candlestick',
        'custom',
        'funnel',
        'gauge',
        'graph',
        'heatmap',
        'kpi',
        'line',
        'mixed',
        'parallel',
        'pictorialbar',
        'pie',
        'pivot',
        'polar',
        'progress',
        'radar',
        'sankey',
        'scatter',
        'scorecard',
        'sunburst',
        'themeriver',
        'tree',
        'treemap',
      ];
      final actual = BcChartType.bcChartTypes.map((t) => t.name).toList();
      expect(actual, expected);
    });

    test('doughnut is NOT in the canonical 26 (maps to pie)', () {
      expect(
        BcChartType.bcChartTypes.map((t) => t.name),
        isNot(contains('doughnut')),
      );
      expect(BcChartType.fromName('doughnut'), BcChartType.pie);
    });
  });

  group('buildChartOption: golden-fixture parity per type', () {
    test('bar_basic', () => expectParity('bar_basic', _ctx(BcChartType.bar)));

    test('bar_horizontal', () {
      expectParity(
        'bar_horizontal',
        _ctx(BcChartType.bar, options: {'horizontal': true}),
      );
    });

    test('bar_stacked', () {
      expectParity(
        'bar_stacked',
        _ctx(
          BcChartType.bar,
          data: _multiSeriesData(),
          options: {'stacked': true},
        ),
      );
    });

    test('bar_multiseries', () {
      expectParity(
        'bar_multiseries',
        _ctx(BcChartType.bar, data: _multiSeriesData()),
      );
    });

    test('line_basic', () {
      expectParity('line_basic', _ctx(BcChartType.line));
    });

    test('line_multiseries', () {
      // line_multiseries uses the same multi-series payload; golden built with
      // categories Q1/Q2/Q3 and two line series.
      expectParity(
        'line_multiseries',
        _ctx(BcChartType.line, data: _multiSeriesData()),
      );
    });

    test('area_basic', () {
      expectParity('area_basic', _ctx(BcChartType.area));
    });

    test('scatter_basic', () {
      expectParity('scatter_basic', _ctx(BcChartType.scatter));
    });

    test('pie_basic', () {
      expectParity('pie_basic', _ctx(BcChartType.pie));
    });

    test('funnel_basic', () {
      expectParity('funnel_basic', _ctx(BcChartType.funnel));
    });

    test('gauge_basic', () {
      expectParity('gauge_basic', _ctx(BcChartType.gauge));
    });

    test('progress_basic', () {
      expectParity('progress_basic', _ctx(BcChartType.progress));
    });

    test('scorecard_basic', () {
      expectParity('scorecard_basic', _ctx(BcChartType.scorecard));
    });

    test('kpi_basic', () {
      expectParity('kpi_basic', _ctx(BcChartType.kpi));
    });

    test('radar_basic', () {
      expectParity('radar_basic', _ctx(BcChartType.radar));
    });

    test('heatmap_basic', () {
      expectParity('heatmap_basic', _ctx(BcChartType.heatmap));
    });

    test('candlestick_basic', () {
      expectParity('candlestick_basic', _ctx(BcChartType.candlestick));
    });

    test('boxplot_basic', () {
      expectParity('boxplot_basic', _ctx(BcChartType.boxplot));
    });

    test('graph_basic', () {
      expectParity('graph_basic', _ctx(BcChartType.graph));
    });

    test('sankey_basic', () {
      expectParity('sankey_basic', _ctx(BcChartType.sankey));
    });

    test('treemap_basic', () {
      expectParity('treemap_basic', _ctx(BcChartType.treemap));
    });

    test('tree_basic', () {
      expectParity('tree_basic', _ctx(BcChartType.tree));
    });

    test('sunburst_basic', () {
      expectParity('sunburst_basic', _ctx(BcChartType.sunburst));
    });

    test('polar_basic', () {
      expectParity('polar_basic', _ctx(BcChartType.polar));
    });

    test('parallel_basic', () {
      expectParity('parallel_basic', _ctx(BcChartType.parallel));
    });

    test('pictorialbar_basic', () {
      expectParity('pictorialbar_basic', _ctx(BcChartType.pictorialbar));
    });

    test('themeriver_basic', () {
      expectParity('themeriver_basic', _ctx(BcChartType.themeriver));
    });

    test('mixed_multiseries', () {
      expectParity(
        'mixed_multiseries',
        _ctx(BcChartType.mixed, data: _multiSeriesData()),
      );
    });

    test('pivot_basic', () {
      expectParity('pivot_basic', _ctx(BcChartType.pivot));
    });

    test('custom_passthrough (object data returned as-is)', () {
      expectParity(
        'custom_passthrough',
        _ctx(
          BcChartType.custom,
          data: {
            'series': [
              {
                'type': 'line',
                'data': [1, 2, 3],
              },
            ],
          },
          chartTitle: 'Chart',
        ),
      );
    });

    test('parsed_string_data (JSON string parsed then built)', () {
      final parsed = parseChartData(
        '[{"name":"X","value":30},{"name":"Y","value":70}]',
      );
      expectParity('parsed_string_data', _ctx(BcChartType.pie, data: parsed));
    });
  });

  group('buildChartOption: option-flag edge cases (bar)', () {
    test('bar_with_datazoom (dataZoom + toolbox on)', () {
      expectParity(
        'bar_with_datazoom',
        _ctx(BcChartType.bar, dataZoom: true, toolbox: true),
      );
    });

    test('bar_no_legend (legend off)', () {
      expectParity('bar_no_legend', _ctx(BcChartType.bar, legend: false));
    });

    test('bar_no_tooltip (tooltip off)', () {
      expectParity(
        'bar_no_tooltip',
        _ctx(BcChartType.bar, tooltipEnabled: false),
      );
    });

    test('bar_custom_colors (explicit color array)', () {
      expectParity(
        'bar_custom_colors',
        _ctx(BcChartType.bar, colors: ['#ff0000', '#00ff00', '#0000ff']),
      );
    });

    test('bar_no_title (chartTitle null)', () {
      expectParity('bar_no_title', _ctx(BcChartType.bar, chartTitle: null));
    });
  });

  group('buildChartOption: structural invariants (CP-015, XS-003)', () {
    test('every registered type returns a non-null Map', () {
      for (final type in BcChartType.bcChartTypes) {
        final opt = buildChartOption(_ctx(type));
        expect(opt, isA<Map<String, Object?>>(), reason: '$type returned null');
      }
    });

    test('every type except custom includes the animation field', () {
      for (final type in BcChartType.bcChartTypes) {
        final opt = buildChartOption(_ctx(type));
        if (type == BcChartType.custom) continue;
        expect(
          opt.containsKey('animation'),
          isTrue,
          reason: '$type missing animation field',
        );
      }
    });

    test('custom passthrough omits animation when data is an object', () {
      final opt = buildChartOption(
        _ctx(BcChartType.custom, data: {'series': <Map<String, Object?>>[]}),
      );
      expect(opt.containsKey('animation'), isFalse);
    });

    test('default (unknown) type falls back to single-series bar', () {
      // fromName('unknown') -> bar; default switch branch builds single-series.
      final type = BcChartType.fromName('unknown');
      expect(type, BcChartType.bar);
      final opt = buildChartOption(_ctx(type));
      final series = opt['series'] as List;
      expect((series.first as Map)['type'], 'bar');
    });

    test('area series carry areaStyle', () {
      final opt = buildChartOption(_ctx(BcChartType.area));
      final series = opt['series'] as List;
      expect((series.first as Map).containsKey('areaStyle'), isTrue);
    });

    test('stacked bar series carry stack=total; non-stacked omit stack', () {
      final stacked = buildChartOption(
        _ctx(
          BcChartType.bar,
          data: _multiSeriesData(),
          options: {'stacked': true},
        ),
      );
      final stackedSeries = stacked['series'] as List;
      expect((stackedSeries.first as Map)['stack'], 'total');

      final plain = buildChartOption(_ctx(BcChartType.bar));
      final plainSeries = plain['series'] as List;
      expect((plainSeries.first as Map).containsKey('stack'), isFalse);
    });

    test('horizontal bar swaps xAxis/yAxis types', () {
      final opt = buildChartOption(
        _ctx(BcChartType.bar, options: {'horizontal': true}),
      );
      expect((opt['xAxis'] as Map)['type'], 'value');
      expect((opt['yAxis'] as Map)['type'], 'category');
    });

    test('mixed series alternate bar/line types', () {
      final opt = buildChartOption(
        _ctx(BcChartType.mixed, data: _multiSeriesData()),
      );
      final series = (opt['series'] as List).cast<Map>();
      expect(series[0]['type'], 'bar');
      expect(series[1]['type'], 'line');
    });

    test('pie/funnel are single-series item charts', () {
      final pie = buildChartOption(_ctx(BcChartType.pie));
      final funnel = buildChartOption(_ctx(BcChartType.funnel));
      expect(((pie['series'] as List).first as Map)['type'], 'pie');
      expect(((funnel['series'] as List).first as Map)['type'], 'funnel');
    });
  });
}
