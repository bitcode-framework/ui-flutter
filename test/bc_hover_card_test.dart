import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_hover_card.dart';

void main() {
  group('BcHoverCard', () {
    Widget buildHarness({
      bool? open,
      bool defaultOpen = false,
      bool disabled = false,
      BcHoverCardPlacement placement = BcHoverCardPlacement.bottom,
      Duration openDelay = const Duration(milliseconds: 50),
      Duration closeDelay = const Duration(milliseconds: 50),
      BcChangeHandler<bool>? onOpenChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcHoverCard(
              open: open,
              defaultOpen: defaultOpen,
              disabled: disabled,
              placement: placement,
              openDelay: openDelay,
              closeDelay: closeDelay,
              onOpenChange: onOpenChange,
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Preview Title', key: Key('preview-title')),
                  Text('Preview Body', key: Key('preview-body')),
                ],
              ),
              child: Container(
                key: const Key('hover-trigger'),
                width: 100,
                height: 40,
                color: Colors.blue,
                child: const Text('Hover Me'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
        'card appears on pointer enter and disappears on pointer exit '
        '(VAL-M4-009)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-hover-card-content')), findsNothing);

      final gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(0, 0));
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byKey(const Key('hover-trigger'))));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('bc-hover-card-content')), findsOneWidget);

      await gesture.moveTo(const Offset(0, 0));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('bc-hover-card-content')), findsNothing);

      await gesture.removePointer();
    });

    testWidgets(
        'hover card renders preview content and stays open while pointer '
        'is over the card (VAL-M4-010)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      final gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(0, 0));
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byKey(const Key('hover-trigger'))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('preview-title')), findsOneWidget);
      expect(find.byKey(const Key('preview-body')), findsOneWidget);
      expect(find.byKey(const Key('bc-hover-card-content')), findsOneWidget);

      await gesture.moveTo(
        tester.getCenter(find.byKey(const Key('bc-hover-card-content'))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('bc-hover-card-content')), findsOneWidget);

      await gesture.moveTo(const Offset(0, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('bc-hover-card-content')), findsNothing);

      await gesture.removePointer();
    });

    testWidgets(
        'disabled trigger never reveals the card (VAL-M4-011)',
        (tester) async {
      await tester.pumpWidget(buildHarness(disabled: true));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-hover-card-content')), findsNothing);

      final gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(0, 0));
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byKey(const Key('hover-trigger'))));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('bc-hover-card-content')), findsNothing);

      await gesture.removePointer();
    });

    testWidgets('emits onOpenChange with BcChangeMeta on transitions',
        (tester) async {
      bool? capturedOpen;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(buildHarness(
        onOpenChange: (value, meta) {
          capturedOpen = value;
          capturedMeta = meta;
          callCount++;
        },
      ));
      await tester.pumpAndSettle();

      final gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(0, 0));
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byKey(const Key('hover-trigger'))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedOpen, isTrue);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);

      await gesture.moveTo(const Offset(0, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(callCount, greaterThanOrEqualTo(2));
      expect(capturedOpen, isFalse);

      await gesture.removePointer();
    });
  });
}
