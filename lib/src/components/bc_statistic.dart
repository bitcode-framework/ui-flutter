library bc_statistic;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Trend direction for [BcStatistic].
enum BcStatisticTrend { up, down, neutral }

/// Statistic display card (ADR-011 Phase 5c — M1 display).
///
/// Renders a large value with optional [prefix] (e.g. currency) and
/// [suffix] (e.g. unit), a [title] caption above, an optional [caption]
/// sub-line below, and a [trend] indicator that drives both an arrow glyph
/// and the value color via [BcTheme] tokens.
///
/// When [prefix] or [suffix] is null/empty, no text node is rendered for
/// that part. The widget is a pure [StatelessWidget] because it has no
/// internal mutable state.
class BcStatistic extends StatelessWidget {
  final String? title;
  final String? value;
  final String? prefix;
  final String? suffix;
  final BcStatisticTrend trend;
  final String? caption;

  const BcStatistic({
    super.key,
    this.title,
    this.value,
    this.prefix,
    this.suffix,
    this.trend = BcStatisticTrend.neutral,
    this.caption,
  });

  Color _valueColor() {
    switch (trend) {
      case BcStatisticTrend.up:
        return BcTheme.success;
      case BcStatisticTrend.down:
        return BcTheme.destructive;
      case BcStatisticTrend.neutral:
        return BcTheme.foreground;
    }
  }

  IconData _trendIcon() {
    switch (trend) {
      case BcStatisticTrend.up:
        return Icons.arrow_upward;
      case BcStatisticTrend.down:
        return Icons.arrow_downward;
      case BcStatisticTrend.neutral:
        return Icons.remove;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: BcTheme.mutedForeground,
            ),
          ),
        if (title != null) const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefix != null && prefix!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Text(
                  prefix!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _valueColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              value ?? '',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: _valueColor(),
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (suffix != null && suffix!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  suffix!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _valueColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _trendIcon(),
                size: 14,
                color: _valueColor(),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  caption!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _valueColor(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
