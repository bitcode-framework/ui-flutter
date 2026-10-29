/// Dart port of the TypeScript `buildChartOption()` factory
/// (packages/ui/src/contracts/chart-option/factory.ts).
///
/// Pure function — no Flutter/widget dependencies — so it can be tested in
/// isolation against golden JSON fixtures captured from the TS original.
///
/// Parity rules (see chart-parity skill):
/// - TS `undefined` values are DROPPED by `JSON.stringify`. In Dart, we never
///   insert a key whose value should be absent — every map is built additively
///   and then null-valued keys are stripped via [_StripNulls].
/// - Key ordering does NOT matter for comparison (JSON object key order is
///   unspecified). Tests compare with `DeepCollectionEquality()`.
library chart_factory;

import 'dart:math' as math;

import 'chart_helpers.dart';
import 'chart_types.dart';

// [BuildOptionContext] is defined in [chart_types.dart] (mirrors TS types.ts)
// and re-exported from this library via [chart_contract.dart].

/// Public entry point — mirrors TS `buildChartOption(ctx)`.
///
/// Returns an ECharts option as a `Map<String, Object?>`. Keys that the TS
/// side would emit as `undefined` are ABSENT here (never `null`), so
/// `jsonEncode(buildChartOption(...))` is structurally identical to the TS
/// `JSON.stringify` output for the same [BuildOptionContext].
Map<String, Object?> buildChartOption(BuildOptionContext ctx) {
  switch (ctx.type) {
    case BcChartType.bar:
      return _buildAxisChart(ctx, 'bar');
    case BcChartType.line:
      return _buildAxisChart(ctx, 'line');
    case BcChartType.area:
      return _buildAxisChart(ctx, 'line', area: true);
    case BcChartType.scatter:
      return _buildAxisChart(ctx, 'scatter');
    case BcChartType.pie:
      return _buildSingleSeries(ctx, 'pie');
    case BcChartType.funnel:
      return _buildSingleSeries(ctx, 'funnel');
    case BcChartType.radar:
      return _buildRadar(ctx);
    case BcChartType.gauge:
    case BcChartType.progress:
      return _buildGaugeLike(ctx, 'gauge');
    case BcChartType.kpi:
    case BcChartType.scorecard:
      return _buildKpi(ctx);
    case BcChartType.polar:
      return _buildPolar(ctx);
    case BcChartType.heatmap:
      return _buildHeatmap(ctx);
    case BcChartType.treemap:
    case BcChartType.sunburst:
    case BcChartType.tree:
      return _buildTreeLike(ctx);
    case BcChartType.sankey:
    case BcChartType.graph:
      return _buildGraphLike(ctx);
    case BcChartType.candlestick:
    case BcChartType.boxplot:
      return _buildStatisticalAxis(ctx);
    case BcChartType.parallel:
      return _buildParallel(ctx);
    case BcChartType.pictorialbar:
      return _buildAxisChart(ctx, 'pictorialBar');
    case BcChartType.themeriver:
      return _buildThemeRiver(ctx);
    case BcChartType.mixed:
      return _buildMixed(ctx);
    case BcChartType.pivot:
      return _buildAxisChart(ctx, 'bar');
    case BcChartType.custom:
      // ctx.data && typeof ctx.data === 'object' && !Array.isArray(ctx.data)
      //   ? ctx.data : baseOption(ctx, 'item')
      if (ctx.data is Map) {
        return _stripNulls(Map<String, Object?>.from(ctx.data as Map));
      }
      return _baseOption(ctx, 'item');
  }
}

// ---------------------------------------------------------------------------
// Internal helpers — mirror the private functions in factory.ts
// ---------------------------------------------------------------------------

/// Strips keys whose value is `null` (the Dart analogue of TS `undefined`).
///
/// TS `JSON.stringify` drops `undefined` values; in Dart we emit `null` and
/// then remove it here so the serialized output matches key-for-key. Returns
/// the same map (mutated) for chaining.
Map<String, Object?> _stripNulls(Map<String, Object?> m) {
  m.removeWhere((_, v) => v == null);
  return m;
}

Map<String, Object?> _baseOption(BuildOptionContext ctx, String trigger) {
  final opt = <String, Object?>{
    'title': buildTitleOption(ctx.chartTitle),
    'tooltip': buildTooltipOption(ctx.tooltipEnabled, trigger),
    'legend': buildLegendOption(ctx.legend),
    'toolbox': buildToolboxOption(ctx.toolbox),
    'animation': ctx.animate,
    'color': List<String>.from(ctx.colors),
  };
  return _stripNulls(opt);
}

/// Reads a type-specific boolean flag from `ctx.options`.
bool _optionFlag(BuildOptionContext ctx, String key) {
  final options = ctx.options;
  if (options == null) return false;
  return options[key] == true;
}

List<Map<String, Object?>> _singleItems(BuildOptionContext ctx) {
  if (isSingleSeries(ctx.data)) {
    // Single-series items are [{name, value, ...}].
    return (ctx.data as List)
        .map((e) => Map<String, Object?>.from(e as Map))
        .toList();
  }
  if (isMultiSeries(ctx.data)) {
    final ms = ctx.data as Map;
    final categories = (ms['categories'] as List).cast<String>();
    final series = (ms['series'] as List);
    final firstData = series.isNotEmpty ? (series[0] as Map)['data'] : null;
    final firstNums = firstData is List ? firstData.cast<num>() : null;
    return List<Map<String, Object?>>.generate(categories.length, (i) {
      return <String, Object?>{
        'name': categories[i],
        'value': (firstNums != null && i < firstNums.length) ? firstNums[i] : 0,
      };
    });
  }
  return const [];
}

/// Returns `{categories, series}` — mirrors TS `categoriesAndSeries`.
_CategoriesAndSeries _categoriesAndSeries(
  BuildOptionContext ctx,
  String seriesType,
) {
  final stacked = _optionFlag(ctx, 'stacked');
  if (isMultiSeries(ctx.data)) {
    final ms = ctx.data as Map;
    final categories = (ms['categories'] as List).cast<String>();
    final series = (ms['series'] as List).cast<Map>();
    final out = series.map((s) {
      final m = <String, Object?>{
        'type': seriesType,
        'name': s['name'],
        'data': s['data'],
        'stack': stacked ? 'total' : null,
      };
      return _stripNulls(m);
    }).toList();
    return _CategoriesAndSeries(categories, out);
  }
  final ss = _singleItems(ctx);
  final m = <String, Object?>{
    'type': seriesType,
    'data': ss.map((d) => d['value']).toList(),
    'stack': stacked ? 'total' : null,
  };
  _stripNulls(m);
  return _CategoriesAndSeries(ss.map((d) => d['name'] as String).toList(), [m]);
}

Map<String, Object?> _buildAxisChart(
  BuildOptionContext ctx,
  String seriesType, {
  bool area = false,
}) {
  final horizontal = _optionFlag(ctx, 'horizontal');
  final cs = _categoriesAndSeries(ctx, seriesType);
  var series = cs.series;
  if (area) {
    series = series
        .map((s) => <String, Object?>{...s, 'areaStyle': <String, Object?>{}})
        .toList();
  }
  final opt = <String, Object?>{
    ..._baseOption(ctx, 'axis'),
    'grid': buildGridOption(ctx.dataZoom, ctx.legend),
    'dataZoom': buildDataZoomOption(ctx.dataZoom),
    'xAxis': horizontal
        ? <String, Object?>{'type': 'value'}
        : <String, Object?>{'type': 'category', 'data': cs.categories},
    'yAxis': horizontal
        ? <String, Object?>{'type': 'category', 'data': cs.categories}
        : <String, Object?>{'type': 'value'},
    'series': series,
  };
  return _stripNulls(opt);
}

Map<String, Object?> _buildSingleSeries(
  BuildOptionContext ctx,
  String seriesType,
) {
  return {
    ..._baseOption(ctx, 'item'),
    'series': [
      <String, Object?>{'type': seriesType, 'data': _singleItems(ctx)},
    ],
  };
}

Map<String, Object?> _buildGaugeLike(
  BuildOptionContext ctx,
  String seriesType,
) {
  final items = _singleItems(ctx);
  final value = items.isNotEmpty ? items[0]['value'] : 0;
  return {
    ..._baseOption(ctx, 'item'),
    'series': [
      <String, Object?>{
        'type': seriesType,
        'data': [
          <String, Object?>{'name': ctx.chartTitle ?? 'Value', 'value': value},
        ],
      },
    ],
  };
}

Map<String, Object?> _buildRadar(BuildOptionContext ctx) {
  final items = _singleItems(ctx);
  return {
    ..._baseOption(ctx, 'item'),
    'radar': <String, Object?>{
      'indicator': items
          .map(
            (d) => <String, Object?>{
              'name': d['name'],
              // TS: Math.max(d.value, 100) — returns a num; keep int when
              // the value is int so JSON is byte-identical to the TS output.
              'max': math.max<num>(d['value'] as num, 100),
            },
          )
          .toList(),
    },
    'series': [
      <String, Object?>{
        'type': 'radar',
        'data': [
          <String, Object?>{
            'value': items.map((d) => d['value']).toList(),
            'name': ctx.chartTitle ?? 'Series',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> _buildKpi(BuildOptionContext ctx) {
  final items = _singleItems(ctx);
  final value = items.isNotEmpty ? items[0]['value'] : 0;
  return {
    ..._baseOption(ctx, 'item'),
    'graphic': [
      <String, Object?>{
        'type': 'text',
        'left': 'center',
        'top': 'middle',
        'style': <String, Object?>{
          'text': '$value',
          'fill': 'currentColor',
          'fontSize': 32,
          'fontWeight': 600,
        },
      },
    ],
    'series': <Map<String, Object?>>[],
  };
}

Map<String, Object?> _buildPolar(BuildOptionContext ctx) {
  final items = _singleItems(ctx);
  return {
    ..._baseOption(ctx, 'axis'),
    'angleAxis': <String, Object?>{},
    'radiusAxis': <String, Object?>{
      'type': 'category',
      'data': items.map((d) => d['name']).toList(),
    },
    'polar': <String, Object?>{},
    'series': [
      <String, Object?>{
        'type': 'bar',
        'coordinateSystem': 'polar',
        'data': items.map((d) => d['value']).toList(),
      },
    ],
  };
}

Map<String, Object?> _buildHeatmap(BuildOptionContext ctx) {
  return {
    ..._baseOption(ctx, 'item'),
    'xAxis': <String, Object?>{'type': 'category'},
    'yAxis': <String, Object?>{'type': 'category'},
    'visualMap': <String, Object?>{'min': 0, 'max': 100, 'calculable': true},
    'series': [
      <String, Object?>{
        'type': 'heatmap',
        'data': ctx.data is List ? ctx.data : <Object?>[],
      },
    ],
  };
}

/// treemap / sunburst / tree:
/// `{...baseOption('item'), series:[{type: ctx.type, data: Array.isArray(ctx.data) ? ctx.data : [ctx.data]}]}`
Map<String, Object?> _buildTreeLike(BuildOptionContext ctx) {
  final Object? data;
  if (ctx.data is List) {
    data = ctx.data;
  } else {
    data = <Object?>[ctx.data];
  }
  return {
    ..._baseOption(ctx, 'item'),
    'series': [
      <String, Object?>{'type': ctx.type.name, 'data': data},
    ],
  };
}

/// sankey / graph:
/// `{...baseOption('item'), series:[{type: ctx.type, ...(data && typeof === 'object' && !Array.isArray ? data : {data: ctx.data})}]}`
Map<String, Object?> _buildGraphLike(BuildOptionContext ctx) {
  final Map<String, Object?> seriesEntry;
  if (ctx.data is Map) {
    seriesEntry = <String, Object?>{
      'type': ctx.type.name,
      ...(ctx.data as Map).cast<String, Object?>(),
    };
  } else {
    seriesEntry = <String, Object?>{'type': ctx.type.name, 'data': ctx.data};
  }
  return {
    ..._baseOption(ctx, 'item'),
    'series': [seriesEntry],
  };
}

/// candlestick / boxplot:
/// `{...baseOption('axis'), grid, dataZoom, xAxis:{type:'category'}, yAxis:{type:'value'}, series:[{type: ctx.type, data: Array.isArray(ctx.data) ? ctx.data : []}]}`
Map<String, Object?> _buildStatisticalAxis(BuildOptionContext ctx) {
  final opt = <String, Object?>{
    ..._baseOption(ctx, 'axis'),
    'grid': buildGridOption(ctx.dataZoom, ctx.legend),
    'dataZoom': buildDataZoomOption(ctx.dataZoom),
    'xAxis': <String, Object?>{'type': 'category'},
    'yAxis': <String, Object?>{'type': 'value'},
    'series': [
      <String, Object?>{
        'type': ctx.type.name,
        'data': ctx.data is List ? ctx.data : <Object?>[],
      },
    ],
  };
  return _stripNulls(opt);
}

Map<String, Object?> _buildParallel(BuildOptionContext ctx) {
  return {
    ..._baseOption(ctx, 'axis'),
    'parallelAxis': <Object?>[],
    'parallel': <String, Object?>{},
    'series': [
      <String, Object?>{
        'type': 'parallel',
        'data': ctx.data is List ? ctx.data : <Object?>[],
      },
    ],
  };
}

Map<String, Object?> _buildThemeRiver(BuildOptionContext ctx) {
  return {
    ..._baseOption(ctx, 'axis'),
    'singleAxis': <String, Object?>{'type': 'time'},
    'series': [
      <String, Object?>{
        'type': 'themeRiver',
        'data': ctx.data is List ? ctx.data : <Object?>[],
      },
    ],
  };
}

Map<String, Object?> _buildMixed(BuildOptionContext ctx) {
  final cs = _categoriesAndSeries(ctx, 'bar');
  final opt = <String, Object?>{
    ..._baseOption(ctx, 'axis'),
    'grid': buildGridOption(ctx.dataZoom, ctx.legend),
    'dataZoom': buildDataZoomOption(ctx.dataZoom),
    'xAxis': <String, Object?>{
      'type': 'category',
      'data': _categoriesAndSeries(ctx, 'line').categories,
    },
    'yAxis': <String, Object?>{'type': 'value'},
    'series': cs.series.asMap().entries.map((e) {
      final s = Map<String, Object?>.from(e.value);
      s['type'] = e.key % 2 == 0 ? 'bar' : 'line';
      return s;
    }).toList(),
  };
  return _stripNulls(opt);
}

class _CategoriesAndSeries {
  final List<String> categories;
  final List<Map<String, Object?>> series;
  _CategoriesAndSeries(this.categories, this.series);
}
