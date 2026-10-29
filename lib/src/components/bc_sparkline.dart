library bc_sparkline;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcSparkline extends StatelessWidget {
  final List<double> data;
  final double width;
  final double height;
  final BcSparklineType type;
  final bool showDot;
  final double strokeWidth;
  final String? ariaLabel;
  final Color color;

  const BcSparkline({
    super.key,
    this.data = const [],
    this.width = 80,
    this.height = 24,
    this.type = BcSparklineType.line,
    this.showDot = false,
    this.strokeWidth = 1.5,
    this.ariaLabel,
    this.color = BcTheme.foreground,
  });

  @override
  Widget build(BuildContext context) {
    CustomPainter painter;

    switch (type) {
      case BcSparklineType.line:
        painter = SparklineLinePainter(
          data: data,
          width: width,
          height: height,
          color: color,
          strokeWidth: strokeWidth,
          showDot: showDot,
        );
        break;
      case BcSparklineType.bar:
        painter = SparklineBarPainter(
          data: data,
          width: width,
          height: height,
          color: color,
        );
        break;
      case BcSparklineType.area:
        painter = SparklineAreaPainter(
          data: data,
          width: width,
          height: height,
          color: color,
          strokeWidth: strokeWidth,
        );
        break;
    }

    return Semantics(
      container: true,
      label: ariaLabel ?? 'Sparkline',
      child: SizedBox(
        key: const Key('bc_sparkline'),
        width: width,
        height: height,
        child: CustomPaint(
          size: Size(width, height),
          painter: painter,
        ),
      ),
    );
  }
}

({double min, double max, double range}) _bounds(List<double> data) {
  if (data.isEmpty) return (min: 0, max: 0, range: 0);
  double min = data[0];
  double max = data[0];
  for (final n in data) {
    if (n < min) min = n;
    if (n > max) max = n;
  }
  final range = max - min;
  return (min: min, max: max, range: range == 0 ? 1 : range);
}

List<Offset> _points(
  List<double> data,
  double w,
  double h,
) {
  if (data.isEmpty) return [];
  final b = _bounds(data);
  final step = data.length > 1 ? w / (data.length - 1) : 0.0;
  return List.generate(data.length, (i) {
    final x = i * step;
    final y = h - ((data[i] - b.min) / b.range) * h;
    return Offset(x, y);
  });
}

class SparklineLinePainter extends CustomPainter {
  final List<double> data;
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final bool showDot;

  SparklineLinePainter({
    required this.data,
    required this.width,
    required this.height,
    required this.color,
    required this.strokeWidth,
    required this.showDot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final points = _points(data, size.width, size.height);
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    if (showDot && points.isNotEmpty) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points.last, 2.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklineLinePainter old) =>
      old.data != data ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.showDot != showDot ||
      old.width != width ||
      old.height != height;
}

class SparklineBarPainter extends CustomPainter {
  final List<double> data;
  final double width;
  final double height;
  final Color color;

  SparklineBarPainter({
    required this.data,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final b = _bounds(data);
    final barSpace = size.width / data.length;
    final barWidth = (barSpace * 0.6).clamp(1.0, double.infinity);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < data.length; i++) {
      final barHeight = ((data[i] - b.min) / b.range) * size.height;
      final x = i * barSpace + (barSpace - barWidth) / 2;
      final y = size.height - barHeight;
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SparklineBarPainter old) =>
      old.data != data ||
      old.color != color ||
      old.width != width ||
      old.height != height;
}

class SparklineAreaPainter extends CustomPainter {
  final List<double> data;
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;

  SparklineAreaPainter({
    required this.data,
    required this.width,
    required this.height,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final points = _points(data, size.width, size.height);
    if (points.isEmpty) return;

    final areaPath = Path();
    areaPath.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.lineTo(points[0].dx, size.height);
    areaPath.close();

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant SparklineAreaPainter old) =>
      old.data != data ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.width != width ||
      old.height != height;
}
