library bc_knob;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcKnob extends StatefulWidget {
  final double? value;
  final double? defaultValue;
  final double min;
  final double max;
  final double size;
  final String? label;
  final bool disabled;
  final BcChangeHandler<double>? onChange;

  const BcKnob({
    super.key,
    this.value,
    this.defaultValue,
    this.min = 0,
    this.max = 100,
    this.size = 96,
    this.label,
    this.disabled = false,
    this.onChange,
  });

  @override
  State<BcKnob> createState() => _BcKnobState();
}

class _BcKnobState extends State<BcKnob> {
  double _internalValue = 0;
  double _dragStartValue = 0;

  @override
  void initState() {
    super.initState();
    _internalValue = _clamp(widget.defaultValue ?? widget.min);
  }

  @override
  void didUpdateWidget(BcKnob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internalValue = _clamp(widget.defaultValue ?? widget.min);
    }
  }

  double get _current => _clamp(widget.value ?? _internalValue);

  double _clamp(double v) {
    final min = widget.min;
    final max = widget.max;
    if (max <= min) return min;
    return v.clamp(min, max).toDouble();
  }

  double _fractionFromValue(double value) {
    final range = widget.max - widget.min;
    if (range <= 0) return 0;
    return ((value - widget.min) / range).clamp(0.0, 1.0);
  }

  double get _angleFromFraction {
    const startAngle = -135.0;
    const sweepAngle = 270.0;
    return startAngle + sweepAngle * _fractionFromValue(_current);
  }

  void _handlePanStart(DragStartDetails details) {
    if (widget.disabled) return;
    _dragStartValue = _current;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.disabled) return;

    final delta = details.delta;
    final verticalMovement = -delta.dy;
    final horizontalMovement = delta.dx;
    final combined = verticalMovement + horizontalMovement * 0.5;

    final range = widget.max - widget.min;
    final sensitivity = range / 200;

    final newValue = _clamp(_dragStartValue + combined * sensitivity);
    _dragStartValue = newValue;

    if (widget.value == null) {
      setState(() => _internalValue = newValue);
    }

    widget.onChange?.call(
      newValue,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handleKeyDown(KeyEvent event) {
    if (widget.disabled) return;
    if (event is! KeyDownEvent) return;

    final range = widget.max - widget.min;
    final step = range > 0 ? range / 100 : 1.0;

    double? next;
    BcChangeReason? reason;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      next = _clamp(_current + step);
      reason = BcChangeReason.increment;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      next = _clamp(_current - step);
      reason = BcChangeReason.decrement;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      next = widget.min;
      reason = BcChangeReason.programmatic;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      next = widget.max;
      reason = BcChangeReason.programmatic;
    }

    if (next == null) return;
    final nextValue = next;

    if (widget.value == null) {
      setState(() => _internalValue = nextValue);
    }

    widget.onChange?.call(
      nextValue,
      BcChangeMeta(
        reason: reason!,
        source: BcEventSource.keyboard,
      ),
    );
  }

  String _formatValue(double v) {
    final intVal = v.toInt();
    return intVal == v ? intVal.toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        _handleKeyDown(event);
        return KeyEventResult.ignored;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            key: const Key('bc_knob_gesture'),
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            child: _buildDial(),
          ),
          if (widget.label != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14,
                color: widget.disabled
                    ? BcTheme.mutedForeground
                    : BcTheme.foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDial() {
    final dialSize = widget.size;
    final angle = _angleFromFraction * (math.pi / 180);

    return SizedBox(
      width: dialSize,
      height: dialSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(dialSize, dialSize),
            painter: _KnobTrackPainter(
              fraction: _fractionFromValue(_current),
              disabled: widget.disabled,
            ),
          ),
          Container(
            key: const Key('bc_knob_dial'),
            width: dialSize * 0.75,
            height: dialSize * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.disabled ? BcTheme.muted : BcTheme.background,
              border: Border.all(
                color: widget.disabled
                    ? BcTheme.mutedForeground.withValues(alpha: 0.3)
                    : BcTheme.border,
                width: 2,
              ),
              boxShadow: widget.disabled
                  ? null
                  : [
                      BoxShadow(
                        color: BcTheme.foreground.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                _formatValue(_current),
                style: TextStyle(
                  fontSize: dialSize * 0.18,
                  fontWeight: FontWeight.w500,
                  color: widget.disabled
                      ? BcTheme.mutedForeground
                      : BcTheme.foreground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          Positioned(
            top: dialSize * 0.08,
            child: Transform.rotate(
              angle: angle,
              child: Container(
                width: 3,
                height: dialSize * 0.15,
                decoration: BoxDecoration(
                  color: widget.disabled
                      ? BcTheme.mutedForeground
                      : BcTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnobTrackPainter extends CustomPainter {
  final double fraction;
  final bool disabled;

  _KnobTrackPainter({required this.fraction, required this.disabled});

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -135.0 * (math.pi / 180);
    const sweepAngle = 270.0 * (math.pi / 180);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 4.0;

    final trackPaint = Paint()
      ..color = BcTheme.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, trackPaint);

    if (fraction > 0) {
      final activePaint = Paint()
        ..color = disabled ? BcTheme.mutedForeground : BcTheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        arcRect,
        startAngle,
        sweepAngle * fraction,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _KnobTrackPainter oldDelegate) {
    return fraction != oldDelegate.fraction ||
        disabled != oldDelegate.disabled;
  }
}
