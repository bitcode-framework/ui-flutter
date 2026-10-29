import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_sparkline.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  testWidgets(
      'BcSparkline renders data series as CustomPaint '
      '(VAL-M5-011)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5, 7],
        width: 80,
        height: 24,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_sparkline')), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets(
      'BcSparkline empty data renders without error '
      '(VAL-M5-011)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(data: [], width: 80, height: 24),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_sparkline')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'BcSparkline single data point renders without error '
      '(VAL-M5-011)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(data: [5], width: 80, height: 24),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_sparkline')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'BcSparkline line type uses SparklineLinePainter '
      '(VAL-M5-012)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5],
        type: BcSparklineType.line,
        width: 80,
        height: 24,
      ),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    expect(customPaint.painter, isA<SparklineLinePainter>());
  });

  testWidgets(
      'BcSparkline bar type uses SparklineBarPainter '
      '(VAL-M5-012)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5],
        type: BcSparklineType.bar,
        width: 80,
        height: 24,
      ),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    expect(customPaint.painter, isA<SparklineBarPainter>());
  });

  testWidgets(
      'BcSparkline area type uses SparklineAreaPainter '
      '(VAL-M5-012)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5],
        type: BcSparklineType.area,
        width: 80,
        height: 24,
      ),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    expect(customPaint.painter, isA<SparklineAreaPainter>());
  });

  testWidgets(
      'BcSparkline color resolves from BcTheme token '
      '(VAL-M5-013)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5],
        type: BcSparklineType.line,
        width: 80,
        height: 24,
      ),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    final painter = customPaint.painter as SparklineLinePainter;
    expect(painter.color, BcTheme.foreground,
        reason: 'Color should resolve from a BcTheme token');
  });

  testWidgets(
      'BcSparkline stroke width is positive and within range '
      '(VAL-M5-013)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5],
        type: BcSparklineType.line,
        width: 80,
        height: 24,
        strokeWidth: 1.5,
      ),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    final painter = customPaint.painter as SparklineLinePainter;
    expect(painter.strokeWidth, greaterThan(0));
    expect(painter.strokeWidth, lessThanOrEqualTo(24),
        reason: 'Stroke width should not exceed canvas height');
  });

  testWidgets(
      'BcSparkline custom stroke width is applied '
      '(VAL-M5-013)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5],
        type: BcSparklineType.line,
        width: 80,
        height: 24,
        strokeWidth: 3.0,
      ),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    final painter = customPaint.painter as SparklineLinePainter;
    expect(painter.strokeWidth, 3.0);
  });

  testWidgets(
      'BcSparkline default type is line '
      '(VAL-M5-012)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(data: [1, 4, 2, 8, 5]),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    expect(customPaint.painter, isA<SparklineLinePainter>());
  });

  testWidgets(
      'BcSparkline showDot renders a dot at last point '
      '(VAL-M5-012)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSparkline(
        data: [1, 4, 2, 8, 5],
        showDot: true,
        width: 80,
        height: 24,
      ),
    ));
    await tester.pumpAndSettle();

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(const Key('bc_sparkline')),
        matching: find.byType(CustomPaint),
      ),
    );

    final painter = customPaint.painter as SparklineLinePainter;
    expect(painter.showDot, isTrue);
  });
}
