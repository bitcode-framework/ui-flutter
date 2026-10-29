import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_square.dart';

void main() {
  Widget harness(Widget child) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: Align(
              alignment: Alignment.topLeft,
              child: child,
            ),
          ),
        ),
      );

  group('VAL-M7-009 — BcSquare constrains child to square bounds', () {
    testWidgets('renders equal width and height with explicit size', (tester) async {
      await tester.pumpWidget(harness(
        const BcSquare(size: 100),
      ));
      await tester.pumpAndSettle();

      final box = tester.getSize(find.byKey(const Key('bc_square')));
      expect(box.width, 100);
      expect(box.height, 100);
    });

    testWidgets('without size uses AspectRatio 1.0', (tester) async {
      await tester.pumpWidget(harness(
        const BcSquare(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AspectRatio), findsOneWidget);
      final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspect.aspectRatio, 1.0);
    });

    testWidgets('renders with child content', (tester) async {
      await tester.pumpWidget(harness(
        const BcSquare(
          size: 80,
          child: SizedBox(key: Key('inner')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('inner')), findsOneWidget);
    });

    testWidgets('rounded option applies ClipRRect', (tester) async {
      await tester.pumpWidget(harness(
        const BcSquare(size: 80, rounded: true),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('renders without child without error', (tester) async {
      await tester.pumpWidget(harness(
        const BcSquare(size: 50),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
