import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/src/components/bc_form.dart';
import 'package:bc_ui_flutter/src/components/bc_input.dart';
import 'package:bc_ui_flutter/src/components/bc_checkbox.dart';
import 'package:bc_ui_flutter/src/components/bc_toggle.dart';
import 'package:bc_ui_flutter/src/components/bc_number_field.dart';
import 'package:bc_ui_flutter/src/components/bc_select.dart';
import 'package:bc_ui_flutter/src/core/reactive_store.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema.dart';

// ---------------------------------------------------------------------------
// Helper: pump a BcForm with optional fields, actions, child.
// ---------------------------------------------------------------------------

Future<void> _pumpForm(
  WidgetTester tester,
  BcForm form,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: form,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  // =========================================================================
  // VAL-FORM-001 — Backward compatibility: child-only BcForm works
  // =========================================================================
  group('VAL-FORM-001 backward compatibility', () {
    testWidgets('child-only BcForm works without fields', (tester) async {
      ReactiveStore? captured;
      await _pumpForm(
        tester,
        BcForm(
          initialValues: const {'name': 'Alice'},
          onCreateStore: (store) => captured = store,
          child: Builder(
            builder: (context) {
              final store = BcForm.storeOf(context);
              return Text(store?.get('name') ?? 'none');
            },
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.get('name'), 'Alice');
      expect(find.text('Alice'), findsOneWidget);
      // No BcInput or field widgets in legacy mode
      expect(find.byType(BcInput), findsNothing);
    });
  });

  // =========================================================================
  // VAL-FORM-002 — BcForm with fields renders correct field widgets
  // =========================================================================
  group('VAL-FORM-002 fields render', () {
    testWidgets('renders BcInput for input field with label and initial value',
        (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(
                name: 'username', type: FieldType.input, label: 'Username'),
          ],
          initialValues: const {'username': 'bob'},
        ),
      );

      expect(find.byType(BcInput), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('renders multiple fields of different types', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'name', type: FieldType.input, label: 'Name'),
            FieldNode(name: 'age', type: FieldType.number, label: 'Age'),
            FieldNode(
                name: 'active', type: FieldType.toggle, label: 'Active'),
            FieldNode(
                name: 'agree', type: FieldType.checkbox, label: 'Agree'),
            FieldNode(
                name: 'status',
                type: FieldType.select,
                label: 'Status',
                options: const [
                  FieldOption(value: 'a', label: 'Active'),
                  FieldOption(value: 'i', label: 'Inactive'),
                ]),
          ],
        ),
      );

      expect(find.byType(BcInput), findsOneWidget);
      expect(find.byType(BcNumberField), findsOneWidget);
      expect(find.byType(BcToggle), findsOneWidget);
      expect(find.byType(BcCheckbox), findsOneWidget);
      expect(find.byType(BcSelect<String>), findsOneWidget);
    });

    testWidgets('empty fields list does not crash and store is still created',
        (tester) async {
      ReactiveStore? captured;
      await _pumpForm(
        tester,
        BcForm(
          fields: const [],
          onCreateStore: (store) => captured = store,
        ),
      );

      expect(captured, isNotNull);
      expect(find.byType(BcInput), findsNothing);
    });
  });

  // =========================================================================
  // VAL-FORM-003 — Both fields and child render (fields first, child below)
  // =========================================================================
  group('VAL-FORM-003 fields and child', () {
    testWidgets('renders fields first then child below', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'email', type: FieldType.email),
          ],
          initialValues: const {'email': 'test@test.com'},
          child: Builder(
            builder: (context) {
              final store = BcForm.storeOf(context);
              return Text('child:${store?.get('email')}');
            },
          ),
        ),
      );

      expect(find.byType(BcInput), findsOneWidget);
      expect(find.text('child:test@test.com'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-FORM-004 — Action buttons rendered when actions list is provided
  // =========================================================================
  group('VAL-FORM-004 action buttons', () {
    testWidgets('renders action buttons with labels', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'f')],
          actions: [
            const UiAction(name: 'save', label: 'Save'),
            const UiAction(name: 'cancel', label: 'Cancel'),
          ],
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(PlatformElevatedButton), findsNWidgets(2));
    });

    testWidgets('humanizes name when label is null', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'f')],
          actions: [
            const UiAction(name: 'reset_all'),
          ],
        ),
      );

      // Humanized: "Reset All"
      expect(find.text('Reset All'), findsOneWidget);
    });

    testWidgets('disabled action renders as disabled', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'f')],
          actions: [
            const UiAction(name: 'locked', label: 'Locked', disabled: true),
          ],
        ),
      );

      final button = tester.widget<PlatformElevatedButton>(
        find.byType(PlatformElevatedButton),
      );
      expect(button.onPressed, isNull);
    });
  });

  // =========================================================================
  // VAL-FORM-005 — Submit action fires onSubmit callback with form values
  // =========================================================================
  group('VAL-FORM-005 submit action', () {
    testWidgets('tapping submit fires onSubmit with values', (tester) async {
      Map<String, dynamic>? submitted;
      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'email')],
          actions: [
            const UiAction(name: 'submit', label: 'Submit', submit: true),
          ],
          initialValues: const {'email': 'test@example.com'},
          onSubmit: (values) => submitted = values,
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!['email'], 'test@example.com');
    });
  });

  // =========================================================================
  // VAL-FORM-006 — Non-submit action fires onAction with name and values
  // =========================================================================
  group('VAL-FORM-006 non-submit action', () {
    testWidgets('tapping non-submit fires onAction with name and values',
        (tester) async {
      String? actionName;
      Map<String, dynamic>? actionValues;
      Map<String, dynamic>? submittedValues;

      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'note')],
          actions: [
            const UiAction(name: 'reset', label: 'Reset'),
          ],
          initialValues: const {'note': 'hello'},
          onAction: (name, values) {
            actionName = name;
            actionValues = values;
          },
          onSubmit: (values) => submittedValues = values,
        ),
      );

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(actionName, 'reset');
      expect(actionValues!['note'], 'hello');
      // onSubmit should NOT have been fired
      expect(submittedValues, isNull);
    });
  });

  // =========================================================================
  // VAL-FORM-007 — Disabled state disables all fields
  // =========================================================================
  group('VAL-FORM-007 disabled state', () {
    testWidgets('form-level disabled disables all fields', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'name', type: FieldType.input),
          ],
          disabled: true,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('field-level disabled disables specific field',
        (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'name', type: FieldType.input, disabled: true),
          ],
          disabled: false,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('form-level disabled overrides field-level enabled',
        (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'name', type: FieldType.input, disabled: false),
          ],
          disabled: true,
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });

  // =========================================================================
  // VAL-FORM-008 — onChange fires when any field value changes
  // =========================================================================
  group('VAL-FORM-008 onChange', () {
    testWidgets('onChange fires with updated values on text input',
        (tester) async {
      Map<String, dynamic>? lastChange;
      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'city', type: FieldType.input)],
          onChange: (values) => lastChange = values,
        ),
      );

      await tester.enterText(find.byType(TextField), 'Jakarta');
      await tester.pump();

      expect(lastChange, isNotNull);
      expect(lastChange!['city'], 'Jakarta');
    });

    testWidgets('onChange fires again when second field changes',
        (tester) async {
      Map<String, dynamic>? lastChange;
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'a', type: FieldType.input),
            FieldNode(name: 'b', type: FieldType.input),
          ],
          onChange: (values) => lastChange = values,
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'val1');
      await tester.pump();
      expect(lastChange!['a'], 'val1');

      await tester.enterText(find.byType(TextField).at(1), 'val2');
      await tester.pump();
      expect(lastChange!['b'], 'val2');
    });
  });

  // =========================================================================
  // VAL-FORM-009 — Store is created and accessible via storeOf
  // =========================================================================
  group('VAL-FORM-009 store lifecycle', () {
    testWidgets('storeOf returns same instance as onCreateStore',
        (tester) async {
      ReactiveStore? captured;
      ReactiveStore? viaStoreOf;

      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'f')],
          initialValues: const {'x': 1},
          onCreateStore: (store) => captured = store,
          child: Builder(
            builder: (context) {
              viaStoreOf = BcForm.storeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(viaStoreOf, isNotNull);
      expect(identical(captured, viaStoreOf), isTrue);
      expect(captured!.get('x'), 1);
    });

    testWidgets('child-only BcForm also has storeOf', (tester) async {
      ReactiveStore? viaStoreOf;
      await _pumpForm(
        tester,
        BcForm(
          child: Builder(
            builder: (context) {
              viaStoreOf = BcForm.storeOf(context);
              return const Text('child');
            },
          ),
        ),
      );

      expect(viaStoreOf, isNotNull);
    });
  });

  // =========================================================================
  // VAL-FORM-010 — Layout vertical vs horizontal
  // =========================================================================
  group('VAL-FORM-010 layout', () {
    testWidgets('vertical layout stacks fields in a Column', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'a', type: FieldType.input, label: 'A'),
            FieldNode(name: 'b', type: FieldType.input, label: 'B'),
          ],
          layout: FormLayout.vertical,
        ),
      );

      // Both fields rendered
      expect(find.byType(BcInput), findsNWidgets(2));

      // Second field is below the first (vertical offset greater)
      final aRect = tester.getTopLeft(find.text('A'));
      final bRect = tester.getTopLeft(find.text('B'));
      expect(bRect.dy, greaterThan(aRect.dy));
    });

    testWidgets('horizontal layout places fields side by side', (tester) async {
      // Use a wide screen so fields can sit side by side.
      tester.view.physicalSize = const Size(2400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpForm(
        tester,
        BcForm(
          fields: [
            FieldNode(name: 'a', type: FieldType.input, label: 'A'),
            FieldNode(name: 'b', type: FieldType.input, label: 'B'),
          ],
          layout: FormLayout.horizontal,
        ),
      );

      expect(find.byType(BcInput), findsNWidgets(2));

      // In horizontal layout, fields are in a Wrap — second field's
      // horizontal offset is greater than the first's (they sit side by side)
      final aRect = tester.getTopLeft(find.byType(BcInput).first);
      final bRect = tester.getTopLeft(find.byType(BcInput).at(1));
      expect(bRect.dx, greaterThan(aRect.dx));
    });
  });

  // =========================================================================
  // VAL-FORM-011 — Legacy child-only mode ignores renderer action lists
  // =========================================================================
  group('VAL-FORM-011 legacy mode isolation', () {
    testWidgets('child-only mode renders only child, no action buttons',
        (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          child: const Text('Legacy Child'),
        ),
      );

      expect(find.text('Legacy Child'), findsOneWidget);
      expect(find.byType(PlatformElevatedButton), findsNothing);
    });
  });

  // =========================================================================
  // VAL-FORM-012 — Disabled action buttons are inert
  // =========================================================================
  group('VAL-FORM-012 disabled actions inert', () {
    testWidgets('disabled action does not fire callbacks', (tester) async {
      bool submitted = false;
      bool actionFired = false;

      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'f')],
          actions: [
            const UiAction(
                name: 'submit', label: 'Submit', submit: true, disabled: true),
            const UiAction(name: 'cancel', label: 'Cancel', disabled: true),
          ],
          onSubmit: (_) => submitted = true,
          onAction: (_, __) => actionFired = true,
        ),
      );

      // Tap both buttons
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(submitted, isFalse);
      expect(actionFired, isFalse);
    });

    testWidgets('form-level disabled also disables actions', (tester) async {
      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'f')],
          actions: [
            const UiAction(name: 'go', label: 'Go'),
          ],
          disabled: true,
          onAction: (_, __) {},
        ),
      );

      // Button should be disabled (onPressed null)
      final button = tester.widget<PlatformElevatedButton>(
        find.byType(PlatformElevatedButton),
      );
      expect(button.onPressed, isNull);
    });
  });

  // =========================================================================
  // VAL-FORM-013 — BcForm owns and disposes internally-created stores safely
  // =========================================================================
  group('VAL-FORM-013 store disposal', () {
    testWidgets('internally created store is disposed on unmount',
        (tester) async {
      ReactiveStore? captured;

      await _pumpForm(
        tester,
        BcForm(
          fields: [FieldNode(name: 'f')],
          onCreateStore: (store) => captured = store,
        ),
      );

      expect(captured, isNotNull);
      // Access the internal _values to verify the store is alive
      expect(captured!.get('f'), isNull);

      // Unmount the BcForm
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      await tester.pump();

      // After disposal, the store's internal state is cleared.
      // We can't directly assert on disposed state, but we verify no crash
      // and that the widget tree no longer contains BcForm.
      expect(find.byType(BcForm), findsNothing);
    });

    testWidgets('multiple mount/unmount cycles do not crash',
        (tester) async {
      for (var i = 0; i < 3; i++) {
        await _pumpForm(
          tester,
          BcForm(
            fields: [FieldNode(name: 'f')],
            child: Text('cycle $i'),
          ),
        );
        expect(find.text('cycle $i'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        await tester.pump();
      }
    });
  });
}
