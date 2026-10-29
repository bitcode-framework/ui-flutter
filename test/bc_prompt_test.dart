import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_prompt.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  group('BcPrompt', () {
    Widget buildHarness({
      String? title = 'Enter your name',
      String? description,
      String? defaultValue,
      String? placeholder,
      String? controlledValue,
      String confirmLabel = 'OK',
      String cancelLabel = 'Cancel',
      bool barrierDismissible = true,
      bool open = true,
      String? Function(String?)? validator,
      BcChangeHandler<String>? onValueChange,
      BcChangeHandler<String>? onConfirm,
      BcChangeHandler<void>? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('open-trigger'),
                onPressed: () {
                  BcPrompt.show(
                    context: context,
                    title: title,
                    description: description,
                    defaultValue: defaultValue,
                    placeholder: placeholder,
                    value: controlledValue,
                    confirmLabel: confirmLabel,
                    cancelLabel: cancelLabel,
                    barrierDismissible: barrierDismissible,
                    validator: validator,
                    onValueChange: onValueChange,
                    onConfirm: onConfirm,
                    onCancel: onCancel,
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
        'renders title, input field, and OK/cancel actions as modal overlay '
        '(VAL-M4-001)', (tester) async {
      await tester.pumpWidget(buildHarness(
        title: 'Enter your name',
        defaultValue: 'Alice',
        placeholder: 'Type here',
      ));
      await openDialog(tester);

      expect(find.text('Enter your name'), findsWidgets);
      expect(find.byKey(const Key('bc-prompt-input')), findsOneWidget);
      expect(find.text('Alice'), findsWidgets);
      expect(find.byKey(const Key('bc-prompt-confirm')), findsOneWidget);
      expect(find.byKey(const Key('bc-prompt-cancel')), findsOneWidget);

      expect(find.byType(ElevatedButton), findsWidgets,
          reason: 'the underlying button should still be in the tree behind the barrier');
    });

    testWidgets(
        'barrier non-dismissable when barrierDismissible is false '
        '(VAL-M4-001)', (tester) async {
      bool cancelled = false;

      await tester.pumpWidget(buildHarness(
        barrierDismissible: false,
        onCancel: (_, __) => cancelled = true,
      ));
      await openDialog(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-prompt-input')), findsOneWidget,
          reason: 'dialog should remain open when barrier is not dismissible');
      expect(cancelled, isFalse,
          reason: 'cancel should not fire from barrier tap');
    });

    testWidgets(
        'confirming with OK emits entered value and BcChangeMeta, then dismisses '
        '(VAL-M4-002)', (tester) async {
      String? confirmedValue;
      BcChangeMeta? confirmMeta;

      await tester.pumpWidget(buildHarness(
        onConfirm: (value, meta) {
          confirmedValue = value;
          confirmMeta = meta;
        },
      ));
      await openDialog(tester);

      await tester.enterText(
        find.byKey(const Key('bc-prompt-input')),
        'Bob',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('bc-prompt-confirm')));
      await tester.pumpAndSettle();

      expect(confirmedValue, 'Bob',
          reason: 'onConfirm should carry the exact entered value');
      expect(confirmMeta, isNotNull);
      expect(confirmMeta!.reason, BcChangeReason.confirm);
      expect(confirmMeta!.source, BcEventSource.pointer);

      expect(find.byKey(const Key('bc-prompt-input')), findsNothing,
          reason: 'dialog should dismiss after confirm');
    });

    testWidgets(
        'cancelling emits cancelled outcome with BcChangeMeta and does not '
        'propagate input (VAL-M4-003)', (tester) async {
      String? confirmedValue;
      bool confirmedCalled = false;
      bool cancelledCalled = false;
      BcChangeMeta? cancelMeta;

      await tester.pumpWidget(buildHarness(
        onConfirm: (value, meta) {
          confirmedValue = value;
          confirmedCalled = true;
        },
        onCancel: (_, meta) {
          cancelledCalled = true;
          cancelMeta = meta;
        },
      ));
      await openDialog(tester);

      await tester.enterText(
        find.byKey(const Key('bc-prompt-input')),
        'SecretText',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('bc-prompt-cancel')));
      await tester.pumpAndSettle();

      expect(cancelledCalled, isTrue,
          reason: 'cancel callback should fire');
      expect(confirmedCalled, isFalse,
          reason: 'confirm should NOT fire on cancel');
      expect(confirmedValue, isNull,
          reason: 'entered text should NOT be emitted as a value');
      expect(cancelMeta, isNotNull);
      expect(cancelMeta!.reason, BcChangeReason.cancel);

      expect(find.byKey(const Key('bc-prompt-input')), findsNothing,
          reason: 'dialog should dismiss after cancel');
    });

    testWidgets(
        'barrier dismiss emits cancel meta without emitting input value '
        '(VAL-M4-003)', (tester) async {
      String? confirmedValue;
      bool confirmedCalled = false;
      bool cancelledCalled = false;
      BcChangeMeta? cancelMeta;

      await tester.pumpWidget(buildHarness(
        barrierDismissible: true,
        onConfirm: (value, meta) {
          confirmedValue = value;
          confirmedCalled = true;
        },
        onCancel: (_, meta) {
          cancelledCalled = true;
          cancelMeta = meta;
        },
      ));
      await openDialog(tester);

      await tester.enterText(
        find.byKey(const Key('bc-prompt-input')),
        'Uncommitted',
      );
      await tester.pump();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(cancelledCalled, isTrue);
      expect(confirmedCalled, isFalse);
      expect(confirmedValue, isNull);
      expect(cancelMeta, isNotNull);
    });

    testWidgets(
        'controlled value is reflected and OK disabled when input fails '
        'validation (VAL-M4-004)', (tester) async {
      bool confirmedCalled = false;

      await tester.pumpWidget(buildHarness(
        controlledValue: '',
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Required' : null,
        onConfirm: (value, meta) {
          confirmedCalled = true;
        },
      ));
      await openDialog(tester);

      final confirmButton = tester.widget<FilledButton>(
        find.byKey(const Key('bc-prompt-confirm')),
      );
      expect(confirmButton.onPressed, isNull,
          reason: 'OK should be disabled when validation fails');

      expect(find.text('Required'), findsOneWidget,
          reason: 'validation error text should be rendered');

      await tester.tap(find.byKey(const Key('bc-prompt-confirm')));
      await tester.pumpAndSettle();

      expect(confirmedCalled, isFalse,
          reason: 'confirm should not fire when disabled');
      expect(find.byKey(const Key('bc-prompt-input')), findsOneWidget,
          reason: 'dialog should remain open');
    });

    testWidgets(
        'entering a valid value re-enables OK (VAL-M4-004)',
        (tester) async {
      String? confirmedValue;

      String controlledValue = '';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      key: const Key('open-trigger'),
                      onPressed: () {
                        BcPrompt.show(
                          context: context,
                          title: 'Enter name',
                          value: controlledValue,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                          onConfirm: (value, meta) {
                            confirmedValue = value;
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
      await tester.tap(find.byKey(const Key('open-trigger')));
      await tester.pumpAndSettle();

      final confirmDisabled = tester.widget<FilledButton>(
        find.byKey(const Key('bc-prompt-confirm')),
      );
      expect(confirmDisabled.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('bc-prompt-input')),
        'Charlie',
      );
      await tester.pump();

      final confirmEnabled = tester.widget<FilledButton>(
        find.byKey(const Key('bc-prompt-confirm')),
      );
      expect(confirmEnabled.onPressed, isNotNull,
          reason: 'OK should be re-enabled after entering valid value');

      await tester.tap(find.byKey(const Key('bc-prompt-confirm')));
      await tester.pumpAndSettle();

      expect(confirmedValue, isNotNull);
    });
  });
}
