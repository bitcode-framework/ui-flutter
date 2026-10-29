import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_wizard.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  group('BcWizard', () {
    final steps = <BcWizardStep>[
      const BcWizardStep(title: 'Account', description: 'Create account'),
      const BcWizardStep(title: 'Profile', description: 'Set up profile'),
      const BcWizardStep(title: 'Confirm', description: 'Review and finish'),
    ];

    Widget buildHarness({
      required List<BcWizardStep> stepList,
      int? step,
      int defaultStep = 0,
      bool open = true,
      bool Function(int)? canAdvance,
      void Function(int index, BcChangeMeta meta)? onStepChange,
      void Function(BcChangeMeta meta)? onFinish,
      void Function(BcChangeMeta meta)? onCancel,
      List<Widget> Function(int index)? stepContentBuilder,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('open-trigger'),
                onPressed: () {
                  BcWizard.show(
                    context: context,
                    steps: stepList,
                    step: step,
                    defaultStep: defaultStep,
                    canAdvance: canAdvance,
                    onStepChange: onStepChange,
                    onFinishLegacy: onFinish,
                    onCancel: onCancel,
                    stepContentBuilderLegacy: stepContentBuilder,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open-trigger')));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'stepper renders one entry per step with exactly one current marker '
        '(VAL-M4-005)', (tester) async {
      await tester.pumpWidget(buildHarness(
        stepList: steps,
        step: 1,
      ));
      await openDialog(tester);

      expect(find.text('Account'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Confirm'), findsWidgets);

      final markers = find.byKey(const Key('bc-wizard-marker-current'));
      expect(markers, findsNWidgets(1),
          reason: 'exactly one step should carry the current-step marker');
    });

    testWidgets(
        'advancing moves the current marker to the new step '
        '(VAL-M4-005)', (tester) async {
      int currentStep = 0;

      late StateSetter setStateHolder;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateHolder = setState;
            return buildHarness(
              stepList: steps,
              step: currentStep,
              onStepChange: (index, meta) {
                setStateHolder(() {
                  currentStep = index;
                });
              },
            );
          },
        ),
      );
      await openDialog(tester);

      expect(find.byKey(const Key('bc-wizard-next')), findsOneWidget);
      await tester.tap(find.byKey(const Key('bc-wizard-next')));
      await tester.pumpAndSettle();

      expect(currentStep, 1);
    });

    testWidgets(
        'canAdvance gate blocks Next and clamps programmatic advancement '
        '(VAL-M4-006)', (tester) async {
      int currentStep = 0;

      late StateSetter setStateHolder;
      late BcWizardController controller;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateHolder = setState;
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      key: const Key('open-trigger'),
                      onPressed: () {
                        controller = BcWizard.show(
                          context: context,
                          steps: steps,
                          step: currentStep,
                          canAdvance: (s) => false,
                          onStepChange: (index, meta) {
                            setStateHolder(() {
                              currentStep = index;
                            });
                          },
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
      await openDialog(tester);

      final nextButton = tester.widget<FilledButton>(
        find.byKey(const Key('bc-wizard-next')),
      );
      expect(nextButton.onPressed, isNull,
          reason: 'Next should be disabled when canAdvance returns false');

      controller.setStep(1, const BcChangeMeta(reason: BcChangeReason.programmatic, source: BcEventSource.programmatic));
      await tester.pumpAndSettle();

      expect(currentStep, 0,
          reason: 'programmatic advancement should be a no-op when gated');
    });

    testWidgets(
        'when canAdvance returns true, Next proceeds (VAL-M4-006)',
        (tester) async {
      int currentStep = 0;

      late StateSetter setStateHolder;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateHolder = setState;
            return buildHarness(
              stepList: steps,
              step: currentStep,
              canAdvance: (s) => true,
              onStepChange: (index, meta) {
                setStateHolder(() {
                  currentStep = index;
                });
              },
            );
          },
        ),
      );
      await openDialog(tester);

      final nextButton = tester.widget<FilledButton>(
        find.byKey(const Key('bc-wizard-next')),
      );
      expect(nextButton.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('bc-wizard-next')));
      await tester.pumpAndSettle();

      expect(currentStep, 1);
    });

    testWidgets(
        'setStep clamps to [0, steps.length - 1] without RangeError '
        '(VAL-M4-007)', (tester) async {
      int currentStep = 0;

      late StateSetter setStateHolder;
      late BcWizardController controller;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateHolder = setState;
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      key: const Key('open-trigger'),
                      onPressed: () {
                        controller = BcWizard.show(
                          context: context,
                          steps: steps,
                          step: currentStep,
                          canAdvance: (s) => true,
                          onStepChange: (index, meta) {
                            setStateHolder(() {
                              currentStep = index;
                            });
                          },
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
      await openDialog(tester);

      controller.setStep(-1, const BcChangeMeta(reason: BcChangeReason.programmatic, source: BcEventSource.programmatic));
      await tester.pumpAndSettle();

      expect(currentStep, 0, reason: 'setStep(-1) should clamp to 0');

      controller.setStep(10, const BcChangeMeta(reason: BcChangeReason.programmatic, source: BcEventSource.programmatic));
      await tester.pumpAndSettle();

      expect(currentStep, steps.length - 1,
          reason: 'setStep(steps.length) should clamp to last index');

      expect(tester.takeException(), isNull,
          reason: 'no RangeError should be thrown');
    });

    testWidgets(
        'step transitions emit onStepChange with new index and BcChangeMeta '
        '(VAL-M4-008)', (tester) async {
      int? capturedIndex;
      BcChangeMeta? capturedMeta;
      int callCount = 0;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        defaultStep: 0,
        onStepChange: (index, meta) {
          capturedIndex = index;
          capturedMeta = meta;
          callCount++;
        },
      ));
      await openDialog(tester);

      await tester.tap(find.byKey(const Key('bc-wizard-next')));
      await tester.pumpAndSettle();

      expect(callCount, greaterThanOrEqualTo(1));
      expect(capturedIndex, 1);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets(
        'Finish control enabled only on the last step (VAL-M4-008)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        stepList: steps,
        defaultStep: 0,
        canAdvance: (s) => true,
      ));
      await openDialog(tester);

      expect(find.byKey(const Key('bc-wizard-finish')), findsNothing,
          reason: 'Finish should not be visible on non-last step');

      await tester.tap(find.byKey(const Key('bc-wizard-next')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-wizard-finish')), findsNothing,
          reason: 'Finish should not be visible on second-to-last step');

      await tester.tap(find.byKey(const Key('bc-wizard-next')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-wizard-finish')), findsOneWidget,
          reason: 'Finish should be visible on last step');
      expect(find.byKey(const Key('bc-wizard-next')), findsNothing);
    });

    testWidgets(
        'cancel/close disposes step-local controllers (VAL-M4-008)',
        (tester) async {
      bool cancelled = false;
      BcChangeMeta? cancelMeta;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        defaultStep: 0,
        onCancel: (meta) {
          cancelled = true;
          cancelMeta = meta;
        },
      ));
      await openDialog(tester);

      await tester.tap(find.byKey(const Key('bc-wizard-cancel')));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
      expect(cancelMeta, isNotNull);
      expect(cancelMeta!.reason, BcChangeReason.cancel);
      expect(find.byKey(const Key('bc-wizard-stepper')), findsNothing,
          reason: 'wizard should be dismissed after cancel');
    });

    testWidgets(
        'finish on last step invokes onFinish (VAL-M4-008)',
        (tester) async {
      bool finished = false;
      BcChangeMeta? finishMeta;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        step: 2,
        onFinish: (meta) {
          finished = true;
          finishMeta = meta;
        },
      ));
      await openDialog(tester);

      await tester.tap(find.byKey(const Key('bc-wizard-finish')));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
      expect(finishMeta, isNotNull);
      expect(finishMeta!.reason, BcChangeReason.submit);
      expect(find.byKey(const Key('bc-wizard-stepper')), findsNothing);
    });
  });
}
