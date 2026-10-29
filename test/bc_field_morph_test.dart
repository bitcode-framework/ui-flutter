import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

List<BcFieldMorphType> _defaultTypes() => [
      const BcFieldMorphType(
        value: 'text',
        label: 'Text',
        widget: 'text',
      ),
      const BcFieldMorphType(
        value: 'number',
        label: 'Number',
        widget: 'number',
      ),
      const BcFieldMorphType(
        value: 'date',
        label: 'Date',
        widget: 'date',
      ),
      const BcFieldMorphType(
        value: 'select',
        label: 'Select',
        widget: 'select',
        options: [
          BcFieldMorphOption(label: 'Red', value: 'red'),
          BcFieldMorphOption(label: 'Blue', value: 'blue'),
        ],
      ),
      const BcFieldMorphType(
        value: 'boolean',
        label: 'Boolean',
        widget: 'boolean',
      ),
    ];

Widget _harness(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

Future<void> _selectType(WidgetTester tester, String typeLabel) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(typeLabel).last);
  await tester.pumpAndSettle();
}

void main() {
  // --- VAL-INFRA: typed class tests ---

  test('BcFieldMorphOption has label and value', () {
    const opt = BcFieldMorphOption(label: 'Yes', value: 'Y');
    expect(opt.label, 'Yes');
    expect(opt.value, 'Y');
  });

  test('BcFieldMorphType has value/label/widget/options', () {
    const t = BcFieldMorphType(
      value: 'sel',
      label: 'Selection',
      widget: 'select',
      options: [BcFieldMorphOption(label: 'A', value: 'a')],
    );
    expect(t.value, 'sel');
    expect(t.label, 'Selection');
    expect(t.widget, 'select');
    expect(t.options, isNotNull);
    expect(t.options!.length, 1);

    const t2 = BcFieldMorphType(value: 't', label: 'T', widget: 'text');
    expect(t2.options, isNull);
  });

  test('BcFieldMorphValue has type and nullable value', () {
    const v1 = BcFieldMorphValue(type: 'text', value: 'hello');
    expect(v1.type, 'text');
    expect(v1.value, 'hello');

    const v2 = BcFieldMorphValue(type: 'number', value: 42);
    expect(v2.value, 42);

    const v3 = BcFieldMorphValue(type: 'text');
    expect(v3.value, isNull);
  });

  // --- VAL-MORPH-001 ---

  testWidgets('BcFieldMorph renders type dropdown and value control',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hi'),
      ),
    ));

    expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  // --- VAL-MORPH-002 ---

  testWidgets('BcFieldMorph type dropdown lists all type labels',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(types: _defaultTypes()),
    ));

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();

    expect(find.text('Text'), findsWidgets);
    expect(find.text('Number'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Boolean'), findsOneWidget);
  });

  // --- VAL-MORPH-003 ---

  testWidgets('BcFieldMorph text type renders BcInput', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
      ),
    ));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
  });

  // --- VAL-MORPH-004 ---

  testWidgets('BcFieldMorph number type renders BcNumberField',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'number', value: 42),
      ),
    ));

    expect(find.text('42'), findsOneWidget);
  });

  // --- VAL-MORPH-005 ---

  testWidgets('BcFieldMorph date type renders BcDateField', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'date', value: '2026-06-23'),
      ),
    ));

    expect(find.text('2026-06-23'), findsOneWidget);
  });

  // --- VAL-MORPH-006 ---

  testWidgets('BcFieldMorph select type renders BcSelect with options',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'select', value: 'red'),
      ),
    ));

    expect(find.text('Red'), findsOneWidget);
  });

  // --- VAL-MORPH-007 ---

  testWidgets('BcFieldMorph boolean type renders BcCheckbox', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'boolean', value: true),
      ),
    ));

    expect(find.byType(Checkbox), findsOneWidget);
  });

  // --- VAL-MORPH-008 ---

  testWidgets('BcFieldMorph type change fires typeChange reason',
      (tester) async {
    BcFieldMorphValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    await _selectType(tester, 'Number');

    expect(capturedReason, BcChangeReason.typeChange);
    expect(capturedValue, isNotNull);
    expect(capturedValue!.type, 'number');
  });

  // --- VAL-MORPH-009 ---

  testWidgets('BcFieldMorph value carries over when compatible',
      (tester) async {
    BcFieldMorphValue? capturedValue;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: '42'),
        onValueChange: (v, m) {
          capturedValue = v;
        },
      ),
    ));

    await _selectType(tester, 'Number');

    expect(capturedValue!.type, 'number');
    expect(capturedValue!.value, 42);
  });

  // --- VAL-MORPH-010 ---

  testWidgets('BcFieldMorph value resets when incompatible', (tester) async {
    BcFieldMorphValue? capturedValue;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        onValueChange: (v, m) {
          capturedValue = v;
        },
      ),
    ));

    await _selectType(tester, 'Number');

    expect(capturedValue!.type, 'number');
    expect(capturedValue!.value, isNull);
  });

  // --- VAL-MORPH-011 ---

  testWidgets('BcFieldMorph value input fires valueChange reason',
      (tester) async {
    BcFieldMorphValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text'),
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'world');
    await tester.pump();

    expect(capturedReason, BcChangeReason.valueChange);
    expect(capturedValue!.type, 'text');
    expect(capturedValue!.value, 'world');
  });

  // --- VAL-MORPH-012 ---

  testWidgets('BcFieldMorph clear button shown with value', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        clearable: true,
      ),
    ));

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('BcFieldMorph clear button hidden without value', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text'),
        clearable: true,
      ),
    ));

    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('BcFieldMorph clear button hidden when clearable false',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        clearable: false,
      ),
    ));

    expect(find.byIcon(Icons.close), findsNothing);
  });

  // --- VAL-MORPH-013 ---

  testWidgets('BcFieldMorph clear button clears type and value',
      (tester) async {
    BcFieldMorphValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        clearable: true,
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(capturedReason, BcChangeReason.clear);
    expect(capturedValue!.type, '');
    expect(capturedValue!.value, isNull);
  });

  // --- VAL-MORPH-014 ---

  testWidgets('BcFieldMorph disabled blocks type dropdown', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        disabled: true,
      ),
    ));

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>).first,
    );
    expect(dropdown.onChanged, isNull);
  });

  // --- VAL-MORPH-015 ---

  testWidgets('BcFieldMorph disabled blocks value widget', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        disabled: true,
      ),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);
  });

  // --- VAL-MORPH-016 ---

  testWidgets('BcFieldMorph disabled blocks clear button', (tester) async {
    bool called = false;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        disabled: true,
        clearable: true,
        onValueChange: (v, m) => called = true,
      ),
    ));

    if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
    }
    expect(called, isFalse);
  });

  // --- VAL-MORPH-017 ---

  testWidgets('BcFieldMorph readonly blocks type dropdown', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        readonly: true,
      ),
    ));

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>).first,
    );
    expect(dropdown.onChanged, isNull);
  });

  // --- VAL-MORPH-018 ---

  testWidgets('BcFieldMorph readonly blocks value widget but shows data',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        readonly: true,
      ),
    ));

    expect(find.text('hello'), findsOneWidget);

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.readOnly, isTrue);
  });

  // --- VAL-MORPH-019 ---

  testWidgets('BcFieldMorph readonly blocks clear button', (tester) async {
    bool called = false;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        readonly: true,
        clearable: true,
        onValueChange: (v, m) => called = true,
      ),
    ));

    if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
    }
    expect(called, isFalse);
  });

  // --- VAL-MORPH-020 ---

  testWidgets('BcFieldMorph controlled value drives type and widget',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'number', value: 42),
      ),
    ));

    expect(find.text('42'), findsOneWidget);

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'date', value: '2026-06-23'),
      ),
    ));

    expect(find.text('2026-06-23'), findsOneWidget);
  });

  // --- VAL-MORPH-021 ---

  testWidgets('BcFieldMorph defaultValue initializes uncontrolled state',
      (tester) async {
    BcFieldMorphValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        defaultValue: const BcFieldMorphValue(type: 'text', value: 'init'),
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    expect(find.text('init'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    expect(capturedReason, BcChangeReason.valueChange);
    expect(capturedValue!.value, 'hello');
  });

  // --- VAL-MORPH-022 ---

  testWidgets('BcFieldMorph onValueChange value is BcFieldMorphValue',
      (tester) async {
    Object? capturedValue;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text'),
        onValueChange: (v, m) {
          capturedValue = v;
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();

    expect(capturedValue, isA<BcFieldMorphValue>());
    final morph = capturedValue as BcFieldMorphValue;
    expect(morph.type, 'text');
    expect(morph.value, 'test');
  });

  // --- VAL-MORPH-023 ---

  testWidgets('BcFieldMorph renders label hint description', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        label: 'Configure value',
        hint: 'Pick a type then enter a value',
        description: 'The value type determines the input widget',
      ),
    ));

    expect(find.text('Configure value'), findsOneWidget);
    expect(find.text('Pick a type then enter a value'), findsOneWidget);
    expect(find.text('The value type determines the input widget'), findsOneWidget);
  });

  // --- VAL-MORPH-024 ---

  testWidgets('BcFieldMorph placeholder renders when no value', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text'),
        placeholder: 'Enter value',
      ),
    ));

    expect(find.text('Enter value'), findsOneWidget);
  });

  // --- VAL-MORPH-025 ---

  testWidgets('BcFieldMorph required shows indicator', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        label: 'Field',
        required_: true,
      ),
    ));

    expect(find.text('*'), findsOneWidget);
  });

  testWidgets('BcFieldMorph not required hides indicator', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        label: 'Field',
        required_: false,
      ),
    ));

    expect(find.text('*'), findsNothing);
  });

  // --- VAL-MORPH-026 ---

  testWidgets('BcFieldMorph tap sets source to pointer', (tester) async {
    BcEventSource? capturedSource;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hi'),
        onValueChange: (v, m) {
          capturedSource = m.source;
        },
      ),
    ));

    await _selectType(tester, 'Number');

    expect(capturedSource, BcEventSource.pointer);
  });

  // --- VAL-MORPH-027 ---

  testWidgets('BcFieldMorph reset clears without firing onValueChange',
      (tester) async {
    bool called = false;
    final key = GlobalKey<BcFieldMorphState>();

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        key: key,
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        onValueChange: (v, m) => called = true,
      ),
    ));

    key.currentState!.reset();
    await tester.pump();

    expect(called, isFalse);
  });

  // --- VAL-MORPH-028 ---

  testWidgets('BcFieldMorph clear method fires clear reason', (tester) async {
    BcFieldMorphValue? capturedValue;
    BcChangeReason? capturedReason;
    final key = GlobalKey<BcFieldMorphState>();

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        key: key,
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hello'),
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    key.currentState!.clear();
    await tester.pump();

    expect(capturedReason, BcChangeReason.clear);
    expect(capturedValue!.type, '');
    expect(capturedValue!.value, isNull);
  });

  // --- VAL-MORPH-029 ---

  testWidgets('BcFieldMorph exposes group semantics', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hi'),
      ),
    ));

    expect(
      find.bySemanticsLabel('Field Morph'),
      findsOneWidget,
    );
  });

  // --- VAL-MORPH-030 ---

  testWidgets('BcFieldMorph select to text resets value', (tester) async {
    BcFieldMorphValue? capturedValue;

    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'select', value: 'red'),
        onValueChange: (v, m) {
          capturedValue = v;
        },
      ),
    ));

    await _selectType(tester, 'Text');

    expect(capturedValue!.type, 'text');
    expect(capturedValue!.value, isNull);
  });

  // --- VAL-CROSS-003 ---

  testWidgets('BcFieldMorph renders BcInput for text type', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'text', value: 'hi'),
      ),
    ));

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('BcFieldMorph renders BcCheckbox for boolean type',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'boolean', value: true),
      ),
    ));

    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('BcFieldMorph renders BcDateField for date type',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldMorph(
        types: _defaultTypes(),
        value: const BcFieldMorphValue(type: 'date', value: '2026-06-23'),
      ),
    ));

    expect(find.text('2026-06-23'), findsOneWidget);
  });
}
