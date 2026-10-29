import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_disclosure.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  group('BcDisclosure', () {
    testWidgets('BcDisclosure renders title (VAL-DISC-001)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(title: 'Details', child: Text('Body')),
          ),
        ),
      );

      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('BcDisclosure tap opens content (VAL-DISC-002)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(title: 'T', child: Text('Secret content')),
          ),
        ),
      );

      expect(find.text('Secret content'), findsNothing);

      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(find.text('Secret content'), findsOneWidget);
    });

    testWidgets('BcDisclosure tap closes content (VAL-DISC-003)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              title: 'T',
              defaultOpen: true,
              child: Text('Secret content'),
            ),
          ),
        ),
      );

      expect(find.text('Secret content'), findsOneWidget);

      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(find.text('Secret content'), findsNothing);
    });

    testWidgets('BcDisclosure controlled open prop drives state (VAL-DISC-004)',
        (tester) async {
      bool open = false;

      late StateSetter setStateRef;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateRef = setState;
                return BcDisclosure(
                  title: 'T',
                  open: open,
                  child: const Text('Body'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Body'), findsNothing);

      setStateRef(() {
        open = true;
      });
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);

      // Tapping should not change visibility when controlled
      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('BcDisclosure defaultOpen starts expanded (VAL-DISC-005)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              title: 'T',
              defaultOpen: true,
              child: Text('Body'),
            ),
          ),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('BcDisclosure defaults to collapsed (VAL-DISC-006)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(title: 'T', child: Text('Body')),
          ),
        ),
      );

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('BcDisclosure disabled blocks toggle (VAL-DISC-007)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              title: 'T',
              disabled: true,
              child: Text('Body'),
            ),
          ),
        ),
      );

      expect(find.text('Body'), findsNothing);

      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('BcDisclosure onOpenChange fires with toggle reason (VAL-DISC-008)',
        (tester) async {
      bool? capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              title: 'T',
              child: const Text('Body'),
              onOpenChange: (v, m) {
                capturedValue = v;
                capturedReason = m.reason;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(capturedValue, isTrue);
      expect(capturedReason, BcChangeReason.toggle);

      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(capturedValue, isFalse);
      expect(capturedReason, BcChangeReason.toggle);
    });

    testWidgets('BcDisclosure onChange fires with open boolean (VAL-DISC-009)',
        (tester) async {
      bool? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              title: 'T',
              child: const Text('Body'),
              onChange: (open) {
                captured = open;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(captured, isTrue);
    });

    testWidgets('BcDisclosure renders children when open (VAL-DISC-010)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              title: 'T',
              defaultOpen: true,
              child: Text('Inner body'),
            ),
          ),
        ),
      );

      expect(find.text('Inner body'), findsOneWidget);
    });

    testWidgets('BcDisclosure keyboard Enter/Space toggles (VAL-DISC-011)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcDisclosure(title: 'T', child: Text('Body')),
          ),
        ),
      );

      expect(find.text('Body'), findsNothing);

      // Focus the trigger and use Enter to open
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsOneWidget);

      // Use Space to close
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('BcDisclosure trigger exposes expanded semantics (VAL-DISC-012)',
        (tester) async {
      final triggerKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              key: triggerKey,
              title: 'T',
              child: const Text('Body'),
            ),
          ),
        ),
      );

      // Trigger should expose semantics with expanded flag
      // Find the Semantics node for the trigger (the heading/title)
      final semantics = tester.getSemantics(find.text('T'));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(semantics.hasFlag(SemanticsFlag.isExpanded), isFalse);

      // Open the disclosure
      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      final semanticsAfter = tester.getSemantics(find.text('T'));
      expect(semanticsAfter.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(semanticsAfter.hasFlag(SemanticsFlag.isExpanded), isTrue);
    });

    testWidgets('BcDisclosure rapid taps stay consistent (VAL-DISC-013)',
        (tester) async {
      int callCount = 0;
      bool? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcDisclosure(
              title: 'T',
              child: const Text('Body'),
              onOpenChange: (v, m) {
                callCount++;
                lastValue = v;
              },
            ),
          ),
        ),
      );

      // Tap 1: open
      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      // Tap 2: close
      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      // Tap 3: open
      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();

      expect(callCount, 3);
      expect(lastValue, isTrue);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets(
        'BcDisclosure external open change is programmatic (VAL-DISC-014)',
        (tester) async {
      bool open = false;
      bool? capturedValue;
      BcChangeReason? capturedReason;

      late StateSetter setStateRef;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateRef = setState;
                return BcDisclosure(
                  title: 'T',
                  open: open,
                  child: const Text('Body'),
                  onOpenChange: (v, m) {
                    capturedValue = v;
                    capturedReason = m.reason;
                  },
                );
              },
            ),
          ),
        ),
      );

      setStateRef(() {
        open = true;
      });
      await tester.pumpAndSettle();

      expect(capturedValue, isTrue);
      expect(capturedReason, BcChangeReason.programmatic);
    });
  });
}
