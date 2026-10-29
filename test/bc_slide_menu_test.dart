import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_slide_menu.dart';

void main() {
  group('BcSlideMenu', () {
    Widget buildHarness({
      bool? open,
      bool defaultOpen = false,
      List<BcSlideMenuItem>? items,
      BcChangeHandler<bool>? onOpenChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            width: 400,
            child: BcSlideMenu(
              open: open,
              defaultOpen: defaultOpen,
              items: items ??
                  const [
                    BcSlideMenuItem(key: 'home', label: 'Home'),
                    BcSlideMenuItem(key: 'settings', label: 'Settings'),
                    BcSlideMenuItem(key: 'about', label: 'About'),
                  ],
              onOpenChange: onOpenChange,
              child: const Text('Main Content'),
            ),
          ),
        ),
      );
    }

    testWidgets('open/close animates with scrim (VAL-M3-041)',
        (tester) async {
      await tester.pumpWidget(buildHarness(defaultOpen: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-slide-menu-drawer')), findsNothing);
      expect(find.byKey(const Key('bc-slide-menu-scrim')), findsNothing);

      late void Function(void Function()) setStateProxy;
      bool externalOpen = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateProxy = setState;
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 600,
                  width: 400,
                  child: BcSlideMenu(
                    open: externalOpen,
                    items: const [
                      BcSlideMenuItem(key: 'home', label: 'Home'),
                      BcSlideMenuItem(key: 'settings', label: 'Settings'),
                    ],
                    child: const Text('Main Content'),
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      setStateProxy(() {
        externalOpen = true;
      });
      await tester.pump();

      expect(find.byKey(const Key('bc-slide-menu-scrim')), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-slide-menu-drawer')), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      setStateProxy(() {
        externalOpen = false;
      });
      await tester.pump();

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-slide-menu-drawer')), findsNothing);
    });

    testWidgets('emits open state with meta (VAL-M3-042)', (tester) async {
      bool? capturedOpen;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(buildHarness(
        onOpenChange: (isOpen, meta) {
          capturedOpen = isOpen;
          capturedMeta = meta;
          callCount++;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-slide-menu-trigger')));
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedOpen, isTrue);
      expect(capturedMeta, isNotNull);
    });

    testWidgets('scrim tap closes and emits meta with scrim source (VAL-M3-043)',
        (tester) async {
      bool? capturedOpen;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(buildHarness(
        defaultOpen: true,
        onOpenChange: (isOpen, meta) {
          capturedOpen = isOpen;
          capturedMeta = meta;
          callCount++;
        },
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-slide-menu-scrim')), findsOneWidget);
      expect(find.byKey(const Key('bc-slide-menu-drawer')), findsOneWidget);

      await tester.tapAt(const Offset(350, 300));
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedOpen, isFalse);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
      expect(capturedMeta!.reason, BcChangeReason.overlayClick);
    });

    testWidgets('controlled open overrides internal state (VAL-M3-044)',
        (tester) async {
      bool? capturedOpen;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      late void Function(void Function()) setStateProxy;
      bool externalOpen = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateProxy = setState;
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 600,
                  width: 400,
                  child: BcSlideMenu(
                    open: externalOpen,
                    items: const [
                      BcSlideMenuItem(key: 'home', label: 'Home'),
                    ],
                    child: const Text('Main Content'),
                    onOpenChange: (isOpen, meta) {
                      capturedOpen = isOpen;
                      capturedMeta = meta;
                      callCount++;
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-slide-menu-drawer')), findsOneWidget);

      await tester.tapAt(const Offset(350, 300));
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedOpen, isFalse);
      expect(capturedMeta, isNotNull);

      expect(find.byKey(const Key('bc-slide-menu-drawer')), findsOneWidget);

      setStateProxy(() {
        externalOpen = false;
      });
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-slide-menu-drawer')), findsNothing);
    });
  });
}
