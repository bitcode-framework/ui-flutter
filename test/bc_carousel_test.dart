import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_carousel.dart';

void main() {
  final slides = <BcCarouselSlide>[
    const BcCarouselSlide(caption: 'Slide 1'),
    const BcCarouselSlide(caption: 'Slide 2'),
    const BcCarouselSlide(caption: 'Slide 3'),
  ];

  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 200,
          child: child,
        ),
      ),
    );
  }

  testWidgets(
      'BcCarousel renders slides with only active slide visible '
      '(VAL-M5-001)', (tester) async {
    await tester.pumpWidget(harness(
      BcCarousel(slides: slides),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Slide 1'), findsOneWidget,
        reason: 'Initial active slide (index 0) should be visible');
    expect(find.text('Slide 2'), findsNothing,
        reason: 'Non-active slide should not be visible');
    expect(find.text('Slide 3'), findsNothing,
        reason: 'Non-active slide should not be visible');

    expect(find.byKey(const Key('bc_carousel_slide_0')), findsOneWidget);
    expect(find.byKey(const Key('bc_carousel_slide_1')), findsOneWidget);
    expect(find.byKey(const Key('bc_carousel_slide_2')), findsOneWidget);
  });

  testWidgets(
      'BcCarousel initial index matches defaultIndex '
      '(VAL-M5-001)', (tester) async {
    await tester.pumpWidget(harness(
      BcCarousel(slides: slides, defaultIndex: 2),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Slide 3'), findsOneWidget,
        reason: 'Slide at defaultIndex=2 should be the active slide');
    expect(find.text('Slide 1'), findsNothing);
    expect(find.text('Slide 2'), findsNothing);
  });

  testWidgets(
      'BcCarousel next advances index and emits meta '
      '(VAL-M5-002)', (tester) async {
    int? emittedIndex;
    var metaCount = 0;

    await tester.pumpWidget(harness(
      BcCarousel(
        slides: slides,
        onSlideChange: (index, meta) {
          emittedIndex = index;
          metaCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_carousel_next')));
    await tester.pumpAndSettle();

    expect(emittedIndex, 1, reason: 'Next should advance from 0 to 1');
    expect(metaCount, 1, reason: 'onSlideChange should fire once');
    expect(find.text('Slide 2'), findsOneWidget,
        reason: 'Slide 2 should now be visible');
    expect(find.text('Slide 1'), findsNothing);
  });

  testWidgets(
      'BcCarousel prev decrements and wraps from 0 to last '
      '(VAL-M5-002)', (tester) async {
    int? emittedIndex;

    await tester.pumpWidget(harness(
      BcCarousel(
        slides: slides,
        onSlideChange: (index, meta) {
          emittedIndex = index;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_carousel_prev')));
    await tester.pumpAndSettle();

    expect(emittedIndex, 2,
        reason: 'Prev from index 0 should wrap to last slide (2)');
    expect(find.text('Slide 3'), findsOneWidget);
  });

  testWidgets(
      'BcCarousel next wraps from last to 0 '
      '(VAL-M5-002)', (tester) async {
    int? emittedIndex;

    await tester.pumpWidget(harness(
      BcCarousel(
        slides: slides,
        defaultIndex: 2,
        onSlideChange: (index, meta) {
          emittedIndex = index;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_carousel_next')));
    await tester.pumpAndSettle();

    expect(emittedIndex, 0,
        reason: 'Next from last slide should wrap to 0');
    expect(find.text('Slide 1'), findsOneWidget);
  });

  testWidgets(
      'BcCarousel autoplay advances on interval '
      '(VAL-M5-003)', (tester) async {
    int? emittedIndex;

    await tester.pumpWidget(harness(
      BcCarousel(
        slides: slides,
        autoplay: true,
        interval: const Duration(milliseconds: 500),
        onSlideChange: (index, meta) {
          emittedIndex = index;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(emittedIndex, 1, reason: 'Autoplay should advance to slide 1');
    expect(find.text('Slide 2'), findsOneWidget);
  });

  testWidgets(
      'BcCarousel autoplay disabled does not advance '
      '(VAL-M5-003)', (tester) async {
    var metaCount = 0;

    await tester.pumpWidget(harness(
      BcCarousel(
        slides: slides,
        autoplay: false,
        interval: const Duration(milliseconds: 500),
        onSlideChange: (index, meta) {
          metaCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(metaCount, 0, reason: 'No autoplay advancement when disabled');
    expect(find.text('Slide 1'), findsOneWidget);
  });

  testWidgets(
      'BcCarousel indicator dots reflect active and are tappable '
      '(VAL-M5-004)', (tester) async {
    int? emittedIndex;

    await tester.pumpWidget(harness(
      BcCarousel(
        slides: slides,
        onSlideChange: (index, meta) {
          emittedIndex = index;
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_carousel_dot_0')), findsOneWidget);
    expect(find.byKey(const Key('bc_carousel_dot_1')), findsOneWidget);
    expect(find.byKey(const Key('bc_carousel_dot_2')), findsOneWidget);

    final dot0 = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('bc_carousel_dot_0')),
        matching: find.byType(Container),
      ),
    );
    final activeDecoration = dot0.decoration as BoxDecoration;
    expect(activeDecoration.color, BcCarouselActiveDotColor.value);

    await tester.tap(find.byKey(const Key('bc_carousel_dot_2')));
    await tester.pumpAndSettle();

    expect(emittedIndex, 2, reason: 'Tapping dot 2 should set active to 2');
    expect(find.text('Slide 3'), findsOneWidget);
  });
}
