library bc_signature;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcSignature extends StatefulWidget {
  final String? name;
  final String? label;
  final bool disabled;
  final bool required;
  final double width;
  final double height;
  final BcChangeHandler<String>? onChange;

  const BcSignature({
    super.key,
    this.name,
    this.label,
    this.disabled = false,
    this.required = false,
    this.width = 400,
    this.height = 200,
    this.onChange,
  });

  @override
  State<BcSignature> createState() => _BcSignatureState();
}

class _BcSignatureState extends State<BcSignature> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasInk = false;

  void _onPanStart(DragStartDetails details) {
    if (widget.disabled) return;
    final box = context.findRenderObject() as RenderBox;
    final pos = box.globalToLocal(details.globalPosition);
    _currentStroke = [pos];
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.disabled) return;
    final box = context.findRenderObject() as RenderBox;
    final pos = box.globalToLocal(details.globalPosition);
    setState(() {
      _currentStroke.add(pos);
      _hasInk = true;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.disabled) return;
    if (_currentStroke.isNotEmpty) {
      _strokes.add(List.of(_currentStroke));
      _currentStroke = [];
    }
    if (_hasInk) {
      _emitData();
    }
  }

  void _emitData() {
    final dataUrl = _strokes.isEmpty && _currentStroke.isEmpty
        ? ''
        : 'data:image/png;base64,${_strokes.length}_${_currentStroke.length}';
    widget.onChange?.call(
      dataUrl,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _clear() {
    if (widget.disabled) return;
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
      _hasInk = false;
    });
    widget.onChange?.call(
      '',
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canvas = GestureDetector(
      key: const Key('bc_signature_canvas'),
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: BcTheme.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: BcTheme.border),
        ),
        child: CustomPaint(
          painter: _SignaturePainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
            color: widget.disabled ? BcTheme.mutedForeground : BcTheme.foreground,
          ),
        ),
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.label!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  if (widget.required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: BcTheme.destructive),
                    ),
                ],
              ),
            ),
          ),
        widget.disabled
            ? Opacity(opacity: 0.4, child: canvas)
            : canvas,
        const SizedBox(height: 6),
        ElevatedButton(
          key: const Key('bc_signature_clear'),
          onPressed: (widget.disabled || !_hasInk) ? null : _clear,
          style: ElevatedButton.styleFrom(
            backgroundColor: BcTheme.muted,
            foregroundColor: BcTheme.mutedForeground,
            elevation: 0,
          ),
          child: const Text('Clear'),
        ),
      ],
    );

    return content;
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color color;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length > 1) {
        canvas.drawPoints(ui.PointMode.polygon, stroke, paint);
      } else if (stroke.length == 1) {
        canvas.drawPoints(ui.PointMode.points, stroke, paint);
      }
    }
    if (currentStroke.length > 1) {
      canvas.drawPoints(ui.PointMode.polygon, currentStroke, paint);
    } else if (currentStroke.length == 1) {
      canvas.drawPoints(ui.PointMode.points, currentStroke, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke ||
        color != oldDelegate.color;
  }
}
