import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_circle.dart';

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

  group('VAL-M7-008 — BcCircle constrains child to circular bounds', () {
    testWidgets('renders circular clipping for child', (tester) async {
      await tester.pumpWidget(harness(
        const BcCircle(
          size: 100,
          child: SizedBox(key: Key('inner')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_circle')), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.byKey(const Key('inner')), findsOneWidget);
    });

    testWidgets('renders equal width and height', (tester) async {
      await tester.pumpWidget(harness(
        const BcCircle(size: 120),
      ));
      await tester.pumpAndSettle();

      final box = tester.getSize(find.byKey(const Key('bc_circle')));
      expect(box.width, 120);
      expect(box.height, 120);
    });

    testWidgets('without size uses AspectRatio 1.0', (tester) async {
      await tester.pumpWidget(harness(
        const BcCircle(child: SizedBox(key: Key('inner'))),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AspectRatio), findsOneWidget);
      final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspect.aspectRatio, 1.0);
    });

    testWidgets('renders with label below', (tester) async {
      await tester.pumpWidget(harness(
        const BcCircle(size: 80, label: 'Avatar'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Avatar'), findsOneWidget);
    });

    testWidgets('renders without child without error', (tester) async {
      await tester.pumpWidget(harness(
        const BcCircle(size: 50),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('bc_circle')), findsOneWidget);
    });
  });
}
