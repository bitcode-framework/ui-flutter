# BcChart Migration Guide — CustomPaint → flutter_echarts (ADR-015)

> **ADR-015** replaces the 912-line `CustomPaint`-based `BcChart` widget with a
> thin `flutter_echarts` wrapper that delegates rendering to Apache ECharts
> inside a WebView. This achieves **26/26 chart-type parity** with the Stencil
> and Mitosis layers via a shared chart-option contract.

## What Changed

### Before (v0.x — CustomPaint)

- **912 lines** of hand-drawn `CustomPainter` code (`_BarChartPainter`,
  `_LineChartPainter`, `_PieChartPainter`, `_PieChartView`, etc.)
- Only **4/26 chart types**: `bar`, `line`, `pie`, `doughnut`
- No tooltip, no legend interactivity, no animation, no dataZoom, no toolbox
- Buggy: negative values crashed, Y-axis labels missing, no accessibility
- `BcChartType` was a 4-value enum: `{ bar, line, pie, doughnut }`

### After (v1.0 — flutter_echarts)

- **288 lines** — thin wrapper around `flutter_echarts`'s `Echarts` widget
- All **26/26 chart types** via the shared Dart chart-option contract
  (`core/chart/chart_factory.dart`)
- Tooltip, animation, legend, dataZoom, toolbox — **free from ECharts**
- `Semantics` wrapper + `ariaLabel` prop for accessibility
- `BcChartType` is now a 26-value enum with `doughnut`→`pie` backward-compat

## Breaking Changes

### 1. `BcChartType` enum expanded from 4 to 26 values

```dart
// Before
enum BcChartType { bar, line, pie, doughnut }

// After (26 values)
enum BcChartType {
  bar, line, area, pie, scatter, radar, funnel, gauge, heatmap,
  treemap, sunburst, candlestick, boxplot, graph, sankey, tree,
  parallel, themeriver, pictorialbar, polar, mixed, custom,
  kpi, progress, pivot, scorecard,
}
```

**Migration:** `doughnut` is now an alias of `pie`. If you used
`BcChartType.doughnut`, it still works — `BcChartType.fromName('doughnut')`
returns `BcChartType.pie`. No code change required.

### 2. New contract props (additive — all optional)

These new props mirror the TS `BcChartProps` contract. All have sensible
defaults, so existing call sites work without changes:

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `data` | `String?` | `null` | JSON string or pre-parsed chart data (highest priority) |
| `colorsString` | `String?` | `null` | Comma-separated CSS color strings |
| `chartTitle` | `String?` | `null` | Chart title text |
| `legend` | `bool` | `true` | Show legend |
| `tooltipEnabled` | `bool` | `true` | Enable tooltips |
| `animate` | `bool` | `true` | Animate transitions |
| `loading` | `bool` | `false` | Show loading overlay |
| `theme` | `String?` | `null` | ECharts theme name |
| `renderer` | `String?` | `null` | `'canvas'` or `'svg'` |
| `toolbox` | `bool` | `false` | Show toolbox (saveAsImage, etc.) |
| `dataZoom` | `bool` | `false` | Enable dataZoom (inside + slider) |
| `stacked` | `bool` | `false` | Stack bar series |
| `horizontal` | `bool` | `false` | Swap axes for horizontal bars |
| `ariaLabel` | `String?` | `null` | Accessibility label |

### 3. Legacy props preserved (backward compatible)

These props are normalized into the `ChartData` shape that
`buildChartOption()` expects:

| Legacy Prop | Type | Still Works? |
|-------------|------|-------------|
| `series` | `List<BcChartSeries>` | ✅ Yes |
| `categories` | `List<String>` | ✅ Yes |
| `items` | `List<BcChartItem>` | ✅ Yes |
| `colors` | `List<Color>` | ✅ Yes (converted to hex) |
| `showAxisLabels` | `bool` | ✅ Yes (no-op, ECharts handles automatically) |
| `doughnutInnerRadiusFactor` | `double` | ✅ Yes (applied as pie `radius`) |

## Data Priority

Data is resolved in this priority order:

1. **`data`** (JSON string) — highest priority, parsed and passed directly to
   `buildChartOption()`.
2. **`items`** (`List<BcChartItem>`) — normalized to single-series data
   (for pie, funnel, gauge, etc.).
3. **`series` + `categories`** — normalized to multi-series axis data
   (for bar, line, area, etc.).

## Examples

### Basic bar chart (legacy API — still works)

```dart
BcChart(
  type: BcChartType.bar,
  categories: ['Q1', 'Q2', 'Q3'],
  series: [
    BcChartSeries(name: 'Revenue', data: [100, 200, 150]),
  ],
  height: 300,
)
```

### New chart types (now available)

```dart
BcChart(
  type: BcChartType.heatmap,
  data: jsonEncode({
    'categories': ['Mon', 'Tue', 'Wed'],
    'series': [
      {'name': 'A', 'data': [10, 20, 30]},
      {'name': 'B', 'data': [40, 50, 60]},
    ],
  }),
  dataZoom: true,
  height: 400,
)
```

### Using contract props (full feature set)

```dart
BcChart(
  type: BcChartType.bar,
  categories: ['A', 'B', 'C'],
  series: [
    BcChartSeries(name: 'S1', data: [10, 20, 30]),
    BcChartSeries(name: 'S2', data: [15, 25, 35]),
  ],
  stacked: true,
  horizontal: true,
  toolbox: true,
  dataZoom: true,
  chartTitle: 'Sales by Region',
  ariaLabel: 'Stacked horizontal bar chart showing sales by region',
  height: 350,
)
```

## Testing

Widget tests use a fake `WebViewPlatform` (`test/helpers/fake_webview_platform.dart`)
to allow the `Echarts` widget to build in the test environment without a real
WebView. Tests verify the widget **contract surface** (container structure,
option JSON, loading/empty states, semantics, backward-compat) — NOT rendered
pixels (per XS-001: the WebView cannot render in widget tests).

The chart-option factory itself is exhaustively parity-tested against 36
golden JSON fixtures in `chart_factory_test.dart` (48 assertions, 0 diff).

## Platform Requirements

`flutter_echarts` uses `webview_flutter` under the hood, which requires:

- **Android:** `minSdkVersion 19` (already satisfied by Flutter default)
- **iOS:** `platform :ios, '12.0'` (already satisfied by Flutter default)
- **Web:** Not supported (WebView is not available on Flutter Web)

For Flutter Web, use the Stencil or Mitosis layer instead (which render
ECharts directly in the DOM).

## See Also

- [ADR-015](../../../docs/adr/015-flutter-echarts-chart-strategy.md) — Full decision record
- [Chart-option contract](../lib/src/core/chart/chart_contract.dart) — Dart port
- [Golden fixtures](../test/fixtures/chart-options/golden-fixtures.json) — 36 TS-generated fixtures
