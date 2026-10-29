// ignore_for_file: avoid_dynamic_calls

/// Unit tests for the Dart port of the chart-option helpers
/// (`packages/ui-flutter/lib/src/core/chart/chart_helpers.dart`).
///
/// These mirror the TypeScript `helpers.test.ts` assertions 1:1 and use NO
/// widget binding — the helpers are pure functions (XS-002).
library;

import 'dart:convert';

import 'package:bc_ui_flutter/src/core/chart/chart_helpers.dart';
import 'package:bc_ui_flutter/src/core/chart/chart_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isSingleSeries', () {
    test('detects [{name, value}] shape', () {
      expect(
        isSingleSeries(<Map<String, Object>>[
          {'name': 'A', 'value': 10},
        ]),
        isTrue,
      );
    });

    test('empty array is not single-series', () {
      expect(isSingleSeries(<dynamic>[]), isFalse);
    });

    test('non-numeric value is not single-series', () {
      expect(
        isSingleSeries(<Map<String, Object>>[
          {'name': 'A', 'value': 'x'},
        ]),
        isFalse,
      );
    });

    test('non-string name is not single-series', () {
      expect(
        isSingleSeries(<Map<String, Object>>[
          {'name': 5, 'value': 10},
        ]),
        isFalse,
      );
    });

    test('map is not single-series', () {
      expect(isSingleSeries(<String, Object>{}), isFalse);
    });
  });

  group('isMultiSeries', () {
    test('detects {categories, series} shape', () {
      expect(
        isMultiSeries(<String, Object>{
          'categories': <String>['Q1'],
          'series': <Map<String, Object>>[
            {
              'name': 'A',
              'data': <int>[1],
            },
          ],
        }),
        isTrue,
      );
    });

    test('array is not multi-series', () {
      expect(isMultiSeries(<dynamic>[]), isFalse);
    });

    test('categories non-array is not multi-series', () {
      expect(
        isMultiSeries(<String, Object>{
          'categories': 'x',
          'series': <dynamic>[],
        }),
        isFalse,
      );
    });
  });

  group('parseColors', () {
    test('comma-separated string -> array', () {
      expect(parseColors('#fff, #000 , red'), ['#fff', '#000', 'red']);
    });

    test('empty/undefined -> default token palette', () {
      expect(parseColors().length, DEFAULT_PALETTE.length);
      expect(parseColors('').length, DEFAULT_PALETTE.length);
    });

    test('array passthrough', () {
      expect(parseColors(['#a', '#b']), ['#a', '#b']);
      // Empty array falls back to default to avoid blank charts.
      expect(parseColors(<String>[]).length, DEFAULT_PALETTE.length);
    });

    test('whitespace-only string -> default', () {
      expect(parseColors('   ').length, DEFAULT_PALETTE.length);
    });
  });

  group('DEFAULT_PALETTE', () {
    test('token-driven (no hex) — 7 token colors', () {
      expect(DEFAULT_PALETTE.length, 7);
      for (final c in DEFAULT_PALETTE) {
        expect(c, matches(RegExp(r'hsl\(var\(--bc-')));
      }
    });
  });

  group('parseChartData', () {
    test('JSON string parses safely', () {
      final result = parseChartData('[{"name":"A","value":1}]');
      expect(result, isA<List>());
      expect((result as List).length, 1);
    });

    test('invalid JSON returns []', () {
      final result = parseChartData('not-json');
      expect(result, isA<List>());
      expect((result as List).isEmpty, isTrue);
    });

    test('object/array passthrough', () {
      final arr = <Map<String, Object>>[
        {'name': 'A', 'value': 1},
      ];
      expect(parseChartData(arr), same(arr));
    });

    test('null returns []', () {
      final result = parseChartData(null);
      expect(result, isA<List>());
      expect((result as List).isEmpty, isTrue);
    });
  });

  group('buildTitleOption', () {
    test('undefined when title empty', () {
      expect(buildTitleOption(null), isNull);
      expect(buildTitleOption(''), isNull);
    });

    test('produces echarts title shape', () {
      final t = buildTitleOption('Sales')!;
      expect(t['text'], 'Sales');
      expect(t['left'], 'left');
      expect((t['textStyle']! as Map)['fontSize'], 14);
    });
  });

  group('buildTooltipOption', () {
    test('gates by enabled flag', () {
      expect(buildTooltipOption(false, 'item'), isNull);
      final t = buildTooltipOption(true, 'axis')!;
      expect(t['trigger'], 'axis');
      expect(t['confine'], true);
    });
  });

  group('buildLegendOption', () {
    test('gates by enabled flag', () {
      expect(buildLegendOption(false), isNull);
      final l = buildLegendOption(true)!;
      expect(l['type'], 'scroll');
      expect(l['bottom'], 0);
    });
  });

  group('buildToolboxOption', () {
    test('features include saveAsImage/restore/dataView', () {
      expect(buildToolboxOption(false), isNull);
      final t = buildToolboxOption(true)!;
      final feature = t['feature']! as Map;
      expect(feature.containsKey('saveAsImage'), isTrue);
      expect(feature.containsKey('restore'), isTrue);
      expect(feature.containsKey('dataView'), isTrue);
      expect((feature['dataView']! as Map)['readOnly'], true);
    });
  });

  group('buildDataZoomOption', () {
    test('emits inside + slider when enabled', () {
      expect(buildDataZoomOption(false), isNull);
      final z = buildDataZoomOption(true)!;
      expect(z.length, 2);
      expect(z[0]['type'], 'inside');
      expect(z[1]['type'], 'slider');
      expect(z[1]['height'], 16);
    });
  });

  group('buildGridOption', () {
    test('bottom padding adapts to legend + dataZoom flags', () {
      final a = buildGridOption(false, false);
      final b = buildGridOption(true, true);
      expect(b['bottom'] as num, greaterThan(a['bottom'] as num));
    });

    test('base grid shape', () {
      final g = buildGridOption(false, false);
      expect(g['left'], 32);
      expect(g['right'], 24);
      expect(g['top'], 32);
      expect(g['bottom'], 12);
      expect(g['containLabel'], true);
    });

    test('legend adds 24, dataZoom adds 32', () {
      expect(buildGridOption(false, true)['bottom'], 36); // 12 + 24
      expect(buildGridOption(true, false)['bottom'], 44); // 12 + 32
      expect(buildGridOption(true, true)['bottom'], 68); // 12 + 24 + 32
    });
  });

  group('JSON serialization parity (undefined-vs-absent)', () {
    test('disabled options are ABSENT from JSON, not null', () {
      // When tooltip/legend/toolbox/dataZoom disabled, the keys must be
      // absent in the JSON string (TS undefined is dropped by JSON.stringify).
      final titleJson = jsonEncode(
        buildTitleOption(null) ?? <String, Object?>{},
      );
      expect(titleJson, '{}');

      final tooltipJson = jsonEncode(
        buildTooltipOption(false, 'item') ?? <String, Object?>{},
      );
      expect(tooltipJson, '{}');

      final legendJson = jsonEncode(
        buildLegendOption(false) ?? <String, Object?>{},
      );
      expect(legendJson, '{}');

      final toolboxJson = jsonEncode(
        buildToolboxOption(false) ?? <String, Object?>{},
      );
      expect(toolboxJson, '{}');

      final zoomJson = jsonEncode(
        buildDataZoomOption(false) ?? <Map<String, dynamic>>[],
      );
      expect(zoomJson, '[]');
    });
  });

  group('BcChartType / BC_CHART_TYPES parity', () {
    test('BC_CHART_TYPES contains exactly 26 unified chart variants', () {
      expect(BcChartType.bcChartTypes.length, 26);
      const expected = <String>[
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
      final names = BcChartType.bcChartTypes.map((e) => e.name).toList();
      expect(names, expected);
    });

    test('doughnut maps to pie (backward compat)', () {
      expect(BcChartType.fromName('doughnut'), BcChartType.pie);
    });

    test('unknown type falls back to bar (default branch)', () {
      expect(BcChartType.fromName('nope'), BcChartType.bar);
    });

    test('fromName round-trips known type names', () {
      // fromName parses the enum .name (lowercase), NOT the echarts seriesType
      // (which uses camelCase for pictorialBar/themeRiver). So we round-trip
      // via .name, not .seriesType.
      for (final t in BcChartType.bcChartTypes) {
        expect(BcChartType.fromName(t.name), t);
      }
    });

    test('pictorialbar seriesType is pictorialBar (camelCase)', () {
      expect(BcChartType.pictorialbar.seriesType, 'pictorialBar');
    });

    test('themeriver seriesType is themeRiver (camelCase)', () {
      expect(BcChartType.themeriver.seriesType, 'themeRiver');
    });

    test('doughnut is NOT a member of the 26', () {
      expect(
        BcChartType.bcChartTypes.any((e) => e.name == 'doughnut'),
        isFalse,
      );
    });
  });
}
