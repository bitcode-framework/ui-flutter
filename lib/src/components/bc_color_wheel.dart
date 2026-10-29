library bc_color_wheel;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Interactive hue/saturation color wheel (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcColorWheelContract] ({ hue?, size?, label?, disabled?,
/// onChange? }).
///
/// Renders a circular color wheel. Dragging within the wheel updates the
/// selected color and invokes [onValueChange] with the HSV color value
/// (as [HSVColor]) and a [BcChangeMeta] whose source reflects pointer
/// interaction. When [value] is controlled, the indicator is positioned
/// at the coordinates corresponding to the HSV value.
class BcColorWheel extends StatefulWidget {
  final String? name;
  final HSVColor? value;
  final HSVColor? defaultValue;
  final double size;
  final String? label;
  final bool disabled;
  final BcChangeHandler<HSVColor>? onValueChange;

  const BcColorWheel({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.size = 200,
    this.label,
    this.disabled = false,
    this.onValueChange,
  });

  @override
  State<BcColorWheel> createState() => _BcColorWheelState();
}

class _BcColorWheelState extends State<BcColorWheel> {
  HSVColor? _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue;
  }

  @override
  void didUpdateWidget(BcColorWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internal = widget.defaultValue;
    }
  }

  HSVColor get _current =>
      widget.value ?? _internal ?? const HSVColor.fromAHSV(1.0, 0, 1.0, 1.0);

  HSVColor _offsetToHsv(Offset offset, double radius) {
    final dx = offset.dx - radius;
    final dy = offset.dy - radius;
    final distance = math.sqrt(dx * dx + dy * dy);
    final r = distance.clamp(0.0, radius);
    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    final hue = (angle * 180.0 / math.pi) % 360.0;
    final saturation = r / radius;
    return HSVColor.fromAHSV(1.0, hue, saturation, 1.0);
  }

  void _handlePan(DragUpdateDetails details) {
    if (widget.disabled) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);
    final radius = widget.size / 2;

    final hsv = _offsetToHsv(localPos, radius);

    if (widget.value == null) {
      setState(() => _internal = hsv);
    }

    widget.onValueChange?.call(
      hsv,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handlePanDown(DragDownDetails details) {
    if (widget.disabled) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);
    final radius = widget.size / 2;

    final hsv = _offsetToHsv(localPos, radius);

    if (widget.value == null) {
      setState(() => _internal = hsv);
    }

    widget.onValueChange?.call(
      hsv,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wheel = GestureDetector(
      key: const Key('bc_color_wheel'),
      onPanDown: _handlePanDown,
      onPanUpdate: _handlePan,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          key: const Key('bc_color_wheel_canvas'),
          painter: _ColorWheelPainter(
            current: _current,
            diameter: widget.size,
          ),
        ),
      ),
    );

    final disabledWheel =
        widget.disabled ? Opacity(opacity: 0.4, child: wheel) : wheel;

    if (widget.label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label!,
            key: const Key('bc_color_wheel_label'),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          disabledWheel,
        ],
      );
    }

    return disabledWheel;
  }
}

class _ColorWheelPainter extends CustomPainter {
  final HSVColor current;
  final double diameter;

  _ColorWheelPainter({
    required this.current,
    required this.diameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    if (radius <= 0) return;

    final wheelPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: List.generate(
          360,
          (h) =>
              HSVColor.fromAHSV(1.0, h.toDouble(), 1.0, 1.0).toColor(),
        ),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, wheelPaint);

    const segments = 24;
    for (var i = 0; i < segments; i++) {
      final angle1 = (i / segments) * 2 * math.pi;
      final angle2 = ((i + 1) / segments) * 2 * math.pi;
      for (var j = 0; j < segments; j++) {
        final r1 = (j / segments) * radius;
        final r2 = ((j + 1) / segments) * radius;
        final midR = (r1 + r2) / 2;
        final midAngle = (angle1 + angle2) / 2;

        final hue = (midAngle * 180 / math.pi) % 360;
        final sat = (midR / radius).clamp(0.0, 1.0);

        final color = HSVColor.fromAHSV(1.0, hue, sat, 1.0).toColor();
        final paint = Paint()..color = color;

        final p1 = Offset(
          center.dx + r1 * math.cos(midAngle),
          center.dy + r1 * math.sin(midAngle),
        );
        final p2 = Offset(
          center.dx + r2 * math.cos(midAngle),
          center.dy + r2 * math.sin(midAngle),
        );
        canvas.drawLine(p1, p2, paint..strokeWidth = radius / segments + 2);
      }
    }

    final indAngle = current.hue * math.pi / 180.0 - math.pi / 2;
    final indR = current.saturation * radius;
    final indPos = Offset(
      center.dx + indR * math.cos(indAngle),
      center.dy + indR * math.sin(indAngle),
    );

    final indPaint = Paint()
      ..color = current.toColor()
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indPos, 12, indPaint);

    final borderPaint = Paint()
      ..color = BcTheme.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(indPos, 12, borderPaint);

    final outerBorderPaint = Paint()
      ..color = current.toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(indPos, 13.5, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return current != oldDelegate.current ||
        diameter != oldDelegate.diameter;
  }
}
