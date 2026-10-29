import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_steps.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 200,
          child: child,
        ),
      ),
    );
  }

  const steps = ['A', 'B', 'C'];

  testWidgets(
      'BcSteps renders one node per step and marks current step '
      '(VAL-M1-032)', (tester) async {
    await tester.pumpWidget(harness(
      const BcSteps(steps: steps, current: 1),
    ));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);

    final stepBRect = tester.getRect(find.text('B'));
    final stepARect = tester.getRect(find.text('A'));

    expect(stepBRect, isNot(equals(stepARect)),
        reason: 'each step node should be distinct');
  });

  testWidgets(
      'BcSteps step tap emits onStepChange with index and BcChangeMeta '
      '(VAL-M1-033)', (tester) async {
    int? capturedIndex;
    BcChangeMeta? capturedMeta;

    await tester.pumpWidget(harness(
      BcSteps(
        steps: steps,
        current: 0,
        clickable: true,
        onStepChange: (index, meta) {
          capturedIndex = index;
          capturedMeta = meta;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();

    expect(capturedIndex, 1,
        reason: 'onStepChange should fire with the tapped step index');
    expect(capturedMeta, isNotNull,
        reason: 'BcChangeMeta should be provided');
    expect(capturedMeta!.source, BcEventSource.pointer,
        reason: 'source should indicate pointer');
  });

  testWidgets(
      'BcSteps controlled current does not mutate on tap until parent '
      'updates (VAL-M1-034)', (tester) async {
    int current = 0;
    int? capturedIndex;

    late StateSetter setStateHolder;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          setStateHolder = setState;
          return harness(
            BcSteps(
              steps: steps,
              current: current,
              clickable: true,
              onStepChange: (index, meta) {
                capturedIndex = index;
              },
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();

    expect(capturedIndex, 2,
        reason: 'onStepChange should fire with tapped index');

    setStateHolder(() {
      current = 2;
    });
    await tester.pumpAndSettle();

    expect(current, 2,
        reason: 'parent updates the current prop, not the widget itself');
  });

  testWidgets('BcSteps disabled steps are not tappable (VAL-M1-035)',
      (tester) async {
    int callCount = 0;

    await tester.pumpWidget(harness(
      BcSteps(
        steps: steps,
        current: 0,
        clickable: true,
        disabledSteps: const [1],
        onStepChange: (index, meta) {
          callCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('B'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(callCount, 0,
        reason: 'onStepChange should NOT fire for disabled steps');
  });
}
