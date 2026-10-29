/// Chart type contract ported 1:1 from the TypeScript
/// `packages/ui/src/contracts/chart-option/types.ts`.
///
/// This is the canonical chart taxonomy (ADR-003 Section 1 / ADR-015):
/// a single discriminated union of 26 variants collapsed into one enum.
/// The legacy 4-value `BcChartType` (bar/line/pie/doughnut) that lived in
/// `core/types.dart` is removed; `doughnut` is preserved as an alias of
/// `pie` for backward compatibility (see [BcChartType.fromName]).
///
/// This module is a pure contract — no Flutter/widget dependencies — so it
/// can be unit-tested in isolation against golden JSON fixtures produced by
/// the TypeScript `buildChartOption()`.
library chart_types;

/// Rendering type for `BcChart`.
///
/// Mirrors the TS `BcChartType` union (26 variants). Order matches the TS
/// `BC_CHART_TYPES` canonical list so runtime checks and tests compare
/// 1:1. `doughnut` is NOT a member of the canonical 26 — it is accepted by
/// [BcChartType.fromName] as a backward-compatible alias of [BcChartType.pie].
enum BcChartType {
  area,
  bar,
  boxplot,
  candlestick,
  custom,
  funnel,
  gauge,
  graph,
  heatmap,
  kpi,
  line,
  mixed,
  parallel,
  pictorialbar,
  pie,
  pivot,
  polar,
  progress,
  radar,
  sankey,
  scatter,
  scorecard,
  sunburst,
  themeriver,
  tree,
  treemap;

  /// Canonical list (for runtime checks + tests).
  ///
  /// Mirrors TS `BC_CHART_TYPES`. MUST stay in lockstep with the TS array
  /// (same order, same 26 entries). The `doughnut` alias is deliberately
  /// absent — it maps to [pie] via [fromName].
  static const List<BcChartType> bcChartTypes = [
    BcChartType.area,
    BcChartType.bar,
    BcChartType.boxplot,
    BcChartType.candlestick,
    BcChartType.custom,
    BcChartType.funnel,
    BcChartType.gauge,
    BcChartType.graph,
    BcChartType.heatmap,
    BcChartType.kpi,
    BcChartType.line,
    BcChartType.mixed,
    BcChartType.parallel,
    BcChartType.pictorialbar,
    BcChartType.pie,
    BcChartType.pivot,
    BcChartType.polar,
    BcChartType.progress,
    BcChartType.radar,
    BcChartType.sankey,
    BcChartType.scatter,
    BcChartType.scorecard,
    BcChartType.sunburst,
    BcChartType.themeriver,
    BcChartType.tree,
    BcChartType.treemap,
  ];

  /// Parse a type name string into a [BcChartType].
  ///
  /// `doughnut` (the legacy 4-value enum member) is accepted as an alias of
  /// [BcChartType.pie] for backward compatibility. Unknown strings fall back
  /// to [BcChartType.bar] (mirrors the TS `default` branch in
  /// `buildChartOption`).
  static BcChartType fromName(String name) {
    if (name == 'doughnut') return BcChartType.pie;
    return BcChartType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => BcChartType.bar,
    );
  }

  /// The ECharts series `type` string used when this variant renders as a
  /// series. Convenience accessor; the factory uses raw string literals to
  /// match the TS exactly (e.g. `pictorialBar`, `themeRiver`).
  String get seriesType {
    switch (this) {
      case BcChartType.pictorialbar:
        return 'pictorialBar';
      case BcChartType.themeriver:
        return 'themeRiver';
      default:
        return name;
    }
  }
}

/// Single-series data item `{ name, value }`.
///
/// Mirrors TS `SingleSeriesItem`. Kept as a typed wrapper for ergonomic
/// construction; the factory converts to/from plain `Map<String, dynamic>`.
class BcChartItem {
  final String name;
  final num value;

  const BcChartItem({required this.name, required this.value});

  Map<String, dynamic> toMap() => {'name': name, 'value': value};

  @override
  String toString() => 'BcChartItem(name: $name, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcChartItem && name == other.name && value == other.value;

  @override
  int get hashCode => Object.hash(name, value);
}

/// Multi-series entry `{ name, data }`.
///
/// Mirrors TS `MultiSeriesEntry`.
class BcChartSeries {
  final String name;
  final List<num> data;

  const BcChartSeries({required this.name, required this.data});

  Map<String, dynamic> toMap() => {'name': name, 'data': data};

  @override
  String toString() => 'BcChartSeries(name: $name, data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcChartSeries &&
          name == other.name &&
          _listEquals(data, other.data);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(data));

  static bool _listEquals(List<num> a, List<num> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Multi-series data shape `{ categories, series }`.
///
/// Mirrors TS `MultiSeriesData`.
class BcChartMultiSeriesData {
  final List<String> categories;
  final List<BcChartSeries> series;

  const BcChartMultiSeriesData({
    required this.categories,
    required this.series,
  });

  Map<String, dynamic> toMap() => {
    'categories': categories,
    'series': series.map((s) => s.toMap()).toList(),
  };

  @override
  String toString() =>
      'BcChartMultiSeriesData(categories: $categories, series: $series)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcChartMultiSeriesData &&
          _listEquals(categories, other.categories) &&
          _listEquals(series, other.series);

  @override
  int get hashCode => Object.hashAll(categories) ^ Object.hashAll(series);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Chart data union.
///
/// Mirrors TS `ChartData = SingleSeriesItem[] | MultiSeriesData |
/// Record<string, unknown> | unknown[]`. In Dart this is represented as
/// `Object?` (the dynamic value); the helpers [isSingleSeries] and
/// [isMultiSeries] narrow the shape at runtime.
typedef ChartData = Object?;

/// Loose ECharts option type.
///
/// Mirrors TS `EChartsOption = Record<string, unknown>`.
typedef EChartsOption = Map<String, dynamic>;

/// Build-option context passed to [buildChartOption].
///
/// Mirrors TS `BuildOptionContext` field-for-field.
class BuildOptionContext {
  final BcChartType type;
  final ChartData data;
  final List<String> colors;
  final String? chartTitle;
  final bool legend;
  final bool tooltipEnabled;
  final bool animate;
  final bool toolbox;
  final bool dataZoom;

  /// Type-specific flags (bar.stacked, bar.horizontal, etc.).
  ///
  /// Mirrors TS `options?: Record<string, unknown>`.
  final Map<String, dynamic>? options;

  const BuildOptionContext({
    required this.type,
    required this.data,
    required this.colors,
    this.chartTitle,
    this.legend = true,
    this.tooltipEnabled = true,
    this.animate = true,
    this.toolbox = false,
    this.dataZoom = false,
    this.options,
  });
}
