import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_field_duration.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

/// Widget tests for [BcFieldDuration] (ADR-011 Phase 5b.2).
///
/// Covers the 27 VAL-DUR assertions from the validation contract:
/// rendering of segments (hours/minutes/seconds), up/down stepper
/// increment/decrement by `step`, `maxHours` cap, `clearable` clear button,
/// disabled/readonly/required props, `onValueChange` with the correct
/// `BcChangeReason` (input/increment/decrement/clear/programmatic),
/// value-is-total-seconds int semantics, segment overflow roll-over,
/// keyboard ArrowUp/Down adjusting the focused segment, and the
/// label/hint/description/placeholder/size/name props.
void main() {
  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('BcFieldDuration rendering', () {
    testWidgets(
        'BcFieldDuration renders hours and minutes (VAL-DUR-001)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur'),
      ));
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets(
        'BcFieldDuration showSeconds renders third segment (VAL-DUR-002)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', showSeconds: true),
      ));
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets(
        'BcFieldDuration default hides seconds (VAL-DUR-003)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', showSeconds: false),
      ));
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets(
        'BcFieldDuration label renders (VAL-DUR-018)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', label: 'Duration'),
      ));
      expect(find.text('Duration'), findsOneWidget);
    });

    testWidgets(
        'BcFieldDuration hint renders as helper text (VAL-DUR-019)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', hint: 'Enter elapsed time'),
      ));
      expect(find.text('Enter elapsed time'), findsOneWidget);
    });

    testWidgets(
        'BcFieldDuration description renders (VAL-DUR-020)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', description: 'Time spent on task'),
      ));
      expect(find.text('Time spent on task'), findsOneWidget);
    });

    testWidgets(
        'BcFieldDuration required marks field (VAL-DUR-021)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', label: 'Duration', required: true),
      ));
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets(
        'BcFieldDuration placeholder renders when empty (VAL-DUR-023)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', placeholder: '00'),
      ));
      expect(find.text('00'), findsWidgets);
    });

    testWidgets(
        'BcFieldDuration name prop set on field (VAL-DUR-025)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur-field'),
      ));
      expect(find.byKey(const ValueKey<String>('bc-field-duration-dur-field')),
          findsOneWidget);
    });

    testWidgets(
        'BcFieldDuration size prop accepted (VAL-DUR-024)',
        (tester) async {
      for (final size in BcComponentSize.values) {
        await tester.pumpWidget(harness(
          BcFieldDuration(name: 'dur', size: size),
        ));
        expect(find.byType(BcFieldDuration), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('BcFieldDuration steppers', () {
    testWidgets(
        'BcFieldDuration up button increments by step (VAL-DUR-004)',
        (tester) async {
      int? capturedValue;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 0,
          step: 60,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
          },
        ),
      ));
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-up')));
      await tester.pump();
      expect(capturedValue, 60);
    });

    testWidgets(
        'BcFieldDuration down button decrements by step (VAL-DUR-005)',
        (tester) async {
      int? capturedValue;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 120,
          step: 60,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
          },
        ),
      ));
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-down')));
      await tester.pump();
      expect(capturedValue, 60);
    });

    testWidgets(
        'BcFieldDuration down clamps to zero (VAL-DUR-006)',
        (tester) async {
      int? capturedValue;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 30,
          step: 60,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
          },
        ),
      ));
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-down')));
      await tester.pump();
      expect(capturedValue, 0);
    });

    testWidgets(
        'BcFieldDuration maxHours caps value (VAL-DUR-007)',
        (tester) async {
      int? capturedValue;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 23 * 3600,
          maxHours: 23,
          step: 3600,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
          },
        ),
      ));
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-up')));
      await tester.pump();
      expect(capturedValue, 23 * 3600);
    });

    testWidgets(
        'BcFieldDuration up button fires increment reason (VAL-DUR-013)',
        (tester) async {
      BcChangeReason? capturedReason;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 0,
          step: 60,
          onValueChange: (v, m) {
            capturedReason = m.reason;
          },
        ),
      ));
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-up')));
      await tester.pump();
      expect(capturedReason, BcChangeReason.increment);
    });

    testWidgets(
        'BcFieldDuration down button fires decrement reason (VAL-DUR-014)',
        (tester) async {
      BcChangeReason? capturedReason;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 120,
          step: 60,
          onValueChange: (v, m) {
            capturedReason = m.reason;
          },
        ),
      ));
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-down')));
      await tester.pump();
      expect(capturedReason, BcChangeReason.decrement);
    });
  });

  group('BcFieldDuration clear', () {
    testWidgets(
        'BcFieldDuration clearable shows clear button (VAL-DUR-008)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', value: 60, clearable: true),
      ));
      expect(find.byKey(const ValueKey<String>('bc-field-duration-clear')),
          findsOneWidget);
    });

    testWidgets(
        'BcFieldDuration clear resets to zero with clear reason (VAL-DUR-009)',
        (tester) async {
      int? capturedValue;
      BcChangeReason? capturedReason;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 60,
          clearable: true,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
            capturedReason = m.reason;
          },
        ),
      ));
      await tester
          .tap(find.byKey(const ValueKey<String>('bc-field-duration-clear')));
      await tester.pump();
      expect(capturedValue, 0);
      expect(capturedReason, BcChangeReason.clear);
    });
  });

  group('BcFieldDuration disabled/readonly', () {
    testWidgets(
        'BcFieldDuration disabled prevents input (VAL-DUR-010)',
        (tester) async {
      bool changed = false;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 0,
          disabled: true,
          onValueChange: (v, m) {
            changed = true;
          },
        ),
      ));
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final tf in textFields) {
        expect(tf.enabled, isFalse);
      }
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-up')));
      await tester.pump();
      expect(changed, isFalse);
    });

    testWidgets(
        'BcFieldDuration readonly prevents input but displays value (VAL-DUR-011)',
        (tester) async {
      bool changed = false;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 3661,
          readonly: true,
          showSeconds: true,
          onValueChange: (v, m) {
            changed = true;
          },
        ),
      ));
      expect(find.text('1'), findsNWidgets(3));
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final tf in textFields) {
        expect(tf.readOnly, isTrue);
      }
      await tester.tap(find.byKey(const ValueKey<String>('bc-field-duration-up')));
      await tester.pump();
      expect(changed, isFalse);
    });
  });

  group('BcFieldDuration value semantics', () {
    testWidgets(
        'BcFieldDuration text input fires input reason (VAL-DUR-012)',
        (tester) async {
      int? capturedValue;
      BcChangeReason? capturedReason;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 0,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
            capturedReason = m.reason;
          },
        ),
      ));
      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-duration-hours')),
        '2',
      );
      await tester.pump();
      expect(capturedValue, 7200);
      expect(capturedReason, BcChangeReason.input);
    });

    testWidgets(
        'BcFieldDuration value is total seconds int (VAL-DUR-015)',
        (tester) async {
      int? capturedValue;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 5400,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
          },
        ),
      ));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-duration-hours')),
        '2',
      );
      await tester.pump();
      expect(capturedValue, 9000);
    });

    testWidgets(
        'BcFieldDuration controlled value updates segments (VAL-DUR-016)',
        (tester) async {
      int value = 3661;
      late StateSetter setStateRef;
      await tester.pumpWidget(harness(
        StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return BcFieldDuration(
              name: 'dur',
              value: value,
              showSeconds: true,
            );
          },
        ),
      ));
      expect(find.text('1'), findsNWidgets(3));
      setStateRef(() {
        value = 7322;
      });
      await tester.pump();
      expect(find.text('2'), findsNWidgets(3));
    });

    testWidgets(
        'BcFieldDuration defaultValue initializes state (VAL-DUR-017)',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcFieldDuration(name: 'dur', defaultValue: 3600),
      ));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets(
        'BcFieldDuration minute overflow rolls to hours (VAL-DUR-022)',
        (tester) async {
      int? capturedValue;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 0,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
          },
        ),
      ));
      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-duration-minutes')),
        '60',
      );
      await tester.pump();
      expect(capturedValue, 3600);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('BcFieldDuration programmatic changes', () {
    testWidgets(
        'BcFieldDuration external value change is programmatic (VAL-DUR-026)',
        (tester) async {
      int value = 0;
      int? capturedValue;
      BcChangeReason? capturedReason;
      late StateSetter setStateRef;
      await tester.pumpWidget(harness(
        StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return BcFieldDuration(
              name: 'dur',
              value: value,
              onValueChange: (v, m) {
                capturedValue = v.toInt();
                capturedReason = m.reason;
              },
            );
          },
        ),
      ));
      setStateRef(() {
        value = 3600;
      });
      await tester.pump();
      expect(capturedValue, 3600);
      expect(capturedReason, BcChangeReason.programmatic);
    });
  });

  group('BcFieldDuration a11y', () {
    testWidgets(
        'BcFieldDuration arrow keys adjust focused segment (VAL-DUR-027)',
        (tester) async {
      int? capturedValue;
      await tester.pumpWidget(harness(
        BcFieldDuration(
          name: 'dur',
          value: 0,
          onValueChange: (v, m) {
            capturedValue = v.toInt();
          },
        ),
      ));
      final minutesField = find
          .byKey(const ValueKey<String>('bc-field-duration-minutes'));
      await tester.tap(minutesField);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(capturedValue, 60);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(capturedValue, 0);
    });
  });
}
