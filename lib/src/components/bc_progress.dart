library bc_progress;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Visual variant for [BcProgress] fill. Mirrors TS `BcProgress` variant map.
enum BcProgressVariant {
  defaultVariant,
  success,
  warning,
  destructive;

  Color get color {
    switch (this) {
      case BcProgressVariant.defaultVariant:
        return BcTheme.primary;
      case BcProgressVariant.success:
        return BcTheme.success;
      case BcProgressVariant.warning:
        return BcTheme.warning;
      case BcProgressVariant.destructive:
        return BcTheme.destructive;
    }
  }
}

/// Deterministic horizontal progress bar (ADR-011 Phase 5c - block parity).
///
/// Mirrors TS `BcProgress` contract. Renders a rounded track with a fill
/// bar whose width is `clamp(value / max, 0, 1)` of the track width.
///
/// - [value] defaults to 0, [max] defaults to 100.
/// - [size] maps to track height: sm = 6, md = 10, lg = 16.
/// - [variant] selects the fill color token.
/// - When [showLabel] is true, a percentage label row renders above the
///   bar. When [label] is provided it renders on the left of that row.
/// - [striped] adds a diagonal-stripe decoration to the fill.
/// - [animated] is accepted for API parity with the web contract; it is a
///   no-op visual hint on Flutter because CSS keyframe animation has no
///   built-in equivalent without extra dependencies. When true the fill
///   still renders (striped if [striped] is also true).
///
/// Layout uses [LayoutBuilder] for deterministic widths so widget tests
/// can assert exact fill widths (same pattern as `BcMeterGroup`).
class BcProgress extends StatelessWidget {
  final double value;
  final double max;
  final BcComponentSize size;
  final BcProgressVariant variant;
  final bool showLabel;
  final String? label;
  final bool striped;
  final bool animated;

  const BcProgress({
    super.key,
    this.value = 0,
    this.max = 100,
    this.size = BcComponentSize.md,
    this.variant = BcProgressVariant.defaultVariant,
    this.showLabel = false,
    this.label,
    this.striped = false,
    this.animated = false,
  });

  double get _height {
    switch (size) {
      case BcComponentSize.sm:
        return 6;
      case BcComponentSize.md:
        return 10;
      case BcComponentSize.lg:
        return 16;
    }
  }

  double get _effectiveMax => max > 0 ? max : 100;

  /// Resolved percentage clamped to [0, 100].
  double get percentage {
    final m = _effectiveMax;
    final raw = (value / m) * 100;
    if (raw.isNaN || raw.isInfinite) return 0;
    if (raw < 0) return 0;
    if (raw > 100) return 100;
    return raw;
  }

  Widget _buildStripes(double width, double height) {
    if (!striped) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: CustomPaint(
        size: Size(width, height),
        painter: _StripePainter(color: variant.color.withValues(alpha: 0.35)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = percentage;
    final rounded = pct.round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel || (label != null && label!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                if (label != null && label!.isNotEmpty)
                  Expanded(
                    child: Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: BcTheme.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (showLabel)
                  Text(
                    '$rounded%',
                    key: const Key('bc-progress-pct'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: BcTheme.foreground,
                    ),
                  ),
              ],
            ),
          ),
        Semantics(
          container: true,
          label: label,
          value: '$rounded%',
          maxValueLength: 100,
          currentValueLength: rounded,
          child: ExcludeSemantics(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth =
                    constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
                final fillWidth = trackWidth * (pct / 100);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(_height / 2),
                  child: SizedBox(
                    key: const Key('bc-progress'),
                    height: _height,
                    width: trackWidth,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          key: const Key('bc-progress-track'),
                          width: trackWidth,
                          color: BcTheme.muted,
                        ),
                        SizedBox(
                          key: const Key('bc-progress-fill'),
                          width: fillWidth,
                          height: _height,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: variant.color),
                          ),
                        ),
                        if (striped)
                          SizedBox(
                            width: fillWidth,
                            height: _height,
                            child: _buildStripes(fillWidth, _height),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints diagonal stripes over the progress fill. Used when [BcProgress.striped]
/// is true. Stripe angle and spacing mirror the web `bg-stripes` pattern.
class _StripePainter extends CustomPainter {
  final Color color;
  _StripePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4;
    const spacing = 8.0;
    // Draw diagonal lines from bottom-left to top-right, sweeping across.
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) =>
      oldDelegate.color != color;
}