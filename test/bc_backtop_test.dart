import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_backtop.dart';

void main() {
  group('BcBackTop', () {
    Widget buildHarness({
      double visibilityHeight = 200,
      bool disabled = false,
      ScrollController? controller,
      void Function(BcChangeMeta meta)? onClick,
    }) {
      final scrollController = controller ?? ScrollController();
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            width: 400,
            child: Stack(
              children: [
                SingleChildScrollView(
                  key: const Key('backtop-scroll'),
                  controller: scrollController,
                  child: const Column(
                    children: [
                      SizedBox(height: 300, child: Text('spacer')),
                      SizedBox(height: 800, child: Text('content')),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: BcBackTop(
                    visibilityHeight: visibilityHeight,
                    disabled: disabled,
                    scrollController: scrollController,
                    onClick: onClick,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('hidden below scroll threshold, visible above (VAL-M3-029)',
        (tester) async {
      await tester.pumpWidget(buildHarness(visibilityHeight: 200));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-backtop-button')), findsNothing);

      await tester.drag(
        find.byKey(const Key('backtop-scroll')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-backtop-button')), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('backtop-scroll')),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-backtop-button')), findsNothing);
    });

    testWidgets('click scrolls to top (VAL-M3-030)', (tester) async {
      const scrollKey = Key('backtop-scroll');
      await tester.pumpWidget(buildHarness(visibilityHeight: 100));
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(scrollKey), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-backtop-button')), findsOneWidget);

      final scrollable = tester.widget<Scrollable>(find.byType(Scrollable).first);
      expect(scrollable.controller!.position.pixels, greaterThan(100));

      await tester.tap(find.byKey(const Key('bc-backtop-button')));
      await tester.pumpAndSettle();

      expect(scrollable.controller!.position.pixels, 0);
      expect(find.byKey(const Key('bc-backtop-button')), findsNothing);
    });

    testWidgets('emits click meta (VAL-M3-031)', (tester) async {
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(buildHarness(
        visibilityHeight: 100,
        onClick: (meta) => capturedMeta = meta,
      ));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('backtop-scroll')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-backtop-button')));
      await tester.pumpAndSettle();

      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets('respects disabled state (VAL-M3-032)', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(buildHarness(
        visibilityHeight: 100,
        disabled: true,
        onClick: (_) => callCount++,
      ));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('backtop-scroll')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-backtop-button')), findsOneWidget);

      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('bc-backtop-button')),
      );
      expect(button.onPressed, isNull);

      await tester.tap(find.byKey(const Key('bc-backtop-button')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });
  });
}
