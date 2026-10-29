import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_lightbox.dart';

void main() {
  group('BcLightbox', () {
    Widget buildHarness({
      bool? open,
      bool defaultOpen = false,
      List<BcLightboxItem> items = const [],
      int? index,
      int defaultIndex = 0,
      bool closable = true,
      void Function(bool open, BcChangeMeta meta)? onOpenChange,
      void Function(int index, BcChangeMeta meta)? onIndexChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: BcLightbox(
              open: open,
              defaultOpen: defaultOpen,
              items: items,
              index: index,
              defaultIndex: defaultIndex,
              closable: closable,
              onOpenChange: onOpenChange,
              onIndexChange: onIndexChange,
            ),
          ),
        ),
      );
    }

    const items = [
      BcLightboxItem.image('https://example.com/a.png', alt: 'A', caption: 'Cap A'),
      BcLightboxItem.image('https://example.com/b.png', alt: 'B'),
      BcLightboxItem.video('https://example.com/c.mp4'),
    ];

    testWidgets('defaultOpen=true renders the root + PageView (VAL-C-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness(defaultOpen: true, items: items));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-lightbox-root')), findsOneWidget);
      expect(find.byKey(const Key('bc-lightbox-pageview')), findsOneWidget);
    });

    testWidgets('open=false renders nothing (VAL-C-002)', (tester) async {
      await tester.pumpWidget(buildHarness(open: false, items: items));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-lightbox-root')), findsNothing);
    });

    testWidgets('close button fires onOpenChange false + pointer '
        '(VAL-C-003)', (tester) async {
      bool? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        open: true,
        items: items,
        onOpenChange: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-lightbox-close')));
      await tester.pumpAndSettle();
      expect(captured, isFalse);
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('closable=false hides the close button (VAL-C-004)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        closable: false,
        items: items,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-lightbox-close')), findsNothing);
    });

    testWidgets('prev button fires onIndexChange + wraps (VAL-C-005)',
        (tester) async {
      int? captured;
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        open: true,
        items: items,
        index: 0,
        onIndexChange: (v, m) {
          captured = v;
          meta = m;
        },
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-lightbox-prev')));
      await tester.pumpAndSettle();
      // wraps from 0 to last index (2)
      expect(captured, items.length - 1);
      expect(meta, isNotNull);
    });

    testWidgets('next button fires onIndexChange + wraps (VAL-C-006)',
        (tester) async {
      int? captured;
      await tester.pumpWidget(buildHarness(
        open: true,
        items: items,
        index: items.length - 1,
        onIndexChange: (v, _) => captured = v,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-lightbox-next')));
      await tester.pumpAndSettle();
      // wraps from last to 0
      expect(captured, 0);
    });

    testWidgets('video item uses default placeholder (VAL-C-007)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        open: true,
        items: const [BcLightboxItem.video('https://example.com/x.mp4')],
        index: 0,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-lightbox-video-placeholder')), findsOneWidget);
    });

    testWidgets('renders dialog semantics label (VAL-C-008)', (tester) async {
      await tester.pumpWidget(buildHarness(defaultOpen: true, items: items));
      await tester.pumpAndSettle();
      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'image gallery',
      );
      expect(semantics, findsOneWidget);
    });
  });
}
