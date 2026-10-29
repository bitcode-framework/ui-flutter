import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_tour.dart';

void main() {
  group('BcTour', () {
    final steps = [
      const BcTourStep(title: 'Step 1', description: 'First step'),
      const BcTourStep(title: 'Step 2', description: 'Second step'),
      const BcTourStep(title: 'Step 3', description: 'Third step'),
    ];

    Widget buildHarness({
      bool open = true,
      List<BcTourStep>? stepList,
      int? step,
      int defaultStep = 0,
      String nextLabel = 'Next',
      String prevLabel = 'Back',
      String finishLabel = 'Finish',
      BcChangeHandler<int>? onStepChange,
      void Function(BcChangeMeta meta)? onFinish,
      void Function(BcChangeMeta meta)? onSkip,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcTour(
            open: open,
            steps: stepList ?? steps,
            step: step,
            defaultStep: defaultStep,
            nextLabel: nextLabel,
            prevLabel: prevLabel,
            finishLabel: finishLabel,
            onStepChange: onStepChange,
            onFinish: onFinish,
            onSkip: onSkip,
          ),
        ),
      );
    }

    testWidgets(
        'tour highlights the current step and renders overlay with cut-out '
        '(VAL-M4-022)', (tester) async {
      await tester.pumpWidget(buildHarness(
        stepList: steps,
        defaultStep: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-tour-overlay')), findsOneWidget);
      expect(find.byKey(const Key('bc-tour-cutout')), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('Second step'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets(
        'Next advances and Back reverses through steps; Next disabled on '
        'last, Back disabled on first (VAL-M4-023)', (tester) async {
      int? currentStep;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        onStepChange: (val, _) => currentStep = val,
      ));
      await tester.pumpAndSettle();

      final backButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('bc-tour-prev')),
      );
      expect(backButton.enabled, isFalse,
          reason: 'Back disabled on first step');

      await tester.tap(find.byKey(const Key('bc-tour-next')));
      await tester.pumpAndSettle();
      expect(currentStep, 1);
      expect(find.text('Step 2'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-tour-prev')));
      await tester.pumpAndSettle();
      expect(currentStep, 0);
      expect(find.text('Step 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-tour-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-tour-next')));
      await tester.pumpAndSettle();
      expect(currentStep, 2);
      expect(find.text('Step 3'), findsOneWidget);

      final nextButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('bc-tour-next')),
      );
      expect(nextButton.enabled, isFalse,
          reason: 'Next disabled on last step');
    });

    testWidgets(
        'step transitions emit onStepChange with new index and meta '
        '(VAL-M4-024)', (tester) async {
      int? capturedStep;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        onStepChange: (val, meta) {
          capturedStep = val;
          capturedMeta = meta;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-tour-next')));
      await tester.pumpAndSettle();

      expect(capturedStep, 1);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);

      await tester.tap(find.byKey(const Key('bc-tour-prev')));
      await tester.pumpAndSettle();

      expect(capturedStep, 0);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets(
        'Finish on last step disposes the overlay (VAL-M4-025)',
        (tester) async {
      BcChangeMeta? finishMeta;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        defaultStep: 2,
        onFinish: (meta) => finishMeta = meta,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Finish'), findsOneWidget);
      await tester.tap(find.byKey(const Key('bc-tour-finish')));
      await tester.pumpAndSettle();

      expect(finishMeta, isNotNull);
      expect(find.byKey(const Key('bc-tour-overlay')), findsNothing);
    });

    testWidgets(
        'skip/cancel disposes the overlay (VAL-M4-025)',
        (tester) async {
      BcChangeMeta? skipMeta;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        onSkip: (meta) => skipMeta = meta,
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-tour-overlay')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-tour-skip')));
      await tester.pumpAndSettle();

      expect(skipMeta, isNotNull);
      expect(find.byKey(const Key('bc-tour-overlay')), findsNothing);
    });

    testWidgets('controlled step does not self-mutate on Next tap',
        (tester) async {
      int? capturedStep;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        step: 0,
        onStepChange: (val, _) => capturedStep = val,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-tour-next')));
      await tester.pumpAndSettle();

      expect(capturedStep, 1);
      expect(find.text('Step 1'), findsOneWidget,
          reason: 'Controlled mode: display does not change until parent updates');
    });

    testWidgets('closed tour renders nothing', (tester) async {
      await tester.pumpWidget(buildHarness(open: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-tour-overlay')), findsNothing);
    });

    testWidgets('empty steps renders nothing', (tester) async {
      await tester.pumpWidget(buildHarness(stepList: []));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-tour-overlay')), findsNothing);
    });

    testWidgets('backdrop tap triggers skip', (tester) async {
      BcChangeMeta? skipMeta;

      await tester.pumpWidget(buildHarness(
        stepList: steps,
        onSkip: (meta) => skipMeta = meta,
      ));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(skipMeta, isNotNull);
      expect(find.byKey(const Key('bc-tour-overlay')), findsNothing);
    });
  });
}
