library bc_kpi;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';
import 'bc_statistic.dart';
import 'bc_box.dart';

/// Key performance indicator card (ADR-011 Phase 5c - block parity).
///
/// Mirrors TS `BcKpi` contract. Wraps a metric value, optional title,
/// subtitle, trend indicator, and optional icon inside a bordered card
/// frame.
///
/// Internally reuses [BcStatistic] for the value/title/trend rendering to
/// keep semantics consistent with the statistic widget, then wraps it in a
/// card frame with an optional leading icon chip.
///
/// The public widget key is `BcKpi` (required by ADR-017 catalog
/// validation) even though it composes [BcStatistic] internally.
class BcKpi extends StatelessWidget {
  final String? title;

  /// The metric value. Accepts [String] or [num]; rendered via toString.
  final Object? value;

  /// Secondary line under the value.
  final String? subtitle;

  /// Trend direction. Drives both the trend glyph and the value color via
  /// [BcStatistic].
  final BcStatisticTrend trend;

  /// Trend descriptor shown next to the trend glyph (e.g. '+5.4%').
  final String? trendValue;

  /// Optional leading icon. Flutter-idiomatic (web uses a string glyph).
  final IconData? icon;

  /// Tint color for the [icon] and its background chip. Defaults to
  /// [BcTheme.primary].
  final Color color;

  const BcKpi({
    super.key,
    this.title,
    this.value,
    this.subtitle,
    this.trend = BcStatisticTrend.neutral,
    this.trendValue,
    this.icon,
    this.color = BcTheme.primary,
  });

  String get _valueText {
    final v = value;
    if (v == null) return '';
    return v.toString();
  }

  Widget _buildIcon() {
    final i = icon;
    if (i == null) return const SizedBox.shrink();
    return Container(
      key: const Key('bc-kpi-icon'),
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BcTheme.radius),
      ),
      child: Icon(i, size: 20, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = [
      if (title != null && title!.isNotEmpty) title,
      if (_valueText.isNotEmpty) _valueText,
      if (trendValue != null && trendValue!.isNotEmpty) trendValue,
    ].join(', ');

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: BcBox(
        key: const Key('bc-kpi'),
        padding: 24,
        border: true,
        borderRadius: BcTheme.radius,
        backgroundColor: BcBoxColorToken.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BcStatistic(
                    title: title,
                    value: _valueText,
                    trend: trend,
                    caption: subtitle,
                  ),
                  if (trendValue != null && trendValue!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trend == BcStatisticTrend.up
                                ? Icons.arrow_upward
                                : trend == BcStatisticTrend.down
                                    ? Icons.arrow_downward
                                    : Icons.remove,
                            size: 14,
                            color: trend == BcStatisticTrend.up
                                ? BcTheme.success
                                : trend == BcStatisticTrend.down
                                    ? BcTheme.destructive
                                    : BcTheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trendValue!,
                            key: const Key('bc-kpi-trend'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: trend == BcStatisticTrend.up
                                  ? BcTheme.success
                                  : trend == BcStatisticTrend.down
                                      ? BcTheme.destructive
                                      : BcTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              _buildIcon(),
            ],
          ],
        ),
      ),
    );
  }
}