library bc_meter_group;

import 'package:flutter/material.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Visual variant for a meter segment. Mirrors TS `BcMeterVariant`.
enum BcMeterVariant {
  defaultVariant,
  success,
  warning,
  destructive,
  info,
}

/// A single meter reading inside a [BcMeterGroup].
///
/// Mirrors TS `BcMeterSegment`: [label] is the human-readable name,
/// [value] is the measured quantity, and [variant] selects the token
/// color used to fill the segment. When [variant] is null or
/// [BcMeterVariant.defaultVariant], the [BcTheme.primary] token is used.
class BcMeterSegment {
  final String label;
  final double value;
  final BcMeterVariant? variant;

  const BcMeterSegment({
    required this.label,
    required this.value,
    this.variant,
  });

  @override
  String toString() =>
      'BcMeterSegment(label: $label, value: $value, variant: $variant)';
}

/// A group of progress meters (ADR-011 Phase 5c — M4 layout utility).
///
/// Mirrors TS [BcMeterGroupContract]. Renders each [segment] as an
/// independent horizontal gauge whose filled width maps [value] onto
/// [max] and clamps at the bounds (`[0, max]`). Each gauge exposes the
/// `meter` ARIA role via a Flutter [Semantics] node so assistive
/// technology identifies it as a meter; the semantic label reflects the
/// segment label and value.
///
/// Variants resolve to distinct [BcTheme] tokens (success, warning,
/// destructive, info, default→primary). Meters are independent: changing
/// one segment's value does not affect another's width.
///
/// When [segments] change (a new list is supplied by the parent),
/// [BcMeterGroup] recomputes every gauge width and the aggregate
/// `aria-valuenow` on the next frame, then invokes [onChange] with the
/// new total value and a [BcChangeMeta] whose reason is
/// [BcChangeReason.valueChange]. The widget never retains stale widths:
/// widths are derived directly from the current [segments] each build,
/// so propagation is immediate and deterministic.
class BcMeterGroup extends StatefulWidget {
  /// The independent meters to render.
  final List<BcMeterSegment> segments;

  /// The maximum value each meter maps onto. Defaults to `100`, matching
  /// the TS default. Must be > 0; a non-positive value is treated as 100.
  final double max;

  /// Accessible label for the group container.
  final String ariaLabel;

  /// Emitted when the aggregated value changes because [segments] was
  /// updated by the parent. Receives the new total and a [BcChangeMeta]
  /// with reason [BcChangeReason.valueChange] and source
  /// [BcEventSource.external] (the parent is the originator).
  final BcChangeHandler<double>? onChange;

  const BcMeterGroup({
    super.key,
    this.segments = const [],
    this.max = 100,
    this.ariaLabel = 'Meter group',
    this.onChange,
  });

  @override
  State<BcMeterGroup> createState() => _BcMeterGroupState();
}

class _BcMeterGroupState extends State<BcMeterGroup> {
  double _lastTotal = double.nan;

  double get _effectiveMax => widget.max > 0 ? widget.max : 100;

  double get _currentTotal =>
      widget.segments.fold<double>(0, (sum, s) => sum + s.value);

  @override
  void initState() {
    super.initState();
    _lastTotal = _currentTotal;
  }

  @override
  void didUpdateWidget(covariant BcMeterGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTotal = _currentTotal;
    // Compare against the last emitted total. Using NaN-aware compare so
    // the first frame after init does not re-emit.
    if (!_approxEqual(newTotal, _lastTotal)) {
      _lastTotal = newTotal;
      // Defer the callback so it fires after the build completes and
      // never synchronously mutates parent state mid-build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChange?.call(
            newTotal,
            const BcChangeMeta(
              reason: BcChangeReason.valueChange,
              source: BcEventSource.external,
            ),
          );
        }
      });
    }
  }

  bool _approxEqual(double a, double b) {
    if (a.isNaN && b.isNaN) return true;
    if (a.isNaN || b.isNaN) return false;
    return (a - b).abs() < 1e-9;
  }

  Color _colorFor(BcMeterVariant? variant) {
    switch (variant ?? BcMeterVariant.defaultVariant) {
      case BcMeterVariant.defaultVariant:
        return BcTheme.primary;
      case BcMeterVariant.success:
        return BcTheme.success;
      case BcMeterVariant.warning:
        return BcTheme.warning;
      case BcMeterVariant.destructive:
        return BcTheme.destructive;
      case BcMeterVariant.info:
        return BcTheme.info;
    }
  }

  /// Clamps the value into `[0, max]` and returns the fill fraction in
  /// `[0, 1]`.
  double _fillFor(double value) {
    final clamped = value.clamp(0.0, _effectiveMax);
    return clamped / _effectiveMax;
  }

  @override
  Widget build(BuildContext context) {
    final max = _effectiveMax;
    final total = _currentTotal;
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: widget.ariaLabel,
      value: total.toStringAsFixed(0),
      hint: 'meter group',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widget.segments.length; i++)
            _MeterGauge(
              key: ValueKey('bc-meter-$i'),
              segment: widget.segments[i],
              fill: _fillFor(widget.segments[i].value),
              max: max,
              color: _colorFor(widget.segments[i].variant),
            ),
          if (widget.segments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (final s in widget.segments)
                  _LegendChip(
                    label: s.label,
                    value: s.value,
                    color: _colorFor(s.variant),
                    textStyle: theme.textTheme.labelSmall,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A single horizontal meter gauge with `role=meter` semantics.
class _MeterGauge extends StatelessWidget {
  final BcMeterSegment segment;
  final double fill;
  final double max;
  final Color color;

  const _MeterGauge({
    super.key,
    required this.segment,
    required this.fill,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = segment.value.clamp(0.0, max);
    // Clamp fill once for layout determinism (VAL-M4-027).
    final f = fill.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        // `meter` ARIA role — Flutter's SemanticsFlags has no dedicated
        // meter flag, so we expose a labelled container with an explicit
        // value and a `meter` hint that assistive tech maps to a
        // meter/progressbar. The label carries the meter's label and
        // value (VAL-M4-026).
        container: true,
        label:
            '${segment.label}: ${clampedValue.toStringAsFixed(0)} / ${max.toStringAsFixed(0)}',
        value: clampedValue.toStringAsFixed(0),
        hint: 'meter',
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Available width for the track. Falls back to 0 when
            // unbounded (e.g. inside a horizontally-scrollable parent).
            final trackWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 0.0;
            return ClipRRect(
              borderRadius: BorderRadius.circular(BcTheme.radius),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 12,
                width: trackWidth,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track.
                    Container(
                      key: const Key('bc-meter-track'),
                      width: trackWidth,
                      color: BcTheme.muted,
                    ),
                    // Fill — explicit width maps value onto max and is
                    // deterministic for tests (VAL-M4-027).
                    SizedBox(
                      key: Key('bc-meter-fill-${segment.label}'),
                      width: trackWidth * f,
                      height: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: color),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Legend chip pairing a color swatch with the segment label and value.
class _LegendChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final TextStyle? textStyle;

  const _LegendChip({
    required this.label,
    required this.value,
    required this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: textStyle?.copyWith(color: BcTheme.mutedForeground),
        ),
        Text(
          value.toStringAsFixed(0),
          style: textStyle?.copyWith(
            color: BcTheme.foreground,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
