library bc_color_slider;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// 1D hue slider (ADR-011 Phase 5c).
///
/// Displays a horizontal slider with a hue spectrum gradient track.
/// Dragging the thumb emits a clamped [double] hue value via [onChange]
/// with `BcChangeReason.input`. The [label] prop renders adjacent to the
/// slider. Controlled [value] outside [min]/[max] is clamped for rendering.
class BcColorSlider extends StatefulWidget {
  final String? name;
  final String? label;
  final double min;
  final double max;
  final double value;
  final double? defaultValue;
  final bool disabled;
  final BcChangeHandler<double>? onChange;

  const BcColorSlider({
    super.key,
    this.name,
    this.label,
    this.min = 0,
    this.max = 360,
    this.value = 0,
    this.defaultValue,
    this.disabled = false,
    this.onChange,
  });

  @override
  State<BcColorSlider> createState() => _BcColorSliderState();
}

class _BcColorSliderState extends State<BcColorSlider> {
  double? _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue;
  }

  double get _effective {
    final v = _internal ?? widget.value;
    return v.clamp(widget.min, widget.max);
  }

  double _valueToFraction(double v) {
    final range = widget.max - widget.min;
    if (range == 0) return 0;
    return ((v - widget.min) / range).clamp(0.0, 1.0);
  }

  double _fractionToValue(double frac) {
    final f = frac.clamp(0.0, 1.0);
    return widget.min + f * (widget.max - widget.min);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.disabled) return;
    final box = context.findRenderObject() as RenderBox;
    final pos = box.globalToLocal(details.globalPosition);
    final w = box.size.width;

    final frac = pos.dx / w;
    final val = _fractionToValue(frac);

    setState(() => _internal = val);
    widget.onChange?.call(
      val,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fraction = _valueToFraction(_effective);

    final slider = GestureDetector(
      key: const Key('bc_color_slider'),
      onPanUpdate: _onPanUpdate,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BcTheme.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Gradient track (full hue spectrum)
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _HueGradientPainter(),
                  ),
                  // Thumb
                  Positioned(
                    left: (fraction * constraints.maxWidth - 14)
                        .clamp(0.0, constraints.maxWidth - 28),
                    top: (constraints.maxHeight - 28) / 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black26,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    final disabledSlider = widget.disabled
        ? Opacity(opacity: 0.4, child: slider)
        : slider;

    if (widget.label != null) {
      return Row(
        children: [
          Text(
            widget.label!,
            key: const Key('bc_color_slider_label'),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: 12),
          Expanded(child: disabledSlider),
        ],
      );
    }

    return disabledSlider;
  }
}

class _HueGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: List.generate(
          13,
          (i) => HSLColor.fromAHSL(1.0, (i * 30).toDouble(), 1.0, 0.5).toColor(),
        ),
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
