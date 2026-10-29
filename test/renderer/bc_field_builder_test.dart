import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/src/components/bc_checkbox.dart';
import 'package:bc_ui_flutter/src/components/bc_date_field.dart';
import 'package:bc_ui_flutter/src/components/bc_input.dart';
import 'package:bc_ui_flutter/src/components/bc_number_field.dart';
import 'package:bc_ui_flutter/src/components/bc_select.dart';
import 'package:bc_ui_flutter/src/components/bc_toggle.dart';
import 'package:bc_ui_flutter/src/core/reactive_store.dart' hide DataSource;
import 'package:bc_ui_flutter/src/renderer/bc_field_builder.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema_types.dart' as schema_types;

// ---------------------------------------------------------------------------
// Helper: pump buildField inside a minimal widget tree.
// ---------------------------------------------------------------------------

Future<void> _pumpField(
  WidgetTester tester,
  FieldNode node,
  ReactiveStore store, {
  bool disabled = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: buildField(node, store, disabled: disabled),
      ),
    ),
  );
}

void main() {
  // =========================================================================
  // VAL-FB-001 — input maps to BcInput with text keyboard
  // =========================================================================
  group('VAL-FB-001 input', () {
    testWidgets('maps to BcInput with text keyboard', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.input);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.keyboardType, TextInputType.text);
      expect(widget.obscureText, isFalse);
      expect(widget.maxLines, 1);
    });
  });

  // =========================================================================
  // VAL-FB-002 — email maps to BcInput with emailAddress keyboard
  // =========================================================================
  group('VAL-FB-002 email', () {
    testWidgets('maps to BcInput with emailAddress keyboard', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.email);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.keyboardType, TextInputType.emailAddress);
      expect(widget.obscureText, isFalse);
    });
  });

  // =========================================================================
  // VAL-FB-003 — password maps to BcInput with obscureText
  // =========================================================================
  group('VAL-FB-003 password', () {
    testWidgets('maps to BcInput with obscureText true', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.password);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.obscureText, isTrue);
      expect(widget.keyboardType, TextInputType.text);
    });
  });

  // =========================================================================
  // VAL-FB-004 — url maps to BcInput with url keyboard
  // =========================================================================
  group('VAL-FB-004 url', () {
    testWidgets('maps to BcInput with url keyboard', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.url);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.keyboardType, TextInputType.url);
    });
  });

  // =========================================================================
  // VAL-FB-005 — tel maps to BcInput with phone keyboard
  // =========================================================================
  group('VAL-FB-005 tel', () {
    testWidgets('maps to BcInput with phone keyboard', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.tel);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.keyboardType, TextInputType.phone);
    });
  });

  // =========================================================================
  // VAL-FB-006 — textarea maps to BcInput with multiline maxLines
  // =========================================================================
  group('VAL-FB-006 textarea', () {
    testWidgets('maps to BcInput with maxLines null', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.textarea);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.maxLines, isNull);
      expect(widget.obscureText, isFalse);
    });
  });

  // =========================================================================
  // VAL-FB-007 — number maps to BcNumberField with bounds forwarded
  // =========================================================================
  group('VAL-FB-007 number', () {
    testWidgets('maps to BcNumberField and forwards min/max', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'qty',
        type: FieldType.number,
        min: 0,
        max: 100,
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.min, 0);
      expect(widget.max, 100);
    });

    testWidgets('null min/max forwarded as null', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'qty', type: FieldType.number);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.min, isNull);
      expect(widget.max, isNull);
    });
  });

  // =========================================================================
  // VAL-FB-008 — date maps to BcDateField
  // =========================================================================
  group('VAL-FB-008 date', () {
    testWidgets('maps to BcDateField', (tester) async {
      final dt = DateTime(2025, 1, 15);
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'bday': dt}),
      );
      final node = FieldNode(name: 'bday', type: FieldType.date);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value, dt);
    });
  });

  // =========================================================================
  // VAL-FB-009 — select maps to BcSelect with inline options forwarded
  // =========================================================================
  group('VAL-FB-009 select', () {
    testWidgets('maps to BcSelect with forwarded options', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'country': 'us'}),
      );
      final node = FieldNode(
        name: 'country',
        type: FieldType.select,
        options: [
          const FieldOption(value: 'us', label: 'United States'),
          const FieldOption(value: 'ca', label: 'Canada'),
        ],
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcSelect<String>>(find.byWidgetPredicate((w) => w is BcSelect));
      expect(widget.options.length, 2);
      expect(widget.options[0].value, 'us');
      expect(widget.options[0].label, 'United States');
      expect(widget.options[1].value, 'ca');
      expect(widget.options[1].label, 'Canada');
      expect(widget.value, 'us');
    });

    testWidgets('empty options yields empty BcSelect options', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.select);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcSelect<String>>(find.byWidgetPredicate((w) => w is BcSelect));
      expect(widget.options, isEmpty);
    });
  });

  // =========================================================================
  // VAL-FB-010 — checkbox maps to BcCheckbox
  // =========================================================================
  group('VAL-FB-010 checkbox', () {
    testWidgets('maps to BcCheckbox with value and label', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'agree': true}),
      );
      final node = FieldNode(
        name: 'agree',
        type: FieldType.checkbox,
        label: 'I agree',
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcCheckbox>(find.byType(BcCheckbox));
      expect(widget.value, isTrue);
      expect(widget.label, 'I agree');
    });
  });

  // =========================================================================
  // VAL-FB-011 — toggle maps to BcToggle (distinct from checkbox)
  // =========================================================================
  group('VAL-FB-011 toggle', () {
    testWidgets('maps to BcToggle not BcCheckbox', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'flag': true}),
      );
      final node = FieldNode(
        name: 'flag',
        type: FieldType.toggle,
        label: 'Enable',
      );
      await _pumpField(tester, node, store);

      expect(find.byType(BcToggle), findsOneWidget);
      expect(find.byType(BcCheckbox), findsNothing);

      final widget = tester.widget<BcToggle>(find.byType(BcToggle));
      expect(widget.value, isTrue);
    });
  });

  // =========================================================================
  // VAL-FB-012 — initial value read from store via get(name)
  // =========================================================================
  group('VAL-FB-012 initial value from store', () {
    testWidgets('input value from store', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'firstName': 'Ada'}),
      );
      await _pumpField(
        tester,
        FieldNode(name: 'firstName', type: FieldType.input),
        store,
      );
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.value, 'Ada');
    });

    testWidgets('number value from store', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'age': 42}),
      );
      await _pumpField(
        tester,
        FieldNode(name: 'age', type: FieldType.number),
        store,
      );
      final widget = tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.value, 42);
    });

    testWidgets('date value from store', (tester) async {
      final dt = DateTime(2024, 6, 1);
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'birthday': dt}),
      );
      await _pumpField(
        tester,
        FieldNode(name: 'birthday', type: FieldType.date),
        store,
      );
      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value, dt);
    });

    testWidgets('checkbox value from store', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'agree': true}),
      );
      await _pumpField(
        tester,
        FieldNode(name: 'agree', type: FieldType.checkbox),
        store,
      );
      final widget = tester.widget<BcCheckbox>(find.byType(BcCheckbox));
      expect(widget.value, isTrue);
    });

    testWidgets('null store value yields null widget value for input',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.value, isNull);
    });
  });

  // =========================================================================
  // VAL-FB-013 — changes written back via store.set(name, value)
  // =========================================================================
  group('VAL-FB-013 store write', () {
    testWidgets('BcInput writes back to store', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'firstName', type: FieldType.input),
        store,
      );

      await tester.enterText(find.byType(TextField), 'Grace');
      await tester.pump();

      expect(store.get('firstName'), 'Grace');
    });

    testWidgets('BcNumberField writes back to store', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'qty', type: FieldType.number),
        store,
      );

      await tester.enterText(find.byType(TextField), '7');
      await tester.pump();

      expect(store.get('qty'), 7);
    });

    testWidgets('BcCheckbox writes back to store', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'agree', type: FieldType.checkbox),
        store,
      );

      // Tap the checkbox.
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(store.get('agree'), isTrue);
    });

    testWidgets('BcToggle writes back to store', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'flag', type: FieldType.toggle),
        store,
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(store.get('flag'), isTrue);
    });

    testWidgets('value passed to set matches widget callback', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      expect(store.get('f'), 'hello');
    });
  });

  // =========================================================================
  // VAL-FB-014 — disabled propagated from the disabled parameter
  // =========================================================================
  group('VAL-FB-014 disabled parameter', () {
    testWidgets('disabled param true overrides node false', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.input, disabled: false);
      await _pumpField(tester, node, store, disabled: true);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.disabled, isTrue);
    });

    testWidgets('disabled param true on number field', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.number);
      await _pumpField(tester, node, store, disabled: true);

      final widget =
          tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.disabled, isTrue);
    });
  });

  // =========================================================================
  // VAL-FB-015 — disabled propagated from FieldNode.disabled
  // =========================================================================
  group('VAL-FB-015 node disabled', () {
    testWidgets('node disabled true with param false', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.input, disabled: true);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.disabled, isTrue);
    });

    testWidgets('node disabled false with param omitted', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.input, disabled: false);
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.disabled, isFalse);
    });
  });

  // =========================================================================
  // VAL-FB-016 — disabled parameter precedence (OR / union semantics)
  // =========================================================================
  group('VAL-FB-016 disabled precedence', () {
    testWidgets('param false node false => false', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
        disabled: false,
      );
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.disabled, isFalse);
    });

    testWidgets('param false node true => true', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: true),
        store,
        disabled: false,
      );
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.disabled, isTrue);
    });

    testWidgets('param true node false => true', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
        disabled: true,
      );
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.disabled, isTrue);
    });

    testWidgets('param true node true => true', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: true),
        store,
        disabled: true,
      );
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.disabled, isTrue);
    });
  });

  // =========================================================================
  // VAL-FB-017 — label forwarded to widget
  // =========================================================================
  group('VAL-FB-017 label', () {
    testWidgets('label forwarded to all widget types', (tester) async {
      final store = ReactiveStore();

      // BcInput
      await _pumpField(
        tester,
        FieldNode(name: 'a', type: FieldType.input, label: 'Name'),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).label,
        'Name',
      );

      // BcNumberField
      await _pumpField(
        tester,
        FieldNode(name: 'b', type: FieldType.number, label: 'Count'),
        store,
      );
      expect(
        tester.widget<BcNumberField>(find.byType(BcNumberField)).label,
        'Count',
      );

      // BcDateField
      await _pumpField(
        tester,
        FieldNode(name: 'c', type: FieldType.date, label: 'Day'),
        store,
      );
      expect(
        tester.widget<BcDateField>(find.byType(BcDateField)).label,
        'Day',
      );

      // BcSelect
      await _pumpField(
        tester,
        FieldNode(name: 'd', type: FieldType.select, label: 'Choice'),
        store,
      );
      expect(
        tester.widget<BcSelect>(find.byWidgetPredicate((w) => w is BcSelect)).label,
        'Choice',
      );

      // BcCheckbox
      await _pumpField(
        tester,
        FieldNode(name: 'e', type: FieldType.checkbox, label: 'Ok'),
        store,
      );
      expect(
        tester.widget<BcCheckbox>(find.byType(BcCheckbox)).label,
        'Ok',
      );

      // BcToggle
      await _pumpField(
        tester,
        FieldNode(name: 'g', type: FieldType.toggle, label: 'On'),
        store,
      );
      expect(
        tester.widget<BcToggle>(find.byType(BcToggle)).label,
        'On',
      );
    });

    testWidgets('null label stays null (no name fallback)', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'a', type: FieldType.input),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).label,
        isNull,
      );
    });
  });

  // =========================================================================
  // VAL-FB-018 — placeholder forwarded to widget
  // =========================================================================
  group('VAL-FB-018 placeholder', () {
    testWidgets('placeholder forwarded', (tester) async {
      final store = ReactiveStore();

      await _pumpField(
        tester,
        FieldNode(name: 'a', type: FieldType.input, placeholder: 'Type here'),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).placeholder,
        'Type here',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'b', type: FieldType.number, placeholder: '0'),
        store,
      );
      expect(
        tester.widget<BcNumberField>(find.byType(BcNumberField)).placeholder,
        '0',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'c', type: FieldType.date, placeholder: 'Pick date'),
        store,
      );
      expect(
        tester.widget<BcDateField>(find.byType(BcDateField)).placeholder,
        'Pick date',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'd', type: FieldType.select, placeholder: 'Choose'),
        store,
      );
      expect(
        tester.widget<BcSelect>(find.byWidgetPredicate((w) => w is BcSelect)).placeholder,
        'Choose',
      );
    });

    testWidgets('null placeholder stays null', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'a', type: FieldType.input),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).placeholder,
        isNull,
      );
    });
  });

  // =========================================================================
  // VAL-FB-019 — hint forwarded as helperText
  // =========================================================================
  group('VAL-FB-019 hint', () {
    testWidgets('hint forwarded as helperText on BcInput', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'a', type: FieldType.input, hint: 'Helpful text'),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).helperText,
        'Helpful text',
      );
    });

    testWidgets('null hint stays null', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'a', type: FieldType.input),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).helperText,
        isNull,
      );
    });
  });

  // =========================================================================
  // VAL-FB-020 / VAL-FB-021 — null type defaults to input
  // =========================================================================
  group('VAL-FB-020 VAL-FB-021 null type', () {
    testWidgets('null type defaults to BcInput text keyboard', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f');
      await _pumpField(tester, node, store);

      expect(find.byType(BcInput), findsOneWidget);
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.keyboardType, TextInputType.text);
      expect(widget.obscureText, isFalse);
    });

    testWidgets('null type does not crash', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f');
      await _pumpField(tester, node, store);

      expect(find.byType(BcInput), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-FB-022 — reactive rebuild on store metadata change
  // =========================================================================
  group('VAL-FB-022 reactive rebuild', () {
    testWidgets('field rebuilds when store notifies', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(disabled: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );

      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );

      // Initially not disabled.
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isFalse,
      );

      // Flip trigger so the UiEffect disables field 'f'.
      store.set('trigger', true);
      await tester.pumpAndSettle();

      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isTrue,
      );
    });
  });

  // =========================================================================
  // VAL-FB-023 / VAL-FB-053 — FieldMeta.visible false hides the field
  // =========================================================================
  group('VAL-FB-023 VAL-FB-053 hidden field', () {
    testWidgets('FieldMeta visible false renders SizedBox.shrink', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'hidden': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'hidden',
              effect: UiEffect(visible: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );
      // Run reactions to set hidden.visible = false initially.
      store.runAll();

      await _pumpField(
        tester,
        FieldNode(name: 'hidden', type: FieldType.input),
        store,
      );

      expect(find.byType(BcInput), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('no interactive control when hidden', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'hidden': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'hidden',
              effect: UiEffect(visible: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );
      store.runAll();

      await _pumpField(
        tester,
        FieldNode(name: 'hidden', type: FieldType.input),
        store,
      );

      expect(find.byType(BcInput), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });
  });

  // =========================================================================
  // VAL-FB-024 — FieldMeta.required reflected on rebuild
  // =========================================================================
  group('VAL-FB-024 required metadata', () {
    testWidgets('FieldMeta.required true does not crash and widget renders',
        (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(required: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );

      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );

      // Trigger required true.
      store.set('trigger', true);
      await tester.pumpAndSettle();

      // The field widget is still present (no crash).
      expect(find.byType(BcInput), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-FB-025 — FieldMeta.disabled overrides FieldNode.disabled on rebuild
  // =========================================================================
  group('VAL-FB-025 meta disabled override', () {
    testWidgets('meta disabled flips to true on rebuild', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(disabled: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );

      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
      );

      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isFalse,
      );

      // Flip metadata disabled to true.
      store.set('trigger', true);
      await tester.pumpAndSettle();

      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isTrue,
      );
    });

    testWidgets('meta disabled flips to false on rebuild', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': true, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(disabled: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );
      // Run reactions to set f.disabled = true initially.
      store.runAll();

      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
      );

      // Initially disabled by meta.
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isTrue,
      );

      // Flip trigger to false => meta disabled false.
      store.set('trigger', false);
      await tester.pumpAndSettle();

      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isFalse,
      );
    });
  });

  // =========================================================================
  // VAL-FB-026 — listener disposed to prevent leaks
  // =========================================================================
  group('VAL-FB-026 listener disposal', () {
    testWidgets('unmounting field does not cause setState after dispose',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );
      expect(find.byType(BcInput), findsOneWidget);

      // Replace the tree with something else (unmounting the field).
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Trigger a store notification — should not cause any FlutterError.
      var hadFlutterError = false;
      final originalErrorHandler = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        hadFlutterError = true;
      };

      store.set('f', 'new-value');
      await tester.pump();

      FlutterError.onError = originalErrorHandler;
      expect(hadFlutterError, isFalse);
    });
  });

  // =========================================================================
  // VAL-FB-027 — store.set receives correct name for each field
  // =========================================================================
  group('VAL-FB-027 correct name', () {
    testWidgets('dotted name forwarded to store.set', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'contact.email', type: FieldType.input, label: 'Email'),
        store,
      );

      await tester.enterText(find.byType(TextField), 'a@b.com');
      await tester.pump();

      expect(store.get('contact.email'), 'a@b.com');
    });
  });

  // =========================================================================
  // VAL-FB-028 — onValueChange meta forwarded without mutation
  // =========================================================================
  group('VAL-FB-028 meta integrity', () {
    testWidgets('value from callback reaches store unchanged', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      expect(store.get('f'), 'hello');
    });

    testWidgets('checkbox value from callback reaches store unchanged',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.checkbox),
        store,
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(store.get('f'), isTrue);
    });
  });

  // =========================================================================
  // VAL-FB-029 — select with null store value renders unselected
  // =========================================================================
  group('VAL-FB-029 select null value', () {
    testWidgets('null store value yields null BcSelect value', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'country',
        type: FieldType.select,
        options: [
          const FieldOption(value: 'us', label: 'US'),
        ],
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcSelect<String>>(find.byWidgetPredicate((w) => w is BcSelect));
      expect(widget.value, isNull);
      expect(widget.options.length, 1);
    });
  });

  // =========================================================================
  // VAL-FB-030 — number field with null store value renders empty
  // =========================================================================
  group('VAL-FB-030 number null value', () {
    testWidgets('null store value yields null BcNumberField value',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'qty', type: FieldType.number),
        store,
      );

      final widget =
          tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.value, isNull);
    });
  });

  // =========================================================================
  // VAL-FB-031 — date field with null store value renders empty
  // =========================================================================
  group('VAL-FB-031 date null value', () {
    testWidgets('null store value yields null BcDateField value',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'bday', type: FieldType.date),
        store,
      );

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value, isNull);
    });
  });

  // =========================================================================
  // VAL-FB-032 — checkbox/toggle store value coerced to nullable bool
  // =========================================================================
  group('VAL-FB-032 bool coercion', () {
    testWidgets('checkbox null true false values', (tester) async {
      for (final val in [null, true, false]) {
        final store = ReactiveStore(
          ReactiveStoreOptions(initialValues: {'f': val}),
        );
        await _pumpField(
          tester,
          FieldNode(name: 'f', type: FieldType.checkbox),
          store,
        );
        expect(
          tester.widget<BcCheckbox>(find.byType(BcCheckbox)).value,
          val,
        );
      }
    });

    testWidgets('toggle null true false values', (tester) async {
      for (final val in [null, true, false]) {
        final store = ReactiveStore(
          ReactiveStoreOptions(initialValues: {'f': val}),
        );
        await _pumpField(
          tester,
          FieldNode(name: 'f', type: FieldType.toggle),
          store,
        );
        expect(
          tester.widget<BcToggle>(find.byType(BcToggle)).value,
          val,
        );
      }
    });
  });

  // =========================================================================
  // VAL-FB-033 — input variants share BcInput type but differ in config
  // =========================================================================
  group('VAL-FB-033 input variants', () {
    testWidgets('all six input-like types return BcInput', (tester) async {
      final variants = [
        FieldType.input,
        FieldType.email,
        FieldType.password,
        FieldType.url,
        FieldType.tel,
        FieldType.textarea,
      ];
      for (final t in variants) {
        final store = ReactiveStore();
        await _pumpField(tester, FieldNode(name: 'f', type: t), store);
        expect(find.byType(BcInput), findsOneWidget,
            reason: 'Type $t should map to BcInput');
      }
    });
  });

  // =========================================================================
  // VAL-FB-034 — FieldNode.name is non-null (precondition)
  // =========================================================================
  group('VAL-FB-034 name non-null', () {
    testWidgets('empty string name forwarded to store without rename',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: '', type: FieldType.input),
        store,
      );

      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();

      expect(store.get(''), 'x');
    });
  });

  // =========================================================================
  // VAL-FB-035 — optionsSource not resolved by builder
  // =========================================================================
  group('VAL-FB-035 optionsSource ignored', () {
    testWidgets('optionsSource set with empty options yields empty select',
        (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'f',
        type: FieldType.select,
        optionsSource: schema_types.DataSource.url(
          url: 'https://example.com/options.json',
        ),
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcSelect<String>>(find.byWidgetPredicate((w) => w is BcSelect));
      expect(widget.options, isEmpty);
    });
  });

  // =========================================================================
  // VAL-FB-036 — validation rules ignored at build time
  // =========================================================================
  group('VAL-FB-036 validation ignored', () {
    testWidgets('validation rules do not affect widget', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'f',
        type: FieldType.input,
        validation: [
          const ValidationRule(type: 'required', message: 'Required'),
        ],
      );
      await _pumpField(tester, node, store);

      // Widget builds fine.
      expect(find.byType(BcInput), findsOneWidget);
      // No crash, widget props are standard.
      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.placeholder, isNull);
      expect(widget.helperText, isNull);
    });
  });

  // =========================================================================
  // VAL-FB-037 — pattern not wired into widget
  // =========================================================================
  group('VAL-FB-037 pattern ignored', () {
    testWidgets('pattern does not affect any widget prop', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'f',
        type: FieldType.input,
        pattern: r'^\d+$',
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.placeholder, isNull);
      expect(widget.helperText, isNull);
      expect(widget.maxLength, isNull);
    });
  });

  // =========================================================================
  // VAL-FB-038 — buildField is pure given store state
  // =========================================================================
  group('VAL-FB-038 purity', () {
    testWidgets('two consecutive calls produce equal props', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'f': 'hello'}),
      );
      final node = FieldNode(
        name: 'f',
        type: FieldType.input,
        label: 'Label',
        placeholder: 'Ph',
        disabled: true,
      );

      await _pumpField(tester, node, store);
      final w1 = tester.widget<BcInput>(find.byType(BcInput));

      await _pumpField(tester, node, store);
      final w2 = tester.widget<BcInput>(find.byType(BcInput));

      expect(w1.value, w2.value);
      expect(w1.label, w2.label);
      expect(w1.placeholder, w2.placeholder);
      expect(w1.disabled, w2.disabled);
      expect(w1.keyboardType, w2.keyboardType);
    });
  });

  // =========================================================================
  // VAL-FB-039 — toggle preserves distinction lost by resolver
  // =========================================================================
  group('VAL-FB-039 toggle distinction', () {
    testWidgets('toggle yields BcToggle not BcCheckbox', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.toggle),
        store,
      );
      expect(find.byType(BcToggle), findsOneWidget);
      expect(find.byType(BcCheckbox), findsNothing);
    });

    testWidgets('checkbox yields BcCheckbox not BcToggle', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.checkbox),
        store,
      );
      expect(find.byType(BcCheckbox), findsOneWidget);
      expect(find.byType(BcToggle), findsNothing);
    });
  });

  // =========================================================================
  // VAL-FB-040 — BcSelect generic type is String
  // =========================================================================
  group('VAL-FB-040 select generic String', () {
    testWidgets('BcSelect is parameterized as String', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'f',
        type: FieldType.select,
        options: [
          const FieldOption(value: 'a', label: 'A'),
        ],
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcSelect<String>>(find.byWidgetPredicate((w) => w is BcSelect));
      expect(widget.options.first.value, isA<String>());
    });
  });

  // =========================================================================
  // VAL-FB-041 — name forwarded to widget for form keying
  // =========================================================================
  group('VAL-FB-041 name forwarding', () {
    testWidgets('name forwarded to all widget types', (tester) async {
      final store = ReactiveStore();

      await _pumpField(
        tester,
        FieldNode(name: 'a', type: FieldType.input),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).name,
        'a',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'b', type: FieldType.number),
        store,
      );
      expect(
        tester.widget<BcNumberField>(find.byType(BcNumberField)).name,
        'b',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'c', type: FieldType.date),
        store,
      );
      expect(
        tester.widget<BcDateField>(find.byType(BcDateField)).name,
        'c',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'd', type: FieldType.select),
        store,
      );
      expect(
        tester.widget<BcSelect>(find.byWidgetPredicate((w) => w is BcSelect)).name,
        'd',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'e', type: FieldType.checkbox),
        store,
      );
      expect(
        tester.widget<BcCheckbox>(find.byType(BcCheckbox)).name,
        'e',
      );

      await _pumpField(
        tester,
        FieldNode(name: 'g', type: FieldType.toggle),
        store,
      );
      expect(
        tester.widget<BcToggle>(find.byType(BcToggle)).name,
        'g',
      );
    });
  });

  // =========================================================================
  // VAL-FB-042 — required flag from FieldNode forwarded where supported
  // =========================================================================
  group('VAL-FB-042 required flag', () {
    testWidgets('node required true does not crash on build', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(name: 'f', type: FieldType.input, required: true);
      await _pumpField(tester, node, store);

      // Widget builds without crash.
      expect(find.byType(BcInput), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-FB-043 — disabled parameter defaults to false
  // =========================================================================
  group('VAL-FB-043 disabled default', () {
    testWidgets('omitting disabled param equals disabled false', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isFalse,
      );
    });
  });

  // =========================================================================
  // VAL-FB-044 / VAL-FB-045 — store.getMeta used for reactive metadata
  // =========================================================================
  group('VAL-FB-044 VAL-FB-045 metadata defaults', () {
    testWidgets('missing FieldMeta renders normally (no crash)', (tester) async {
      final store = ReactiveStore();
      // No meta set for 'f' — getMeta returns default FieldMeta().
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );

      expect(find.byType(BcInput), findsOneWidget);
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isFalse,
      );
    });

    testWidgets('getMeta default visible true renders the field',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );
      expect(find.byType(BcInput), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-FB-046 / VAL-FB-054 — all FieldType enum values handled (exhaustiveness)
  // =========================================================================
  group('VAL-FB-046 VAL-FB-054 exhaustiveness', () {
    final expectedTypes = <FieldType, bool Function(Widget)>{
      FieldType.input: (w) => w is BcInput,
      FieldType.email: (w) => w is BcInput,
      FieldType.password: (w) => w is BcInput,
      FieldType.url: (w) => w is BcInput,
      FieldType.tel: (w) => w is BcInput,
      FieldType.textarea: (w) => w is BcInput,
      FieldType.number: (w) => w is BcNumberField,
      FieldType.date: (w) => w is BcDateField,
      FieldType.select: (w) => w is BcSelect,
      FieldType.toggle: (w) => w is BcToggle,
      FieldType.checkbox: (w) => w is BcCheckbox,
    };

    final expectedTypeNames = <FieldType, String>{
      FieldType.input: 'BcInput',
      FieldType.email: 'BcInput',
      FieldType.password: 'BcInput',
      FieldType.url: 'BcInput',
      FieldType.tel: 'BcInput',
      FieldType.textarea: 'BcInput',
      FieldType.number: 'BcNumberField',
      FieldType.date: 'BcDateField',
      FieldType.select: 'BcSelect',
      FieldType.toggle: 'BcToggle',
      FieldType.checkbox: 'BcCheckbox',
    };

    for (final entry in expectedTypes.entries) {
      testWidgets(
          'FieldType.${entry.key.name} maps to ${expectedTypeNames[entry.key]}',
          (tester) async {
        final store = ReactiveStore();
        await _pumpField(
          tester,
          FieldNode(name: 'f', type: entry.key),
          store,
        );
        expect(
          find.byWidgetPredicate(entry.value),
          findsOneWidget,
        );
      });
    }

    testWidgets('null type maps to BcInput', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f'),
        store,
      );
      expect(find.byType(BcInput), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-FB-047 — number fields do not require step forwarding
  // =========================================================================
  group('VAL-FB-047 no step', () {
    testWidgets('number field renders without step requirement', (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'f',
        type: FieldType.number,
        min: 0,
        max: 10,
      );
      await _pumpField(tester, node, store);

      final widget =
          tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.min, 0);
      expect(widget.max, 10);
      // BcNumberField has a default step; builder does not invent one.
      expect(widget.step, 1);
    });
  });

  // =========================================================================
  // VAL-FB-048 — field builder uses store metadata without mutating it
  // =========================================================================
  group('VAL-FB-048 no metadata mutation', () {
    testWidgets('builder does not call store.set with metadata', (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(initialValues: {'f': ''}),
      );
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );

      // Verify that building the field did not change the store value.
      expect(store.get('f'), '');
    });
  });

  // =========================================================================
  // VAL-FB-049 — reactive rebuilds use public store subscription APIs
  // =========================================================================
  group('VAL-FB-049 public subscription', () {
    testWidgets('field reacts to store changes via public subscribe API',
        (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(visible: (scope) => scope['trigger'] == false),
            ),
          ],
        ),
      );

      // No reactions need to be pre-run since getMeta returns default initially.
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input),
        store,
      );
      expect(find.byType(BcInput), findsOneWidget);

      // Use public set() to trigger the reaction which sets visible=false.
      store.set('trigger', true);
      await tester.pumpAndSettle();

      // Field should now be hidden.
      expect(find.byType(BcInput), findsNothing);
    });
  });

  // =========================================================================
  // VAL-FB-050 — required precedence combines node and metadata predictably
  // =========================================================================
  group('VAL-FB-050 required precedence', () {
    testWidgets('node only required renders without crash', (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, required: true),
        store,
      );
      expect(find.byType(BcInput), findsOneWidget);
    });

    testWidgets('metadata override to true renders without crash',
        (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(required: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );

      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, required: false),
        store,
      );

      store.set('trigger', true);
      await tester.pumpAndSettle();

      // Renders fine — required is meta-driven, no crash.
      expect(find.byType(BcInput), findsOneWidget);
    });

    testWidgets('metadata override to false renders without crash',
        (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': true, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(required: (scope) => scope['trigger'] == false),
            ),
          ],
        ),
      );

      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, required: true),
        store,
      );

      store.set('trigger', false);
      await tester.pumpAndSettle();

      expect(find.byType(BcInput), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-FB-051 — unsupported schema-only fields remain out of scope
  // =========================================================================
  group('VAL-FB-051 unsupported props', () {
    testWidgets('pattern validation optionsSource all present no crash',
        (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'f',
        type: FieldType.input,
        pattern: r'^\d+$',
        validation: [
          const ValidationRule(type: 'min', value: 3),
        ],
      );
      await _pumpField(tester, node, store);

      // Renders fine — unsupported props do not crash.
      expect(find.byType(BcInput), findsOneWidget);

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      // No unsupported prop wired.
      expect(widget.maxLength, isNull);
      expect(widget.helperText, isNull);
    });

    testWidgets('select with optionsSource but no inline options renders empty',
        (tester) async {
      final store = ReactiveStore();
      final node = FieldNode(
        name: 'f',
        type: FieldType.select,
        optionsSource: schema_types.DataSource.url(url: 'https://x.com'),
      );
      await _pumpField(tester, node, store);

      final widget = tester.widget<BcSelect<String>>(find.byWidgetPredicate((w) => w is BcSelect));
      expect(widget.options, isEmpty);
    });
  });

  // =========================================================================
  // VAL-FB-052 — disabled precedence: renderer disabled, then metadata, then node
  // =========================================================================
  group('VAL-FB-052 disabled full precedence', () {
    testWidgets(
        'renderer disabled true wins over everything',
        (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': false, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(disabled: (scope) => false),
            ),
          ],
        ),
      );
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
        disabled: true,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isTrue,
      );
    });

    testWidgets(
        'metadata disabled true wins over node false when renderer false',
        (tester) async {
      final store = ReactiveStore(
        ReactiveStoreOptions(
          initialValues: {'trigger': true, 'f': ''},
          reactions: [
            Reaction(
              when: 'trigger',
              target: 'f',
              effect: UiEffect(disabled: (scope) => scope['trigger'] == true),
            ),
          ],
        ),
      );
      // Run reactions so meta disabled = true initially.
      store.runAll();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
        disabled: false,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isTrue,
      );
    });

    testWidgets(
        'node disabled true when renderer false and meta default false',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: true),
        store,
        disabled: false,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isTrue,
      );
    });

    testWidgets(
        'all three false yields false',
        (tester) async {
      final store = ReactiveStore();
      await _pumpField(
        tester,
        FieldNode(name: 'f', type: FieldType.input, disabled: false),
        store,
        disabled: false,
      );
      expect(
        tester.widget<BcInput>(find.byType(BcInput)).disabled,
        isFalse,
      );
    });
  });
}
