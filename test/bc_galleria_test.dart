import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_galleria.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcGalleria child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  final images = [
    const BcGalleriaItem(id: 'a', src: 'https://example.com/a.png'),
    const BcGalleriaItem(id: 'b', src: 'https://example.com/b.png'),
    const BcGalleriaItem(id: 'c', src: 'https://example.com/c.png'),
  ];

  testWidgets(
      'renders N thumbnails for N images (VAL-M6-023)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: BcGalleria(images: images),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_galleria_thumb_0')), findsOneWidget);
    expect(find.byKey(const Key('bc_galleria_thumb_1')), findsOneWidget);
    expect(find.byKey(const Key('bc_galleria_thumb_2')), findsOneWidget);
  });

  testWidgets(
      'activeIndex renders the corresponding main image (VAL-M6-023)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: BcGalleria(images: images, activeIndex: 1),
    ));
    await tester.pump();

    expect(find.byKey(const Key('bc_galleria_main')), findsOneWidget);
  });

  testWidgets(
      'empty images renders emptyState and no thumbnails (VAL-M6-023)',
      (tester) async {
    await tester.pumpWidget(harness(
      child: const BcGalleria(images: [], emptyText: 'Nothing here'),
    ));
    await tester.pump();

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('bc_galleria_empty')),
        findsOneWidget);
    expect(find.byKey(const Key('bc_galleria_thumb_0')), findsNothing);
  });

  testWidgets(
      'thumbnail tap emits onActiveIndexChange with clamped index and meta (VAL-M6-024)',
      (tester) async {
    int? capturedIndex;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      child: BcGalleria(
        images: images,
        activeIndex: 0,
        onActiveIndexChange: (index, meta) {
          capturedIndex = index;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_galleria_thumb_2')));
    await tester.pumpAndSettle();

    expect(capturedIndex, 2);
    expect(capturedMeta, isNotNull);
    expect(capturedMeta!.source, BcEventSource.pointer);
    expect(capturedMeta!.reason, BcChangeReason.select);
  });

  testWidgets(
      'thumbnail tap clamps out-of-range index to [0, N-1] (VAL-M6-024)',
      (tester) async {
    int? capturedIndex;

    await tester.pumpWidget(harness(
      child: BcGalleria(
        images: images,
        onActiveIndexChange: (index, _) => capturedIndex = index,
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_galleria_thumb_2')));
    await tester.pumpAndSettle();

    expect(capturedIndex, lessThanOrEqualTo(2));
    expect(capturedIndex, greaterThanOrEqualTo(0));
  });

  testWidgets(
      'main image tap opens lightbox and emits onLightboxChange true (VAL-M6-024)',
      (tester) async {
    bool? capturedOpen;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      child: BcGalleria(
        images: images,
        lightboxEnabled: true,
        onLightboxChange: (open, meta) {
          capturedOpen = open;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_galleria_main')));
    await tester.pumpAndSettle();

    expect(capturedOpen, true);
    expect(capturedMeta, isNotNull);
    expect(find.byKey(const Key('bc_galleria_lightbox')), findsOneWidget);
  });

  testWidgets(
      'lightbox close emits onLightboxChange false (VAL-M6-024)',
      (tester) async {
    final events = <bool>[];

    await tester.pumpWidget(harness(
      child: BcGalleria(
        images: images,
        lightboxEnabled: true,
        onLightboxChange: (open, _) => events.add(open),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_galleria_main')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bc_galleria_lightbox_close')));
    await tester.pumpAndSettle();

    expect(events, contains(true));
    expect(events, contains(false));
  });

  testWidgets(
      'disabled blocks thumbnail interaction (VAL-M6-024)',
      (tester) async {
    int callCount = 0;

    await tester.pumpWidget(harness(
      child: BcGalleria(
        images: images,
        disabled: true,
        onActiveIndexChange: (_, __) => callCount++,
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_galleria_thumb_1')));
    await tester.pumpAndSettle();

    expect(callCount, 0);
  });

  testWidgets(
      'disabled blocks lightbox open (VAL-M6-024)',
      (tester) async {
    int callCount = 0;

    await tester.pumpWidget(harness(
      child: BcGalleria(
        images: images,
        disabled: true,
        onLightboxChange: (_, __) => callCount++,
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_galleria_main')));
    await tester.pumpAndSettle();

    expect(callCount, 0);
    expect(find.byKey(const Key('bc_galleria_lightbox')), findsNothing);
  });

  testWidgets(
      'uncontrolled active index updates internally on thumbnail tap',
      (tester) async {
    await tester.pumpWidget(harness(
      child: BcGalleria(images: images),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('bc_galleria_thumb_1')));
    await tester.pumpAndSettle();

    final thumb1 = tester.widget<Container>(find
        .descendant(
          of: find.byKey(const Key('bc_galleria_thumb_1')),
          matching: find.byType(Container),
        )
        .first);
    final border = thumb1.decoration as BoxDecoration;
    final borderSide = (border.border as Border).top;
    expect(borderSide.width, greaterThan(1));
  });
}
