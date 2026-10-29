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

/// JSON-payload contract at the field-builder seam.
///
/// `ReactiveStore.get()` returns `dynamic`, and the values reaching the
/// renderer come from JSON documents (or a host app's initial-values map),
/// not from Dart natives. A field builder must therefore coerce, never
/// hard-cast.
///
/// Before the fix, every case below threw a TypeError, e.g.
/// `"2026-06-18": type 'String' is not a subtype of type 'DateTime?'`,
/// which surfaced in the demo as a red error block in Block Catalog.
Future<void> _pumpField(
  WidgetTester tester,
  FieldNode node,
  Map<String, dynamic> values,
) async {
  final store = ReactiveStore(ReactiveStoreOptions(initialValues: values));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: buildField(node, store)),
    ),
  );
  await tester.pump();
}

void main() {
  group('date field accepts JSON date strings', () {
    testWidgets('ISO date string parses', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'd', type: FieldType.date),
        {'d': '2026-06-18'},
      );

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value, DateTime(2026, 6, 18));
    });

    testWidgets('full ISO-8601 timestamp parses', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'd', type: FieldType.date),
        {'d': '2026-06-18T09:30:00Z'},
      );

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value?.toUtc(), DateTime.utc(2026, 6, 18, 9, 30));
    });

    testWidgets('native DateTime passes through', (tester) async {
      final date = DateTime(2026, 1, 2);
      await _pumpField(
        tester,
        const FieldNode(name: 'd', type: FieldType.date),
        {'d': date},
      );

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value, date);
    });

    testWidgets('unparseable string yields null instead of throwing',
        (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'd', type: FieldType.date),
        {'d': 'not-a-date'},
      );

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value, isNull);
    });

    testWidgets('empty string yields null', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'd', type: FieldType.date),
        {'d': ''},
      );

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value, isNull);
    });

    testWidgets('epoch millis int coerces', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'd', type: FieldType.date),
        {'d': DateTime.utc(2026, 3, 4).millisecondsSinceEpoch},
      );

      final widget = tester.widget<BcDateField>(find.byType(BcDateField));
      expect(widget.value?.toUtc(), DateTime.utc(2026, 3, 4));
    });
  });

  group('number field accepts JSON numeric strings', () {
    testWidgets('numeric string parses', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'n', type: FieldType.number),
        {'n': '42.5'},
      );

      final widget = tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.value, 42.5);
    });

    testWidgets('int passes through', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'n', type: FieldType.number),
        {'n': 7},
      );

      final widget = tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.value, 7);
    });

    testWidgets('non-numeric string yields null instead of throwing',
        (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'n', type: FieldType.number),
        {'n': 'abc'},
      );

      final widget = tester.widget<BcNumberField>(find.byType(BcNumberField));
      expect(widget.value, isNull);
    });
  });

  group('boolean fields accept JSON truthiness', () {
    testWidgets('toggle accepts "true"', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 't', type: FieldType.toggle),
        {'t': 'true'},
      );

      final widget = tester.widget<BcToggle>(find.byType(BcToggle));
      expect(widget.value, isTrue);
    });

    testWidgets('toggle accepts "false"', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 't', type: FieldType.toggle),
        {'t': 'false'},
      );

      final widget = tester.widget<BcToggle>(find.byType(BcToggle));
      expect(widget.value, isFalse);
    });

    testWidgets('toggle accepts 1', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 't', type: FieldType.toggle),
        {'t': 1},
      );

      final widget = tester.widget<BcToggle>(find.byType(BcToggle));
      expect(widget.value, isTrue);
    });

    testWidgets('checkbox accepts 0', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'c', type: FieldType.checkbox),
        {'c': 0},
      );

      final widget = tester.widget<BcCheckbox>(find.byType(BcCheckbox));
      expect(widget.value, isFalse);
    });

    testWidgets('checkbox accepts bool', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 'c', type: FieldType.checkbox),
        {'c': true},
      );

      final widget = tester.widget<BcCheckbox>(find.byType(BcCheckbox));
      expect(widget.value, isTrue);
    });
  });

  group('text fields accept non-string JSON scalars', () {
    testWidgets('input stringifies int', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 's', type: FieldType.input),
        {'s': 42},
      );

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.value, '42');
    });

    testWidgets('input stringifies double', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(name: 's', type: FieldType.input),
        {'s': 1.5},
      );

      final widget = tester.widget<BcInput>(find.byType(BcInput));
      expect(widget.value, '1.5');
    });

    testWidgets('select stringifies int', (tester) async {
      await _pumpField(
        tester,
        const FieldNode(
          name: 'sel',
          type: FieldType.select,
          options: [
            FieldOption(value: '1', label: 'One'),
            FieldOption(value: '3', label: 'Three'),
          ],
        ),
        {'sel': 3},
      );

      final widget =
          tester.widget<BcSelect<String>>(find.byType(BcSelect<String>));
      expect(widget.value, '3');
    });
  });

  group('coercion is read-only', () {
    testWidgets('store keeps the original JSON value', (tester) async {
      final store =
          ReactiveStore(ReactiveStoreOptions(initialValues: {'d': '2026-06-18'}));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildField(
              const FieldNode(name: 'd', type: FieldType.date),
              store,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(store.get('d'), '2026-06-18');
    });
  });
}
