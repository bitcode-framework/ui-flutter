library bc_color_area;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// 2D saturation/value drag area (ADR-011 Phase 5c).
///
/// Displays a square area where the horizontal axis maps to saturation
/// (0-100, left to right) and the vertical axis maps to value/brightness
/// (100-0, top to bottom). The [hue] prop tints the gradient.
/// Emits a [BcSvValue] via [onChange] with `BcChangeReason.input`.
class BcColorArea extends StatefulWidget {
  final String? name;
  final double hue;
  final BcSvValue? value;
  final BcSvValue? defaultValue;
  final bool disabled;
  final double width;
  final double height;
  final BcChangeHandler<BcSvValue>? onChange;

  const BcColorArea({
    super.key,
    this.name,
    this.hue = 0,
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.width = 200,
    this.height = 200,
    this.onChange,
  });

  @override
  State<BcColorArea> createState() => _BcColorAreaState();
}

class _BcColorAreaState extends State<BcColorArea> {
  BcSvValue? _internal;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue;
  }

  BcSvValue get _effective => widget.value ?? _internal ?? const BcSvValue(saturation: 100, value: 100);

  BcSvValue _clampSV(BcSvValue sv) {
    return BcSvValue(
      saturation: sv.saturation.clamp(0.0, 100.0),
      value: sv.value.clamp(0.0, 100.0),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.disabled) return;
    final box = context.findRenderObject() as RenderBox;
    final pos = box.globalToLocal(details.globalPosition);
    final w = box.size.width;
    final h = box.size.height;

    // Saturation = x/width * 100, clamped 0-100
    // Value = (1 - y/height) * 100, clamped 0-100
    final sat = (pos.dx / w) * 100;
    final val = (1 - (pos.dy / h)) * 100;

    final sv = _clampSV(BcSvValue(saturation: sat, value: val));
    setState(() => _internal = sv);
    widget.onChange?.call(
      sv,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sv = _effective;
    final hueColor = HSLColor.fromAHSL(1.0, widget.hue, 1.0, 0.5).toColor();

    final area = GestureDetector(
      key: const Key('bc_color_area'),
      onPanUpdate: _onPanUpdate,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: BcTheme.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _ColorAreaPainter(
              hueColor: hueColor,
              saturation: sv.saturation,
              value: sv.value,
              disabled: widget.disabled,
            ),
          ),
        ),
      ),
    );

    return widget.disabled
        ? Opacity(opacity: 0.4, child: area)
        : area;
  }
}

class _ColorAreaPainter extends CustomPainter {
  final Color hueColor;
  final double saturation;
  final double value;
  final bool disabled;

  _ColorAreaPainter({
    required this.hueColor,
    required this.saturation,
    required this.value,
    required this.disabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base hue layer
    final basePaint = Paint()..color = hueColor;
    canvas.drawRect(Offset.zero & size, basePaint);

    // Saturation gradient (white to transparent, left to right)
    final satPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.white, Colors.transparent],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, satPaint);

    // Value gradient (transparent to black, top to bottom)
    final valPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, valPaint);

    // Marker at current SV position
    final markerX = (saturation / 100) * size.width;
    final markerY = (1 - value / 100) * size.height;
    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final markerBorderPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(markerX, markerY), 7, markerPaint);
    canvas.drawCircle(Offset(markerX, markerY), 7, markerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _ColorAreaPainter oldDelegate) {
    return hueColor != oldDelegate.hueColor ||
        saturation != oldDelegate.saturation ||
        value != oldDelegate.value ||
        disabled != oldDelegate.disabled;
  }
}
