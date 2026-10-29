// ============================================================================
// BcBreakpoints — standard media-query breakpoints (ADR-002 §9.2 / §9.4).
//
// Dart port of the TS `BC_BREAKPOINTS`
// (packages/ui/src/core/hooks/use-media-query.ts). Numeric values match the
// Tailwind defaults so the design system stays consistent across tiers.
//
// On Flutter these are not used to drive `window.matchMedia` (there is none);
// instead the host maps a query string to a `MediaQuery.size` width probe via
// [bcBreakpointMinWidth] (e.g. `(min-width: 768px)` ↔ `size.width >= 768`).
// The string form is kept for cross-tier parity with the Adapt contract,
// which encodes conditions as breakpoint names that resolve to these queries.
// ============================================================================

import 'adapt/adapt.dart';

/// Standard breakpoint queries used by the Adapt pattern. Mirrors TS
/// `BC_BREAKPOINTS`. Numeric values match the Tailwind defaults.
const Map<BcAdaptBreakpoint, String> bcBreakpointQueries = {
  BcAdaptBreakpoint.sm: '(min-width: 640px)',
  BcAdaptBreakpoint.md: '(min-width: 768px)',
  BcAdaptBreakpoint.lg: '(min-width: 1024px)',
  BcAdaptBreakpoint.xl: '(min-width: 1280px)',
  BcAdaptBreakpoint.xxl: '(min-width: 1536px)',
};

/// Minimum width (in logical pixels) for each breakpoint. Mirrors the TS
/// `BC_BREAKPOINTS` numeric thresholds. The host uses this to build a
/// `BcAdaptContext.breakpointMatcher` from `MediaQuery.size`:
///
/// ```dart
/// BcAdaptContext(
///   breakpointMatcher: (query) {
///     final bp = bcBreakpointMinWidth.entries
///         .firstWhere((e) => bcBreakpointQueries[e.key] == query);
///     return size.width >= bp.value;
///   },
/// )
/// ```
const Map<BcAdaptBreakpoint, double> bcBreakpointMinWidth = {
  BcAdaptBreakpoint.sm: 640,
  BcAdaptBreakpoint.md: 768,
  BcAdaptBreakpoint.lg: 1024,
  BcAdaptBreakpoint.xl: 1280,
  BcAdaptBreakpoint.xxl: 1536,
};
