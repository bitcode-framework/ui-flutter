library bc_slider;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Single-thumb range slider with min/max/step clamping (ADR-011 Phase 5c — M2 forms).
///
/// Controlled mode: parent provides [value]; uncontrolled: [defaultValue].
/// Values are clamped to [min]–[max] and snapped to [step] granularity.
///
/// When [showValue] is true, the current value is displayed (optionally
/// suffixed with [unit]).
///
/// Platform-aware: uses Flutter's [Slider] widget which automatically renders
/// Cupertino-style on iOS and Material on Android.
///
/// When [disabled] is true, all pointer drags and keyboard events are ignored.
class BcSlider extends StatefulWidget {
  final String? name;
  final String? label;
  final double? value;
  final double? defaultValue;
  final double min;
  final double max;
  final double step;
  final bool disabled;
  final bool showValue;
  final String? unit;
  final BcChangeHandler<double>? onChange;

  const BcSlider({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.showValue = false,
    this.unit,
    this.onChange,
  });

  @override
  State<BcSlider> createState() => _BcSliderState();
}

class _BcSliderState extends State<BcSlider> {
  double _internalValue = 0;

  @override
  void initState() {
    super.initState();
    _internalValue = _clamp(widget.defaultValue ?? widget.min);
  }

  @override
  void didUpdateWidget(BcSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internalValue = _clamp(widget.defaultValue ?? widget.min);
    }
  }

  double get _current => _clamp(widget.value ?? _internalValue);

  double _clamp(double v) {
    final range = widget.max - widget.min;
    if (range <= 0) return widget.min;

    var clamped = v.clamp(widget.min, widget.max).toDouble();
    if (widget.step > 0 && widget.step < range) {
      final steps = ((clamped - widget.min) / widget.step).round();
      clamped = (widget.min + steps * widget.step).clamp(
        widget.min,
        widget.max,
      );
    }
    return clamped;
  }

  void _handleChange(double v) {
    if (widget.disabled) return;

    final clamped = _clamp(v);

    if (widget.value == null) {
      setState(() => _internalValue = clamped);
    }

    widget.onChange?.call(
      clamped,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  String _formatValue(double v) {
    final displayValue = v.toInt() == v ? v.toInt().toString() : v.toStringAsFixed(1);
    return '$displayValue${widget.unit ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final slider = Slider(
      key: const Key('bc_slider'),
      value: _current,
      min: widget.min,
      max: widget.max,
      divisions: widget.step > 0 && widget.step < (widget.max - widget.min)
          ? ((widget.max - widget.min) / widget.step).round()
          : null,
      onChanged: widget.disabled ? null : _handleChange,
      activeColor: widget.disabled ? BcTheme.mutedForeground : BcTheme.primary,
      inactiveColor: BcTheme.muted,
    );

    final children = <Widget>[];

    if (widget.label != null || widget.showValue) {
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
            if (widget.showValue)
              Text(
                _formatValue(_current),
                style: TextStyle(
                  fontSize: 14,
                  color: widget.disabled
                      ? BcTheme.mutedForeground
                      : BcTheme.mutedForeground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      );
    }

    children.add(slider);

    if (widget.disabled) {
      return Opacity(opacity: 0.5, child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
