import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

List<BcDynLinkModel> _defaultModels() => const [
      BcDynLinkModel(model: 'crm.contact', label: 'Contact'),
      BcDynLinkModel(model: 'crm.company', label: 'Company'),
    ];

Widget _harness(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

Future<void> _selectModel(WidgetTester tester, String modelLabel) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(modelLabel).last);
  await tester.pumpAndSettle();
}

void main() {
  // --- VAL-INFRA: typed class tests ---

  test('BcDynLinkModel has model and label', () {
    const m = BcDynLinkModel(model: 'crm.contact', label: 'Contact');
    expect(m.model, 'crm.contact');
    expect(m.label, 'Contact');
  });

  test('BcDynLinkValue has model, id, and display', () {
    const v = BcDynLinkValue(
        model: 'crm.contact', id: '1', display: 'Alice');
    expect(v.model, 'crm.contact');
    expect(v.id, '1');
    expect(v.display, 'Alice');
  });

  test('BcDynLinkRecord has id and label', () {
    const r = BcDynLinkRecord(id: '1', label: 'Alice');
    expect(r.id, '1');
    expect(r.label, 'Alice');
  });

  // --- VAL-DL-001 ---

  testWidgets('BcFieldDynLink renders model dropdown and search input',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(models: _defaultModels()),
    ));

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  // --- VAL-DL-002 ---

  testWidgets('BcFieldDynLink model dropdown lists all model labels',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(models: _defaultModels()),
    ));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Contact'), findsWidgets);
    expect(find.text('Company'), findsWidgets);
  });

  // --- VAL-DL-003 ---

  testWidgets('BcFieldDynLink model change fires modelChange reason',
      (tester) async {
    BcDynLinkValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    await _selectModel(tester, 'Company');

    expect(capturedReason, BcChangeReason.modelChange);
    expect(capturedValue, isNotNull);
    expect(capturedValue!.model, 'crm.company');
    expect(capturedValue!.id, '');
    expect(capturedValue!.display, '');
  });

  // --- VAL-DL-004 ---

  testWidgets('BcFieldDynLink model change resets id and display',
      (tester) async {
    BcDynLinkValue? capturedValue;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '123', display: 'Alice'),
        onValueChange: (v, m) {
          capturedValue = v;
        },
      ),
    ));

    await _selectModel(tester, 'Company');

    expect(capturedValue!.model, 'crm.company');
    expect(capturedValue!.id, '');
    expect(capturedValue!.display, '');
  });

  // --- VAL-DL-005 ---

  testWidgets('BcFieldDynLink search triggers dataFetcher', (tester) async {
    int callCount = 0;
    String lastQuery = '';
    String lastModel = '';

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          callCount++;
          lastModel = model;
          lastQuery = query;
          return const [BcDynLinkRecord(id: '1', label: 'Alice')];
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));

    expect(callCount, greaterThan(0));
    expect(lastModel, 'crm.contact');
    expect(lastQuery, 'ali');
  });

  // --- VAL-DL-006 ---

  testWidgets('BcFieldDynLink search debounces dataFetcher calls',
      (tester) async {
    int callCount = 0;
    String lastQuery = '';

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          callCount++;
          lastQuery = query;
          return const [BcDynLinkRecord(id: '1', label: 'Alice')];
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'al');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();

    expect(callCount, 0);

    await tester.pump(const Duration(milliseconds: 350));

    expect(callCount, 1);
    expect(lastQuery, 'ali');
  });

  // --- VAL-DL-007 ---

  testWidgets('BcFieldDynLink empty search triggers dataFetcher with empty query',
      (tester) async {
    int callCount = 0;
    String lastQuery = 'non-empty';

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          callCount++;
          lastQuery = query;
          return const [];
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));
    expect(callCount, 1);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 350));
    expect(callCount, 2);
    expect(lastQuery, '');
  });

  // --- VAL-DL-008 ---

  testWidgets('BcFieldDynLink no fetch when model not selected',
      (tester) async {
    int callCount = 0;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        dataFetcher: (model, query) async {
          callCount++;
          return const [];
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));

    expect(callCount, 0);
  });

  // --- VAL-DL-009 ---

  testWidgets('BcFieldDynLink loading indicator shows during fetch',
      (tester) async {
    final completer = Completer<List<BcDynLinkRecord>>();

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) => completer.future,
      ),
    ));

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const [BcDynLinkRecord(id: '1', label: 'Alice')]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // --- VAL-DL-010 ---

  testWidgets('BcFieldDynLink select record sets value', (tester) async {
    BcDynLinkValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          return const [BcDynLinkRecord(id: '1', label: 'Alice')];
        },
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(capturedReason, BcChangeReason.select);
    expect(capturedValue!.model, 'crm.contact');
    expect(capturedValue!.id, '1');
    expect(capturedValue!.display, 'Alice');
  });

  // --- VAL-DL-011 ---

  testWidgets('BcFieldDynLink onValueChange value is BcDynLinkValue',
      (tester) async {
    Object? capturedValue;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          return const [BcDynLinkRecord(id: '1', label: 'Alice')];
        },
        onValueChange: (v, m) {
          capturedValue = v;
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(capturedValue, isA<BcDynLinkValue>());
    final val = capturedValue as BcDynLinkValue;
    expect(val.model, 'crm.contact');
    expect(val.id, '1');
    expect(val.display, 'Alice');
  });

  // --- VAL-DL-012 ---

  testWidgets('BcFieldDynLink clear button shown with value', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        value: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        clearable: true,
      ),
    ));

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('BcFieldDynLink clear button hidden without value',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        clearable: true,
      ),
    ));

    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('BcFieldDynLink clear button hidden when clearable false',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        value: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        clearable: false,
      ),
    ));

    expect(find.byIcon(Icons.close), findsNothing);
  });

  // --- VAL-DL-013 ---

  testWidgets('BcFieldDynLink clear button clears value', (tester) async {
    BcDynLinkValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        clearable: true,
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(capturedReason, BcChangeReason.clear);
    expect(capturedValue!.model, '');
    expect(capturedValue!.id, '');
    expect(capturedValue!.display, '');
  });

  // --- VAL-DL-014 ---

  testWidgets('BcFieldDynLink disabled blocks model dropdown',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        disabled: true,
      ),
    ));

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdown.onChanged, isNull);
  });

  // --- VAL-DL-015 ---

  testWidgets('BcFieldDynLink disabled blocks search input',
      (tester) async {
    int callCount = 0;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        disabled: true,
        dataFetcher: (model, query) async {
          callCount++;
          return const [];
        },
      ),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));

    expect(callCount, 0);
  });

  // --- VAL-DL-016 ---

  testWidgets('BcFieldDynLink disabled blocks record selection',
      (tester) async {
    bool called = false;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        disabled: true,
        dataFetcher: (model, query) async {
          return const [BcDynLinkRecord(id: '1', label: 'Alice')];
        },
        onValueChange: (v, m) => called = true,
      ),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);

    expect(called, isFalse);
  });

  // --- VAL-DL-017 ---

  testWidgets('BcFieldDynLink disabled blocks clear button',
      (tester) async {
    bool called = false;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        disabled: true,
        clearable: true,
        onValueChange: (v, m) => called = true,
      ),
    ));

    expect(find.byIcon(Icons.close), findsNothing);

    expect(called, isFalse);
  });

  // --- VAL-DL-018 ---

  testWidgets('BcFieldDynLink readonly blocks model dropdown',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        readonly: true,
      ),
    ));

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdown.onChanged, isNull);
  });

  // --- VAL-DL-019 ---

  testWidgets('BcFieldDynLink readonly blocks search but shows display',
      (tester) async {
    int callCount = 0;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        readonly: true,
        dataFetcher: (model, query) async {
          callCount++;
          return const [];
        },
      ),
    ));

    expect(find.text('Alice'), findsOneWidget);

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.readOnly, isTrue);

    await tester.enterText(find.byType(TextField), 'Bob');
    await tester.pump(const Duration(milliseconds: 350));

    expect(callCount, 0);
  });

  // --- VAL-DL-020 ---

  testWidgets('BcFieldDynLink readonly blocks clear button',
      (tester) async {
    bool called = false;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        readonly: true,
        clearable: true,
        onValueChange: (v, m) => called = true,
      ),
    ));

    expect(find.byIcon(Icons.close), findsNothing);

    expect(called, isFalse);
  });

  // --- VAL-DL-021 ---

  testWidgets('BcFieldDynLink controlled value drives model and display',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        value: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
      ),
    ));

    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        value: const BcDynLinkValue(
            model: 'crm.company', id: '2', display: 'Bob Corp'),
      ),
    ));

    expect(find.text('Company'), findsOneWidget);
    expect(find.text('Bob Corp'), findsOneWidget);
  });

  // --- VAL-DL-022 ---

  testWidgets('BcFieldDynLink defaultValue initializes uncontrolled state',
      (tester) async {
    BcDynLinkValue? capturedValue;
    BcChangeReason? capturedReason;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        dataFetcher: (model, query) async {
          return const [BcDynLinkRecord(id: '1', label: 'Alice')];
        },
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alice').last);
    await tester.pumpAndSettle();

    expect(capturedReason, BcChangeReason.select);
    expect(capturedValue!.id, '1');
    expect(capturedValue!.display, 'Alice');
  });

  // --- VAL-DL-023 ---

  testWidgets('BcFieldDynLink empty state when no results', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          return const [];
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // --- VAL-DL-024 ---

  testWidgets('BcFieldDynLink renders label hint description', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        label: 'Link to record',
        hint: 'Pick a model then search for a record',
        description: 'Creates a dynamic link to a record in the selected model',
      ),
    ));

    expect(find.text('Link to record'), findsOneWidget);
    expect(find.text('Pick a model then search for a record'), findsOneWidget);
    expect(
        find.text(
            'Creates a dynamic link to a record in the selected model'),
        findsOneWidget);
  });

  // --- VAL-DL-025 ---

  testWidgets('BcFieldDynLink placeholder renders when no value',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        placeholder: 'Search records...',
      ),
    ));

    expect(find.text('Search records...'), findsOneWidget);
  });

  // --- VAL-DL-026 ---

  testWidgets('BcFieldDynLink required shows indicator', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        label: 'Field',
        required_: true,
      ),
    ));

    expect(find.text('*'), findsOneWidget);
  });

  testWidgets('BcFieldDynLink not required hides indicator',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        label: 'Field',
        required_: false,
      ),
    ));

    expect(find.text('*'), findsNothing);
  });

  // --- VAL-DL-027 ---

  testWidgets('BcFieldDynLink tap sets source to pointer', (tester) async {
    BcEventSource? modelChangeSource;
    BcEventSource? selectSource;
    BcEventSource? clearSource;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        clearable: true,
        dataFetcher: (model, query) async {
          return const [BcDynLinkRecord(id: '1', label: 'Alice')];
        },
        onValueChange: (v, m) {
          if (m.reason == BcChangeReason.modelChange) {
            modelChangeSource = m.source;
          } else if (m.reason == BcChangeReason.select) {
            selectSource = m.source;
          } else if (m.reason == BcChangeReason.clear) {
            clearSource = m.source;
          }
        },
      ),
    ));

    await _selectModel(tester, 'Company');
    expect(modelChangeSource, BcEventSource.pointer);

    await _selectModel(tester, 'Contact');
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();
    expect(selectSource, BcEventSource.pointer);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(clearSource, BcEventSource.pointer);
  });

  // --- VAL-DL-028 ---

  testWidgets('BcFieldDynLink dataFetcher error does not crash',
      (tester) async {
    bool called = false;

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          throw Exception('Network error');
        },
        onValueChange: (v, m) => called = true,
      ),
    ));

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(called, isFalse);

    expect(tester.takeException(), isNull);
  });

  // --- VAL-DL-029 ---

  testWidgets('BcFieldDynLink reset clears without firing onValueChange',
      (tester) async {
    bool called = false;
    final key = GlobalKey<BcFieldDynLinkState>();

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        key: key,
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        onValueChange: (v, m) => called = true,
      ),
    ));

    key.currentState!.reset();
    await tester.pump();

    expect(called, isFalse);
    expect(key.currentState!.currentValue.model, '');
    expect(key.currentState!.currentValue.id, '');
    expect(key.currentState!.currentValue.display, '');
  });

  // --- VAL-DL-030 ---

  testWidgets('BcFieldDynLink clear method fires clear reason',
      (tester) async {
    BcDynLinkValue? capturedValue;
    BcChangeReason? capturedReason;
    final key = GlobalKey<BcFieldDynLinkState>();

    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        key: key,
        models: _defaultModels(),
        defaultValue: const BcDynLinkValue(
            model: 'crm.contact', id: '1', display: 'Alice'),
        onValueChange: (v, m) {
          capturedValue = v;
          capturedReason = m.reason;
        },
      ),
    ));

    key.currentState!.clear();
    await tester.pump();

    expect(capturedReason, BcChangeReason.clear);
    expect(capturedValue!.model, '');
    expect(capturedValue!.id, '');
    expect(capturedValue!.display, '');
  });

  // --- VAL-DL-031 ---

  testWidgets('BcFieldDynLink exposes combobox semantics', (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(models: _defaultModels()),
    ));

    expect(
      find.bySemanticsLabel('Dynamic Link'),
      findsOneWidget,
    );
  });

  // --- VAL-DL-032 ---

  testWidgets('BcFieldDynLink search results render record labels',
      (tester) async {
    await tester.pumpWidget(_harness(
      BcFieldDynLink(
        models: _defaultModels(),
        defaultValue:
            const BcDynLinkValue(model: 'crm.contact', id: '', display: ''),
        dataFetcher: (model, query) async {
          return const [
            BcDynLinkRecord(id: '1', label: 'Alice'),
            BcDynLinkRecord(id: '2', label: 'Bob'),
          ];
        },
      ),
    ));

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });
}
