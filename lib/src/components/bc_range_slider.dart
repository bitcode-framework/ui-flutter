library bc_range_slider;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Immutable two-element range value for [BcRangeSlider].
///
/// Represents `[min, max]` with `min <= max` (guaranteed by clamping logic
/// in the widget).
class BcRangeValue {
  final double min;
  final double max;

  const BcRangeValue({required this.min, required this.max});

  @override
  String toString() => 'BcRangeValue(min: $min, max: $max)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcRangeValue && min == other.min && max == other.max;

  @override
  int get hashCode => Object.hash(min, max);
}

/// Dual-thumb min/max range slider with non-crossing thumbs (ADR-011 Phase 5c — M2 forms).
///
/// Controlled mode: parent provides [value]; uncontrolled: [defaultValue].
/// Both thumbs are clamped within [min]–[max] and snap to [step] granularity.
/// The lower thumb cannot exceed the upper thumb and vice versa.
///
/// When [showValues] is true, both bounds are displayed (optionally suffixed
/// with [unit]).
///
/// Platform-aware: uses Flutter's [RangeSlider] widget which renders
/// Cupertino-style on iOS and Material on Android. Flutter's RangeSlider
/// inherently enforces non-crossing thumbs (start < end).
///
/// When [disabled] is true, both thumbs are non-interactive.
class BcRangeSlider extends StatefulWidget {
  final String? name;
  final String? label;
  final BcRangeValue? value;
  final BcRangeValue? defaultValue;
  final double min;
  final double max;
  final double step;
  final bool disabled;
  final bool showValues;
  final String? unit;
  final BcChangeHandler<BcRangeValue>? onChange;

  const BcRangeSlider({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.showValues = false,
    this.unit,
    this.onChange,
  });

  @override
  State<BcRangeSlider> createState() => _BcRangeSliderState();
}

class _BcRangeSliderState extends State<BcRangeSlider> {
  BcRangeValue _internalValue = const BcRangeValue(min: 0, max: 100);

  @override
  void initState() {
    super.initState();
    _internalValue = _normalize(
      widget.defaultValue ?? BcRangeValue(min: widget.min, max: widget.max),
    );
  }

  @override
  void didUpdateWidget(BcRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internalValue = _normalize(
        widget.defaultValue ?? BcRangeValue(min: widget.min, max: widget.max),
      );
    }
  }

  BcRangeValue get _current => _normalize(widget.value ?? _internalValue);

  BcRangeValue _normalize(BcRangeValue v) {
    var lo = v.min.clamp(widget.min, widget.max).toDouble();
    var hi = v.max.clamp(widget.min, widget.max).toDouble();

    if (widget.step > 0 && widget.step < (widget.max - widget.min)) {
      lo = _snap(lo);
      hi = _snap(hi);
    }

    if (lo > hi) {
      lo = hi;
    }

    return BcRangeValue(min: lo, max: hi);
  }

  double _snap(double v) {
    final steps = ((v - widget.min) / widget.step).round();
    return (widget.min + steps * widget.step)
        .clamp(widget.min, widget.max)
        .toDouble();
  }

  void _handleChange(RangeValues values) {
    if (widget.disabled) return;

    final normalized = _normalize(BcRangeValue(
      min: values.start,
      max: values.end,
    ));

    if (widget.value == null) {
      setState(() => _internalValue = normalized);
    }

    widget.onChange?.call(
      normalized,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  String _formatValue(double v) {
    final displayValue =
        v.toInt() == v ? v.toInt().toString() : v.toStringAsFixed(1);
    return '$displayValue${widget.unit ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final divisions =
        widget.step > 0 && widget.step < (widget.max - widget.min)
            ? ((widget.max - widget.min) / widget.step).round()
            : null;

    final slider = RangeSlider(
      key: const Key('bc_range_slider'),
      values: RangeValues(current.min, current.max),
      min: widget.min,
      max: widget.max,
      divisions: divisions,
      onChanged: widget.disabled ? null : _handleChange,
      activeColor: widget.disabled ? BcTheme.mutedForeground : BcTheme.primary,
      inactiveColor: BcTheme.muted,
    );

    final children = <Widget>[];

    if (widget.label != null || widget.showValues) {
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label != null)
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.labelMedium,
              )
            else
              const SizedBox.shrink(),
            if (widget.showValues)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatValue(current.min),
                    key: const Key('bc_range_value_min'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: BcTheme.mutedForeground,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 14,
                      color: BcTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatValue(current.max),
                    key: const Key('bc_range_value_max'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: BcTheme.mutedForeground,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      );
    }

    children.add(slider);

    if (widget.disabled) {
      return Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
