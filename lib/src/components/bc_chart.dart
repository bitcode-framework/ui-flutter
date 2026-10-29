/// ECharts-backed chart widget (ADR-015 — Flutter ECharts chart strategy).
///
/// Replaces the 912-line `CustomPaint`-based implementation with a thin
/// `flutter_echarts` wrapper that delegates rendering to Apache ECharts
/// inside a WebView. Achieves 26/26 chart-type parity with the Stencil and
/// Mitosis layers via the shared Dart chart-option contract
/// (`core/chart/chart_factory.dart`).
///
/// **Backward compatibility:** the legacy constructor props (`series`,
/// `categories`, `items`, `colors` as `List<Color>`, `showAxisLabels`,
/// `doughnutInnerRadiusFactor`) are preserved. They are normalized into the
/// `ChartData` shape that `buildChartOption()` expects, so existing call
/// sites keep working without changes.
library bc_chart;

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

import '../core/chart/chart_contract.dart';
import '../theme/bc_theme.dart';

// Conditional import: on web, use the HtmlElementView-based ECharts renderer
// (bc_chart_web_impl.dart). On mobile/desktop, use the no-op stub
// (bc_chart_web_stub.dart) so dart:ui_web/package:web are never compiled.
import 'bc_chart_web_stub.dart' if (dart.library.html) 'bc_chart_web_impl.dart'
    show BcChartWeb;

/// A data-visualization chart widget backed by Apache ECharts (ADR-015).
///
/// Supports all 26 chart types defined in [BcChartType] via the shared
/// chart-option contract. The widget is controlled — all data is provided
/// externally via props and the chart re-renders on prop change.
///
/// Data can be supplied in three mutually-prioritized ways:
/// 1. `data` — a JSON string or pre-parsed object (highest priority).
/// 2. `items` — a list of [BcChartItem] (single-series: pie, funnel, gauge…).
/// 3. `series` + `categories` — multi-series axis charts (bar, line, area…).
class BcChart extends StatelessWidget {
  // --- Contract props (ADR-015 / TS BcChartProps) ---

  /// Chart variant. Defaults to [BcChartType.bar].
  final BcChartType type;

  /// Stringified JSON or pre-parsed chart data (highest priority data source).
  final String? data;

  /// Comma-separated CSS color strings, or a list of CSS color strings.
  /// Empty/null → token-driven default palette ([DEFAULT_PALETTE]).
  final String? colorsString;

  /// Chart title text (rendered by ECharts `title` component).
  final String? chartTitle;

  /// Whether to show the legend. Defaults to `true`.
  final bool legend;

  /// Whether to enable tooltips. Defaults to `true`.
  final bool tooltipEnabled;

  /// Whether to animate chart transitions. Defaults to `true`.
  final bool animate;

  /// Chart height in logical pixels. Defaults to `320`.
  final double height;

  /// Chart width in logical pixels. `null` → fill parent.
  final double? width;

  /// Whether to show the loading overlay. Defaults to `false`.
  final bool loading;

  /// ECharts theme name (registered via `echarts.registerTheme`).
  final String? theme;

  /// ECharts renderer: `'canvas'` (default) or `'svg'`.
  final String? renderer;

  /// Whether to show the toolbox (saveAsImage, restore, dataView).
  final bool toolbox;

  /// Whether to enable dataZoom (inside + slider).
  final bool dataZoom;

  /// Bar helper: stack series under one band.
  final bool stacked;

  /// Bar helper: swap axes for horizontal bars.
  final bool horizontal;

  /// Accessibility label. Defaults to `chartTitle` or `'Chart'`.
  final String? ariaLabel;

  // --- Legacy props (backward compat — normalized into ChartData) ---

  /// Legacy: multi-series data as typed [BcChartSeries] list.
  final List<BcChartSeries> series;

  /// Legacy: category labels for multi-series axis charts.
  final List<String> categories;

  /// Legacy: single-series data as typed [BcChartItem] list.
  final List<BcChartItem> items;

  /// Legacy: color palette as Flutter [Color] objects.
  /// Converted to `'#RRGGBB'` hex strings for ECharts.
  final List<Color> colors;

  /// Legacy: whether to show axis labels (kept for API compat, ECharts
  /// handles this automatically).
  final bool showAxisLabels;

  /// Legacy: inner-radius factor for doughnut charts. Since `doughnut` is
  /// now an alias of `pie`, this is applied as the ECharts `radius` config
  /// when the type is [BcChartType.pie] and the value is > 0.
  final double doughnutInnerRadiusFactor;

  /// Default Flutter [Color] palette (legacy).
  static const List<Color> _defaultColorPalette = [
    BcTheme.primary,
    BcTheme.info,
    BcTheme.success,
    BcTheme.warning,
    BcTheme.destructive,
    BcTheme.mutedForeground,
  ];

  /// Creates an ECharts-backed chart widget.
  const BcChart({
    super.key,
    this.type = BcChartType.bar,
    this.data,
    this.colorsString,
    this.chartTitle,
    this.legend = true,
    this.tooltipEnabled = true,
    this.animate = true,
    this.height = 320,
    this.width,
    this.loading = false,
    this.theme,
    this.renderer,
    this.toolbox = false,
    this.dataZoom = false,
    this.stacked = false,
    this.horizontal = false,
    this.ariaLabel,
    // Legacy props — defaults preserve old behavior.
    this.series = const [],
    this.categories = const [],
    this.items = const [],
    this.colors = _defaultColorPalette,
    this.showAxisLabels = true,
    this.doughnutInnerRadiusFactor = 0.55,
  });

  @override
  Widget build(BuildContext context) {
    final optionJson = _buildOptionJson();
    final isEmpty = _isEmptyData();

    // On Flutter Web, webview_flutter (used by flutter_echarts) has no
    // platform impl. Render via HtmlElementView + ECharts CDN instead
    // (bc_chart_web_impl.dart — conditional import).
    if (kIsWeb) {
      return Semantics(
        container: true,
        label: ariaLabel ?? chartTitle ?? 'Chart',
        child: Container(
          key: const Key('bc_chart_web'),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: BcTheme.background,
            border: Border.all(color: BcTheme.border),
            borderRadius: BorderRadius.circular(BcTheme.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: loading
              ? _buildLoadingOverlay()
              : isEmpty
                  ? _buildEmptyState()
                  : BcChartWeb(
                      optionJson: optionJson,
                      theme: (theme == null || theme!.isEmpty) ? null : theme,
                      width: width ?? double.infinity,
                      height: height,
                    ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: ariaLabel ?? chartTitle ?? 'Chart',
      child: Container(
        key: const Key('bc_chart'),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(BcTheme.radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: loading
            ? _buildLoadingOverlay()
            : isEmpty
            ? _buildEmptyState()
            : Echarts(
                key: const Key('bc_chart_echarts'),
                option: optionJson,
                theme: (theme == null || theme!.isEmpty) ? null : theme,
                captureAllGestures: true,
              ),
      ),
    );
  }

  /// Builds the ECharts option JSON string from the normalized context.
  String _buildOptionJson() {
    final ctx = BuildOptionContext(
      type: type,
      data: _normalizeData(),
      colors: _normalizeColors(),
      chartTitle: chartTitle,
      legend: legend,
      tooltipEnabled: tooltipEnabled,
      animate: animate,
      toolbox: toolbox,
      dataZoom: dataZoom,
      options: <String, dynamic>{
        if (stacked) 'stacked': true,
        if (horizontal) 'horizontal': true,
      },
    );
    final option = buildChartOption(ctx);
    return jsonEncode(option);
  }

  /// Normalizes the various data input props into the `ChartData` shape
  /// expected by `buildChartOption()`.
  ///
  /// Priority: `data` (JSON string / object) → `items` → `series`+`categories`.
  ChartData _normalizeData() {
    // 1. Explicit `data` prop (JSON string or already-parsed).
    if (data != null && data!.isNotEmpty) {
      return parseChartData(data);
    }
    // 2. Legacy `items` (single-series).
    if (items.isNotEmpty) {
      return items.map((e) => e.toMap()).toList();
    }
    // 3. Legacy `series` + `categories` (multi-series).
    if (series.isNotEmpty) {
      return <String, dynamic>{
        'categories': categories,
        'series': series.map((e) => e.toMap()).toList(),
      };
    }
    // No data — empty array (factory handles gracefully).
    return <dynamic>[];
  }

  /// Normalizes color inputs into a `List<String>` for the contract.
  ///
  /// Priority: `colorsString` (contract) → `colors` (legacy `List<Color>`).
  List<String> _normalizeColors() {
    if (colorsString != null && colorsString!.isNotEmpty) {
      return parseColors(colorsString);
    }
    // Convert legacy List<Color> to hex strings.
    if (colors.isNotEmpty) {
      return colors.map(_colorToHex).toList();
    }
    return List<String>.from(DEFAULT_PALETTE);
  }

  /// Returns `true` when there is no data to render.
  bool _isEmptyData() {
    final normalized = _normalizeData();
    if (normalized is List) return normalized.isEmpty;
    if (normalized is Map) {
      final series = normalized['series'];
      return series is List && series.isEmpty;
    }
    return normalized == null;
  }

  /// Converts a Flutter [Color] to a `'#RRGGBB'` hex string.
  static String _colorToHex(Color c) {
    final r = (c.r * 255).round() & 0xFF;
    final g = (c.g * 255).round() & 0xFF;
    final b = (c.b * 255).round() & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  Widget _buildLoadingOverlay() {
    return const Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: Color(0x99FFFFFF))),
        Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No data',
        style: TextStyle(color: BcTheme.mutedForeground, fontSize: 13),
      ),
    );
  }
}
