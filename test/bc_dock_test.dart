import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_dock.dart';

void main() {
  group('BcDock', () {
    testWidgets('toggles dock/detach mode and toggle reflects state (VAL-M3-033)',
        (tester) async {
      bool? capturedDocked;
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcDock(
              child: const Text('Panel Content'),
              onDockChange: (docked, _) {
                capturedDocked = docked;
                callCount++;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-dock-toggle')), findsOneWidget);
      expect(find.text('Panel Content'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-dock-toggle')));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedDocked, isTrue);

      await tester.tap(find.byKey(const Key('bc-dock-toggle')));
      await tester.pumpAndSettle();

      expect(callCount, 2);
      expect(capturedDocked, isFalse);
    });

    testWidgets('emits dock state with meta (VAL-M3-034)', (tester) async {
      bool? capturedDocked;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcDock(
              child: const Text('Panel'),
              onDockChange: (docked, meta) {
                capturedDocked = docked;
                capturedMeta = meta;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-dock-toggle')));
      await tester.pumpAndSettle();

      expect(capturedDocked, isTrue);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
      expect(capturedMeta!.reason, BcChangeReason.toggle);
    });

    testWidgets('controlled mode overrides internal state (VAL-M3-035)',
        (tester) async {
      bool? capturedDocked;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      late void Function(void Function()) setStateProxy;
      bool externalDocked = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateProxy = setState;
            return MaterialApp(
              home: Scaffold(
                body: BcDock(
                  docked: externalDocked,
                  child: const Text('Panel'),
                  onDockChange: (docked, meta) {
                    capturedDocked = docked;
                    capturedMeta = meta;
                    callCount++;
                  },
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dock'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-dock-toggle')));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(capturedDocked, isTrue);
      expect(capturedMeta, isNotNull);

      expect(find.text('Dock'), findsOneWidget);

      setStateProxy(() {
        externalDocked = true;
      });
      await tester.pumpAndSettle();

      expect(find.text('Detach'), findsOneWidget);
    });

    testWidgets('disabled toggle is non-interactive, content interactive (VAL-M3-036)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcDock(
              disabled: true,
              child: const Text('Panel Content'),
              onDockChange: (_, __) => callCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<IconButton>(
        find.byKey(const Key('bc-dock-toggle')),
      );
      expect(button.onPressed, isNull);

      await tester.tap(find.byKey(const Key('bc-dock-toggle')), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(callCount, 0);

      expect(find.text('Panel Content'), findsOneWidget);
    });
  });
}
