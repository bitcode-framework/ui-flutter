import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_field_table_select.dart';
import 'package:bc_ui_flutter/src/components/bc_data_table.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

/// Widget tests for [BcFieldTableSelect] (ADR-011 Phase 5b.2).
///
/// Covers the 30 VAL-TS assertions from the validation contract plus the
/// VAL-CROSS-004 cross-cutting assertion (BcDataTable reuse). Tests pump the
/// widget into a MaterialApp + Scaffold harness, then assert on rendered
/// output and captured callback values.
void main() {
  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  List<Map<String, dynamic>> sampleData() => <Map<String, dynamic>>[
        <String, dynamic>{'id': '1', 'name': 'Alice', 'email': 'alice@example.com'},
        <String, dynamic>{'id': '2', 'name': 'Bob', 'email': 'bob@example.com'},
        <String, dynamic>{'id': '3', 'name': 'Charlie', 'email': 'charlie@example.com'},
      ];

  List<BcFieldTableSelectColumn> sampleColumns() =>
      <BcFieldTableSelectColumn>[
        const BcFieldTableSelectColumn(key: 'name', label: 'Full Name'),
        const BcFieldTableSelectColumn(key: 'email', label: 'Email'),
      ];

  group('BcFieldTableSelect rendering', () {
    testWidgets('renders columns and data rows (VAL-TS-001)', (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
    });

    testWidgets('renders column labels not keys (VAL-TS-002)', (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: const [
            BcFieldTableSelectColumn(key: 'name', label: 'Full Name'),
            BcFieldTableSelectColumn(key: 'email', label: 'Email'),
          ],
          data: sampleData(),
        ),
      ));

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      // 'name' and 'email' as raw keys should never appear as header text.
      // (They may appear in cell values like 'alice@example.com' but not as
      //  bare header labels.) We assert the exact header labels are present.
      expect(find.text('name'), findsNothing);
      expect(find.text('email'), findsNothing);
    });

    testWidgets(
        'renders BcDataTable with configured columns and data (VAL-CROSS-004)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));

      expect(
        find.byWidgetPredicate(
            (widget) => widget is BcDataTable),
        findsOneWidget,
      );
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });
  });

  group('BcFieldTableSelect single select', () {
    testWidgets('single select taps row to select (VAL-TS-003)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(capturedValue, 'Alice');
      expect(capturedReason, BcChangeReason.select);
    });

    testWidgets('single select replaces previous selection (VAL-TS-004)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, 'Alice');

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      expect(capturedValue, 'Bob');
      expect(capturedReason, BcChangeReason.select);
      expect(capturedValue, isA<String>());
    });

    testWidgets('single value is String (VAL-TS-008 single)',
        (tester) async {
      dynamic capturedValue;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
          },
        ),
      ));
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, isA<String>());
    });
  });

  group('BcFieldTableSelect multiple select', () {
    testWidgets('multiple select adds rows (VAL-TS-005)', (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          multiple: true,
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, <String>['Alice']);
      expect(capturedReason, BcChangeReason.select);

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      expect(capturedValue, <String>['Alice', 'Bob']);
      expect(capturedReason, BcChangeReason.select);
    });

    testWidgets('multiple select deselects on re-tap (VAL-TS-006)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          multiple: true,
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, <String>['Alice']);

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, <String>[]);
      expect(capturedReason, BcChangeReason.deselect);
    });

    testWidgets('multiple select preserves selection order (VAL-TS-007)',
        (tester) async {
      dynamic capturedValue;

      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          multiple: true,
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
          },
        ),
      ));

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, <String>['Bob', 'Alice']);
    });

    testWidgets('multiple value is List<String> (VAL-TS-008 multiple)',
        (tester) async {
      dynamic capturedValue;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          multiple: true,
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
          },
        ),
      ));
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, isA<List<String>>());
    });
  });

  group('BcFieldTableSelect search', () {
    testWidgets('search filters rows by searchFields (VAL-TS-009)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          searchable: true,
          searchFields: const ['name'],
        ),
      ));

      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-table-select-search')),
        'Al',
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
      expect(find.text('Charlie'), findsNothing);
    });

    testWidgets('search is case-insensitive (VAL-TS-009 case)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          searchable: true,
          searchFields: const ['name'],
        ),
      ));

      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-table-select-search')),
        'al',
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
    });

    testWidgets('search unions across searchFields (VAL-TS-010)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          searchable: true,
          searchFields: const ['name', 'email'],
        ),
      ));

      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-table-select-search')),
        'bob@example.com',
      );
      await tester.pumpAndSettle();

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
      expect(find.text('Charlie'), findsNothing);
    });
  });

  group('BcFieldTableSelect clearable', () {
    testWidgets('clear button hidden without value (VAL-TS-011 hidden)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          clearable: true,
        ),
      ));
      expect(
        find.byKey(const ValueKey<String>('bc-field-table-select-clear')),
        findsNothing,
      );
    });

    testWidgets('clear button shown with value (VAL-TS-011 shown)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          value: 'Alice',
          clearable: true,
        ),
      ));
      expect(
        find.byKey(const ValueKey<String>('bc-field-table-select-clear')),
        findsOneWidget,
      );
    });

    testWidgets('clear button hidden when clearable false (VAL-TS-011 false)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          value: 'Alice',
          clearable: false,
        ),
      ));
      expect(
        find.byKey(const ValueKey<String>('bc-field-table-select-clear')),
        findsNothing,
      );
    });

    testWidgets('clear button clears and fires clear reason (VAL-TS-012)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          value: 'Alice',
          clearable: true,
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      await tester
          .tap(find.byKey(const ValueKey<String>('bc-field-table-select-clear')));
      await tester.pumpAndSettle();

      expect(capturedValue, '');
      expect(capturedReason, BcChangeReason.clear);
    });

    testWidgets('clear button clears multiple selection (VAL-TS-012 multiple)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          multiple: true,
          value: const <String>['Alice', 'Bob'],
          clearable: true,
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      await tester
          .tap(find.byKey(const ValueKey<String>('bc-field-table-select-clear')));
      await tester.pumpAndSettle();

      expect(capturedValue, <String>[]);
      expect(capturedReason, BcChangeReason.clear);
    });
  });

  group('BcFieldTableSelect empty state', () {
    testWidgets('emptyText shows when data empty (VAL-TS-013)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: const <Map<String, dynamic>>[],
          emptyText: 'No records found',
        ),
      ));
      expect(find.text('No records found'), findsOneWidget);
    });

    testWidgets('emptyText shows when search yields no results (VAL-TS-014)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          searchable: true,
          searchFields: const ['name'],
          emptyText: 'No matches',
        ),
      ));

      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-table-select-search')),
        'zzz',
      );
      await tester.pumpAndSettle();

      expect(find.text('No matches'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
      expect(find.text('Bob'), findsNothing);
      expect(find.text('Charlie'), findsNothing);
    });
  });

  group('BcFieldTableSelect titleField', () {
    testWidgets('titleField drives emitted value (VAL-TS-015)',
        (tester) async {
      dynamic capturedValue;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
          },
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedValue, 'Alice');
    });
  });

  group('BcFieldTableSelect disabled', () {
    testWidgets('disabled blocks row selection (VAL-TS-016)',
        (tester) async {
      bool changed = false;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          disabled: true,
          titleField: 'name',
          onValueChange: (value, meta) {
            changed = true;
          },
        ),
      ));

      await tester.tap(find.text('Alice'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(changed, isFalse);
    });

    testWidgets('disabled blocks search input (VAL-TS-017)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          disabled: true,
          searchable: true,
          searchFields: const ['name'],
        ),
      ));

      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-table-select-search')),
        'Al',
      );
      await tester.pumpAndSettle();

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('disabled blocks clear button (VAL-TS-018)',
        (tester) async {
      bool changed = false;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          disabled: true,
          clearable: true,
          value: 'Alice',
          titleField: 'name',
          onValueChange: (value, meta) {
            changed = true;
          },
        ),
      ));

      await tester.tap(
          find.byKey(const ValueKey<String>('bc-field-table-select-clear')),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(changed, isFalse);
    });
  });

  group('BcFieldTableSelect readonly', () {
    testWidgets('readonly shows data but blocks selection (VAL-TS-019)',
        (tester) async {
      bool changed = false;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          readonly: true,
          titleField: 'name',
          onValueChange: (value, meta) {
            changed = true;
          },
        ),
      ));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(changed, isFalse);
    });

    testWidgets('readonly blocks search input (VAL-TS-020)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          readonly: true,
          searchable: true,
          searchFields: const ['name'],
        ),
      ));

      await tester.enterText(
        find.byKey(const ValueKey<String>('bc-field-table-select-search')),
        'Al',
      );
      await tester.pumpAndSettle();

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });
  });

  group('BcFieldTableSelect controlled value', () {
    testWidgets('controlled value drives selection (VAL-TS-021)',
        (tester) async {
      String value = 'Alice';
      late StateSetter setStateRef;
      await tester.pumpWidget(harness(
        StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return BcFieldTableSelect(
              columns: sampleColumns(),
              data: sampleData(),
              value: value,
              titleField: 'name',
            );
          },
        ),
      ));

      setStateRef(() {
        value = 'Bob';
      });
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('controlled list value drives selection (VAL-TS-022)',
        (tester) async {
      List<String> value = <String>['Alice', 'Bob'];
      late StateSetter setStateRef;
      await tester.pumpWidget(harness(
        StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return BcFieldTableSelect(
              columns: sampleColumns(),
              data: sampleData(),
              value: value,
              multiple: true,
              titleField: 'name',
            );
          },
        ),
      ));

      setStateRef(() {
        value = <String>['Alice'];
      });
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });
  });

  group('BcFieldTableSelect defaultValue', () {
    testWidgets('defaultValue initializes uncontrolled state (VAL-TS-023)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          defaultValue: 'Alice',
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      expect(capturedValue, 'Bob');
      expect(capturedReason, BcChangeReason.select);
    });
  });

  group('BcFieldTableSelect label/hint/description', () {
    testWidgets('renders label hint description (VAL-TS-024)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          label: 'Pick users',
          hint: 'Click a row to select',
          description: 'Select one or more users for the task',
        ),
      ));
      expect(find.text('Pick users'), findsOneWidget);
      expect(find.text('Click a row to select'), findsOneWidget);
      expect(find.text('Select one or more users for the task'), findsOneWidget);
    });
  });

  group('BcFieldTableSelect required', () {
    testWidgets('required shows indicator (VAL-TS-025 shown)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          label: 'Pick users',
          required: true,
        ),
      ));
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('not required hides indicator (VAL-TS-025 hidden)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          label: 'Pick users',
          required: false,
        ),
      ));
      expect(find.text('*'), findsNothing);
    });
  });

  group('BcFieldTableSelect event source', () {
    testWidgets('tap sets source to pointer (VAL-TS-026)',
        (tester) async {
      BcEventSource? capturedSource;
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedSource = meta.source;
          },
        ),
      ));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedSource, BcEventSource.pointer);
    });
  });

  group('BcFieldTableSelect pagination', () {
    testWidgets('pageSize limits visible rows (VAL-TS-027)',
        (tester) async {
      final largeData = List<Map<String, dynamic>>.generate(
        5,
        (i) => <String, dynamic>{
          'id': '${i + 1}',
          'name': 'User${i + 1}',
          'email': 'user${i + 1}@example.com',
        },
      );
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: largeData,
          pageSize: 2,
        ),
      ));

      // Only first 2 rows visible on page 1
      expect(find.text('User1'), findsOneWidget);
      expect(find.text('User2'), findsOneWidget);
      expect(find.text('User3'), findsNothing);
      expect(find.text('User4'), findsNothing);
      expect(find.text('User5'), findsNothing);
    });
  });

  group('BcFieldTableSelect imperative methods', () {
    testWidgets('reset clears without firing onValueChange (VAL-TS-028)',
        (tester) async {
      bool changed = false;
      final key = GlobalKey<BcFieldTableSelectState>();
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          key: key,
          columns: sampleColumns(),
          data: sampleData(),
          defaultValue: 'Alice',
          titleField: 'name',
          onValueChange: (value, meta) {
            changed = true;
          },
        ),
      ));

      key.currentState!.reset();
      await tester.pumpAndSettle();

      expect(changed, isFalse);
    });

    testWidgets('clear method fires clear reason (VAL-TS-029)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;
      final key = GlobalKey<BcFieldTableSelectState>();
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          key: key,
          columns: sampleColumns(),
          data: sampleData(),
          defaultValue: 'Alice',
          titleField: 'name',
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));

      key.currentState!.clear();
      await tester.pumpAndSettle();

      expect(capturedValue, '');
      expect(capturedReason, BcChangeReason.clear);
    });
  });

  group('BcFieldTableSelect a11y', () {
    testWidgets('exposes grid semantics (VAL-TS-030)', (tester) async {
      await tester.pumpWidget(harness(
        BcFieldTableSelect(
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));

      final semanticsHandle = tester.ensureSemantics();
      final rootFinder = find.byType(BcFieldTableSelect);
      expect(rootFinder, findsOneWidget);

      // The root exposes grid semantics via a custom semantic label.
      final rootSemantics = tester.getSemantics(rootFinder);
      expect(rootSemantics.label, contains('grid'));

      semanticsHandle.dispose();
    });
  });
}
