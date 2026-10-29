import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_aspect_ratio.dart';

void main() {
  // The harness gives the child a bounded width (300) and an unbounded
  // height via an Align (loose constraints), so BcAspectRatio is free to
  // compute its own height from the width/ratio. A tight 300x300 box would
  // force the height to 300 and defeat the ratio.
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: Align(
            alignment: Alignment.topLeft,
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets(
      'BcAspectRatio enforces the configured width/height ratio on its child (VAL-M4-034)',
      (tester) async {
    // ratio = w/h = 16/9 => height = width / ratio = 300 / 1.777... = 168.75
    const ratio = 16.0 / 9.0;
    await tester.pumpWidget(harness(
      const BcAspectRatio(
        ratio: ratio,
        child: ColoredBox(
          key: ValueKey('child'),
          color: Colors.red,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final boxRect = tester.getRect(find.byType(BcAspectRatio));
    final childRect = tester.getRect(find.byKey(const ValueKey('child')));

    // The container width is bounded to 300 by the harness.
    expect(boxRect.width, closeTo(300, 1.0));
    // Height must equal width * (h / w) = width / ratio.
    const expectedHeight = 300 / ratio;
    expect(boxRect.height, closeTo(expectedHeight, 1.0),
        reason: 'height should equal width * (h / w)');

    // The child fills the computed box exactly (tight constraints).
    expect(childRect.width, closeTo(boxRect.width, 0.5),
        reason: 'child width should fill the box');
    expect(childRect.height, closeTo(boxRect.height, 0.5),
        reason: 'child height should fill the box');
  });

  testWidgets('BcAspectRatio square ratio renders equal width and height (VAL-M4-034)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcAspectRatio(
        ratio: 1,
        child: ColoredBox(key: ValueKey('child'), color: Colors.blue),
      ),
    ));
    await tester.pumpAndSettle();

    final boxRect = tester.getRect(find.byType(BcAspectRatio));
    expect(boxRect.width, closeTo(300, 1.0));
    expect(boxRect.height, closeTo(300, 1.0),
        reason: 'square ratio should produce equal width and height');
  });

  testWidgets(
      'BcAspectRatio ratio updates propagate to the child box without overflow (VAL-M4-035)',
      (tester) async {
    // Start with a wide ratio (16/9).
    await tester.pumpWidget(harness(
      const BcAspectRatio(
        ratio: 16.0 / 9.0,
        child: ColoredBox(key: ValueKey('child'), color: Colors.green),
      ),
    ));
    await tester.pumpAndSettle();

    final wideHeight = tester.getRect(find.byType(BcAspectRatio)).height;
    expect(wideHeight, closeTo(300 / (16 / 9), 1.0));

    // Switch to a tall ratio (9/16) — height should grow, no overflow.
    await tester.pumpWidget(harness(
      const BcAspectRatio(
        ratio: 9.0 / 16.0,
        child: ColoredBox(key: ValueKey('child'), color: Colors.green),
      ),
    ));
    await tester.pumpAndSettle();

    final tallHeight = tester.getRect(find.byType(BcAspectRatio)).height;
    const expectedTall = 300 / (9 / 16);
    expect(tallHeight, closeTo(expectedTall, 1.0),
        reason: 'tall ratio should produce a taller box');
    expect(tallHeight > wideHeight, isTrue,
        reason: 'switching from wide to tall ratio should increase height');

    // No overflow exception should be thrown.
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'BcAspectRatio clips child content that overflows the aspect box (VAL-M4-036)',
      (tester) async {
    // A child that paints taller than the box via an OverflowBox (which
    // ignores the tight constraints from the aspect box). The aspect box
    // must clip the painted content to its own bounds.
    await tester.pumpWidget(harness(
      const BcAspectRatio(
        ratio: 2.0, // height = 300 / 2 = 150
        child: OverflowBox(
          minHeight: 600,
          maxHeight: 600,
          alignment: Alignment.topCenter,
          child: ColoredBox(color: Colors.orange),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'clipping must suppress overflow assertions');

    final boxRect = tester.getRect(find.byType(BcAspectRatio));
    expect(boxRect.height, closeTo(150, 1.0),
        reason: 'ratio 2 with width 300 => height 150');

    // The aspect box render object must paint with a clipRect so that
    // child content overflowing the computed box is not visible. The
    // `paints` matcher inspects the display list recorded during paint.
    final ro = tester.renderObject(find.byType(BcAspectRatio));
    expect(
      ro,
      paints..clipRect(),
      reason:
          'the aspect box must clip its child via a clipRect on paint',
    );

    // The box itself is sized to the aspect-correct height (150). The
    // oversized child (600px) is clipped within it — verified by the
    // clipRect paint command above and the absence of an overflow error.
    expect(boxRect.height, closeTo(150, 1.0));
  });

  testWidgets('BcAspectRatio renders without a child without assertion (VAL-M4-036)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcAspectRatio(ratio: 1.5),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(BcAspectRatio), findsOneWidget);
  });
}
