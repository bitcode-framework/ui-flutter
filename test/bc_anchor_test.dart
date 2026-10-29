import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_anchor.dart';

void main() {
  group('BcAnchor', () {
    Widget buildHarness({
      String? selected,
      BcChangeHandler<String>? onSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            width: 400,
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: SingleChildScrollView(
                    child: BcAnchor(
                      anchors: const [
                        BcAnchorLink(label: 'Section A', target: 'section-a'),
                        BcAnchorLink(label: 'Section B', target: 'section-b'),
                        BcAnchorLink(label: 'Missing', target: 'missing'),
                      ],
                      selected: selected,
                      onSelected: onSelected,
                    ),
                  ),
                ),
                const Expanded(
                  child: SingleChildScrollView(
                    key: Key('scroll-content'),
                    child: Column(
                      key: Key('anchor-body'),
                      children: [
                        SizedBox(
                          key: ValueKey<String>('section-a'),
                          height: 300,
                          child: Text('Section A Content'),
                        ),
                        SizedBox(
                          key: ValueKey<String>('section-b'),
                          height: 300,
                          child: Text('Section B Content'),
                        ),
                        SizedBox(
                          key: ValueKey<String>('tail'),
                          height: 200,
                          child: Text('Tail'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('click scrolls to target section (VAL-M3-025)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      final beforeScroll = tester.getCenter(find.byKey(const Key('section-b')));
      expect(beforeScroll.dy, greaterThan(150));

      await tester.tap(find.text('Section B'));
      await tester.pumpAndSettle();

      final afterScroll = tester.getCenter(find.byKey(const Key('section-b')));
      expect(afterScroll.dy, lessThan(beforeScroll.dy));
    });

    testWidgets('highlights active link on scroll (VAL-M3-026)',
        (tester) async {
      String? activeTarget;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: BcAnchor(
                      anchors: const [
                        BcAnchorLink(
                            label: 'Section A', target: 'section-a'),
                        BcAnchorLink(
                            label: 'Section B', target: 'section-b'),
                      ],
                      onActiveChange: (target, _) {
                        activeTarget = target;
                      },
                    ),
                  ),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            key: ValueKey<String>('section-a'),
                            height: 300,
                            child: Text('A'),
                          ),
                          SizedBox(
                            key: ValueKey<String>('section-b'),
                            height: 300,
                            child: Text('B'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView).last,
          const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(activeTarget, 'section-b');
    });

    testWidgets('emits selected anchor with meta (VAL-M3-027)',
        (tester) async {
      String? capturedTarget;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        buildHarness(
          onSelected: (target, meta) {
            capturedTarget = target;
            capturedMeta = meta;
          },
        ),
      );

      await tester.tap(find.text('Section A'));
      await tester.pumpAndSettle();

      expect(capturedTarget, 'section-a');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.reason, BcChangeReason.select);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('missing target is a no-op (VAL-M3-028)', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        buildHarness(
          onSelected: (_, __) => callCount++,
        ),
      );

      await tester.tap(find.text('Missing'));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
