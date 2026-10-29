library bc_watermark;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Overlays a watermark text/pattern across child content
/// (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcWatermarkContract] ({ text?, opacity?, rotate?,
/// fontSize?, gap? }).
/// Renders [child] with a semi-transparent [text] overlaid at the given
/// [rotate] angle (degrees) and [opacity] (0.0–1.0). When [text] is null
/// or empty, only the child renders (no overlay).
/// All colors use BcTheme tokens with alpha via withValues(alpha:).
class BcWatermark extends StatelessWidget {
  final Widget? child;
  final String? text;
  final double opacity;
  final double rotate;
  final double fontSize;
  final double gap;

  const BcWatermark({
    super.key,
    this.child,
    this.text,
    this.opacity = 0.15,
    this.rotate = -22,
    this.fontSize = 16,
    this.gap = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return child ?? const SizedBox.shrink();
    }

    return Stack(
      key: const Key('bc_watermark'),
      children: [
        if (child != null) child!,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRect(
              child: CustomPaint(
                key: const Key('bc_watermark_pattern'),
                painter: _WatermarkPainter(
                  text: text!,
                  opacity: opacity.clamp(0.0, 1.0),
                  rotate: rotate,
                  fontSize: fontSize,
                  gap: gap,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String text;
  final double opacity;
  final double rotate;
  final double fontSize;
  final double gap;

  _WatermarkPainter({
    required this.text,
    required this.opacity,
    required this.rotate,
    required this.fontSize,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: BcTheme.mutedForeground.withValues(alpha: opacity),
      fontSize: fontSize,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final cellWidth = textPainter.width + gap;
    final cellHeight = textPainter.height + gap;

    final radians = rotate * math.pi / 180.0;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(radians);

    final diag = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    final halfW = diag / 2 + cellWidth;
    final halfH = diag / 2 + cellHeight;

    final startX = -halfW;
    final startY = -halfH;
    final endX = halfW;
    final endY = halfH;

    for (double y = startY; y < endY; y += cellHeight) {
      for (double x = startX; x < endX; x += cellWidth) {
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) {
    return text != oldDelegate.text ||
        opacity != oldDelegate.opacity ||
        rotate != oldDelegate.rotate ||
        fontSize != oldDelegate.fontSize ||
        gap != oldDelegate.gap;
  }
}
