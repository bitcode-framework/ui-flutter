import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_backdrop.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            children: [
              const Text('content beneath'),
              child,
            ],
          ),
        ),
      ),
    );
  }

  testWidgets(
      'BcBackdrop tap-to-dismiss fires onDismiss with BcChangeMeta '
      '(VAL-M1-020)', (tester) async {
    BcChangeMeta? capturedMeta;
    int dismissCount = 0;

    await tester.pumpWidget(harness(
      BcBackdrop(
        visible: true,
        dismissible: true,
        onDismiss: (meta) {
          capturedMeta = meta;
          dismissCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(BcBackdrop), findsOneWidget);

    final scrimFinder = find.descendant(
      of: find.byType(BcBackdrop),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(scrimFinder);
    await tester.pumpAndSettle();

    expect(dismissCount, 1, reason: 'onDismiss should fire exactly once per tap');
    expect(capturedMeta, isNotNull, reason: 'BcChangeMeta should be provided');
    expect(capturedMeta!.source, BcEventSource.pointer,
        reason: 'source should indicate pointer tap');
  });

  testWidgets('BcBackdrop opacity controls dim level (VAL-M1-021)',
      (tester) async {
    await tester.pumpWidget(harness(
      const BcBackdrop(
        visible: true,
        opacity: 0.5,
        dismissible: false,
      ),
    ));
    await tester.pumpAndSettle();

    final opacity1 =
        tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity1.opacity, closeTo(0.5, 0.01),
        reason: 'scrim alpha should match opacity 0.5');

    await tester.pumpWidget(harness(
      const BcBackdrop(
        visible: true,
        opacity: 0.8,
        dismissible: false,
      ),
    ));
    await tester.pumpAndSettle();

    final opacity2 =
        tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity2.opacity, closeTo(0.8, 0.01),
        reason: 'scrim alpha should match opacity 0.8 (darker)');
    expect(opacity2.opacity, greaterThan(opacity1.opacity),
        reason: 'higher opacity should produce a darker scrim');
  });

  testWidgets(
      'BcBackdrop controlled visibility does not self-dismiss when '
      'dismissible is false (VAL-M1-022)', (tester) async {
    int dismissCount = 0;

    await tester.pumpWidget(harness(
      BcBackdrop(
        visible: true,
        dismissible: false,
        onDismiss: (meta) {
          dismissCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    final scrimFinder = find.descendant(
      of: find.byType(BcBackdrop),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(scrimFinder);
    await tester.pumpAndSettle();

    expect(dismissCount, 0,
        reason: 'onDismiss should NOT fire when dismissible is false');
    expect(find.byType(BcBackdrop), findsOneWidget,
        reason: 'backdrop should remain visible');
  });

  testWidgets('BcBackdrop controlled vs uncontrolled visibility (VAL-M1-023)',
      (tester) async {
    bool controlledVisible = true;
    bool? uncontrolledVisible;
    BcChangeMeta? uncontrolledMeta;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              children: [
                const Text('content'),
                BcBackdrop(
                  visible: controlledVisible,
                  dismissible: true,
                  onVisibleChange: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BcBackdrop), findsOneWidget,
        reason: 'backdrop should be visible when controlled visible=true');

    controlledVisible = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              children: [
                const Text('content'),
                BcBackdrop(
                  visible: controlledVisible,
                  dismissible: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Opacity), findsNothing,
        reason: 'scrim should not render when controlled visible=false');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              children: [
                const Text('content'),
                BcBackdrop(
                  defaultVisible: true,
                  dismissible: true,
                  onVisibleChange: (value, meta) {
                    uncontrolledVisible = value;
                    uncontrolledMeta = meta;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BcBackdrop), findsOneWidget,
        reason: 'uncontrolled backdrop should be visible via defaultVisible');

    final scrimFinder = find.descendant(
      of: find.byType(BcBackdrop),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(scrimFinder);
    await tester.pumpAndSettle();

    expect(uncontrolledVisible, false,
        reason: 'uncontrolled tap should emit visible=false');
    expect(uncontrolledMeta, isNotNull,
        reason: 'onVisibleChange should carry BcChangeMeta');
    expect(uncontrolledMeta!.source, BcEventSource.pointer);
  });
}
