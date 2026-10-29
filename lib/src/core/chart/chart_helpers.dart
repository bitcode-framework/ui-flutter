// ignore_for_file: constant_identifier_names
// Name mirrors the TypeScript `DEFAULT_PALETTE` constant exactly (ADR-015
// chart-option contract parity) — do NOT rename to camelCase.
/// Helpers for the chart-option factory.
///
/// Dart port of `packages/ui/src/contracts/chart-option/helpers.ts`.
///
/// Pure functions only — no Flutter/widget dependencies — so they can be
/// unit-tested in isolation against golden JSON fixtures.
library chart_helpers;

import 'dart:convert';

import 'chart_types.dart';

/// Default palette derived from the design-token semantic colors.
///
/// Mirrors TS `DEFAULT_PALETTE` (token-driven, no hex). ECharts consumes
/// CSS `hsl(var(...))` strings directly when rendered inside the WebView.
const List<String> DEFAULT_PALETTE = <String>[
  'hsl(var(--bc-primary))',
  'hsl(var(--bc-success))',
  'hsl(var(--bc-warning))',
  'hsl(var(--bc-info))',
  'hsl(var(--bc-destructive))',
  'hsl(var(--bc-secondary))',
  'hsl(var(--bc-accent))',
];

/// Detects the single-series shape `[{name: String, value: number}]`.
///
/// Mirrors TS `isSingleSeries`. An empty array is NOT single-series.
/// The first element must have a String `name` and a numeric `value`.
bool isSingleSeries(ChartData data) {
  if (data is! List || data.isEmpty) return false;
  final first = data.first;
  if (first is! Map) return false;
  final name = first['name'];
  final value = first['value'];
  return name is String && value is num;
}

/// Detects the multi-series shape `{categories: [], series: []}`.
///
/// Mirrors TS `isMultiSeries`. Must be a non-array object with both
/// `categories` and `series` arrays.
bool isMultiSeries(ChartData data) {
  if (data is! Map || data is List) return false;
  final categories = data['categories'];
  final series = data['series'];
  return categories is List && series is List;
}

/// Parses a color spec into a list of color strings.
///
/// Mirrors TS `parseColors`:
/// - Array passthrough (non-empty), empty array → default palette.
/// - Comma-separated string → trimmed split, empty/whitespace → default.
/// - Null/undefined → default palette.
List<String> parseColors([Object? input]) {
  if (input is List) {
    final list = input.cast<String>();
    return list.isNotEmpty ? list : DEFAULT_PALETTE;
  }
  if (input is! String || input.trim() == '') {
    return List<String>.from(DEFAULT_PALETTE);
  }
  final list = input
      .split(',')
      .map((c) => c.trim())
      .where((c) => c.isNotEmpty)
      .toList();
  return list.isNotEmpty ? list : List<String>.from(DEFAULT_PALETTE);
}

/// Parses chart data from a JSON string or passes through objects/arrays.
///
/// Mirrors TS `parseChartData`:
/// - JSON string → parsed (invalid JSON → `[]`).
/// - Object/array → passthrough.
/// - null/undefined → `[]`.
ChartData parseChartData(Object? data) {
  if (data is String) {
    try {
      return jsonDecode(data) as ChartData;
    } catch (_) {
      return <dynamic>[];
    }
  }
  return data ?? <dynamic>[];
}

/// Builds the ECharts `title` option.
///
/// Mirrors TS `buildTitleOption`: `undefined` (absent) when title is empty.
Map<String, dynamic>? buildTitleOption([String? title]) {
  if (title == null || title.isEmpty) return null;
  return <String, dynamic>{
    'text': title,
    'left': 'left',
    'textStyle': <String, dynamic>{'fontSize': 14},
  };
}

/// Builds the ECharts `tooltip` option.
///
/// Mirrors TS `buildTooltipOption`: `undefined` (absent) when disabled.
Map<String, dynamic>? buildTooltipOption(bool enabled, String trigger) {
  if (!enabled) return null;
  return <String, dynamic>{'trigger': trigger, 'confine': true};
}

/// Builds the ECharts `legend` option.
///
/// Mirrors TS `buildLegendOption`: `undefined` (absent) when disabled.
Map<String, dynamic>? buildLegendOption(bool enabled) {
  if (!enabled) return null;
  return <String, dynamic>{'type': 'scroll', 'bottom': 0};
}

/// Builds the ECharts `toolbox` option.
///
/// Mirrors TS `buildToolboxOption`: `undefined` (absent) when disabled.
Map<String, dynamic>? buildToolboxOption(bool enabled) {
  if (!enabled) return null;
  return <String, dynamic>{
    'feature': <String, dynamic>{
      'saveAsImage': <String, dynamic>{},
      'restore': <String, dynamic>{},
      'dataView': <String, dynamic>{'readOnly': true},
    },
  };
}

/// Builds the ECharts `dataZoom` option array.
///
/// Mirrors TS `buildDataZoomOption`: `undefined` (absent) when disabled.
List<Map<String, dynamic>>? buildDataZoomOption(bool enabled) {
  if (!enabled) return null;
  return <Map<String, dynamic>>[
    <String, dynamic>{'type': 'inside'},
    <String, dynamic>{'type': 'slider', 'height': 16},
  ];
}

/// Builds the ECharts `grid` option.
///
/// Mirrors TS `buildGridOption`: bottom padding adapts to legend + dataZoom.
Map<String, dynamic> buildGridOption(bool dataZoom, bool legend) {
  return <String, dynamic>{
    'left': 32,
    'right': 24,
    'top': 32,
    'bottom': 12 + (legend ? 24 : 0) + (dataZoom ? 32 : 0),
    'containLabel': true,
  };
}
