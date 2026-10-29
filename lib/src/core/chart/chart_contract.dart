/// Barrel export for the Dart port of the TypeScript chart-option contract
/// (ADR-015 — Flutter ECharts chart strategy).
///
/// Mirrors `packages/ui/src/contracts/chart-option/index.ts`:
///   export * from './types.ts';
///   export * from './helpers.ts';
///   export * from './factory.ts';
///
/// Re-exporting [chart_types.dart], [chart_helpers.dart], and
/// [chart_factory.dart] so consumers import from a single entry point:
///
/// ```dart
/// import 'package:bc_ui_flutter/src/core/chart/chart_contract.dart';
/// ```
library chart_contract;

export 'chart_types.dart';
export 'chart_helpers.dart';
export 'chart_factory.dart';
