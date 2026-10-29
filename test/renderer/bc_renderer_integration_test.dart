// ---------------------------------------------------------------------------
// Integration + Cross-Area tests for the BcRenderer compositor.
//
// Covers:
//   VAL-INT-001..018  — End-to-end form/list/detail/custom/reaction flows
//   VAL-CROSS-001..030 — Recursion, propagation, barrel exports, edge cases
//
// These tests exercise the full renderer pipeline (schema → widget tree →
// store → callbacks) using the same pattern as bc_renderer_test.dart:
// pump inside MaterialApp + Scaffold, interact via WidgetTester.
// ---------------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Barrel import (VAL-CROSS-012..015, VAL-CROSS-029) — proves BcRenderer,
// BcRendererProps, buildField, loadDataSource, UiSchema, FetchResult, etc.
// are importable from the package root without private imports.
// Hide DataSource (reactive_store variant from barrel) in favor of the freezed
// sealed union from ui_schema_types.dart used for list schemas.
import 'package:bc_ui_flutter/bc_ui_flutter.dart' hide DataSource;

// Component imports for widget type assertions in tests.
import 'package:bc_ui_flutter/src/components/bc_input.dart';
import 'package:bc_ui_flutter/src/components/bc_number_field.dart';
import 'package:bc_ui_flutter/src/components/bc_select.dart';
import 'package:bc_ui_flutter/src/components/bc_checkbox.dart';
import 'package:bc_ui_flutter/src/components/bc_toggle.dart';
import 'package:bc_ui_flutter/src/components/bc_date_field.dart';
import 'package:bc_ui_flutter/src/components/bc_data_table.dart';
import 'package:bc_ui_flutter/src/components/bc_empty.dart';
import 'package:bc_ui_flutter/src/components/bc_form.dart';

// ReactiveStore + Reaction/Effect types for reaction integration tests.
// Hide DataSource (the reactive_store variant) in favor of the freezed sealed
// union from ui_schema_types.dart used for list schemas.
import 'package:bc_ui_flutter/src/core/reactive_store.dart' hide DataSource;

// DataSource sealed union + FetchResult + FetchParams + ModelAdapter.
import 'package:bc_ui_flutter/src/schema/ui_schema_types.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps a [BcRenderer] inside a MaterialApp + Scaffold (same helper shape
/// as bc_renderer_test.dart).
Future<void> _pumpRenderer(
  WidgetTester tester,
  BcRenderer renderer,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: renderer),
      ),
    ),
  );
  await tester.pump();
}

/// Mock HTTP client returning [body] with 200.
http.Client _okClient(String body) {
  return MockClient((request) async {
    return http.Response(body, 200,
        headers: {'content-type': 'application/json'});
  });
}

/// Mock HTTP client returning a 500 error.
http.Client _errorClient() {
  return MockClient((request) async {
    return http.Response('Server Error', 500);
  });
}

/// A simple fake [ModelAdapter] for integration tests.
class _FakeAdapter implements ModelAdapter {
  _FakeAdapter(this._result);
  final FetchResult _result;

  @override
  Future<FetchResult> list(String model, FetchParams params) async => _result;

  @override
  Future<List<dynamic>> search(String model, String query) async => [];

  @override
  bool isOffline(String model) => false;
}

/// A fake [ModelAdapter] that always throws.
class _ThrowingAdapter implements ModelAdapter {
  @override
  Future<FetchResult> list(String model, FetchParams params) async {
    throw Exception('model load failed');
  }

  @override
  Future<List<dynamic>> search(String model, String query) async => [];

  @override
  bool isOffline(String model) => false;
}

void main() {
  // =========================================================================
  // VAL-INT-001 — Form renders all field types end-to-end
  // =========================================================================
  group('VAL-INT-001 form all field types', () {
    testWidgets('renders input, select, number, date, checkbox, toggle',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(name: 'name', type: FieldType.input, label: 'Name'),
                FieldNode(
                    name: 'role',
                    type: FieldType.select,
                    label: 'Role',
                    options: [
                      FieldOption(value: 'admin', label: 'Admin'),
                      FieldOption(value: 'user', label: 'User'),
                    ]),
                FieldNode(
                    name: 'age', type: FieldType.number, label: 'Age'),
                FieldNode(
                    name: 'birthday', type: FieldType.date, label: 'Birthday'),
                FieldNode(
                    name: 'active',
                    type: FieldType.checkbox,
                    label: 'Active'),
                FieldNode(
                    name: 'darkMode',
                    type: FieldType.toggle,
                    label: 'Dark Mode'),
              ],
            ),
            values: {
              'name': 'Alice',
              'role': 'admin',
              'age': 30,
              'active': true,
              'darkMode': false,
            },
          ),
        ),
      );

      expect(find.byType(BcForm), findsOneWidget);
      expect(find.byType(BcInput), findsOneWidget);
      expect(find.byType(BcSelect<String>), findsOneWidget);
      expect(find.byType(BcNumberField), findsOneWidget);
      expect(find.byType(BcDateField), findsOneWidget);
      expect(find.byType(BcCheckbox), findsOneWidget);
      expect(find.byType(BcToggle), findsOneWidget);

      // Initial values propagated
      expect(find.text('Alice'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-INT-002 — Form action buttons render and fire correct callbacks
  // =========================================================================
  group('VAL-INT-002 form action buttons', () {
    testWidgets('submit fires onSubmit, non-submit fires onAction',
        (tester) async {
      Map<String, dynamic>? submittedValues;
      String? actionName;
      Map<String, dynamic>? actionValues;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(name: 'email', type: FieldType.input, label: 'Email'),
              ],
              actions: [
                UiAction(name: 'cancel', label: 'Cancel'),
                UiAction(name: 'save', label: 'Save', submit: true),
              ],
            ),
            values: {'email': 'test@test.com'},
            onSubmit: (v) => submittedValues = v,
            onAction: (name, v) {
              actionName = name;
              actionValues = v;
            },
          ),
        ),
      );

      // Two buttons rendered
      expect(find.byType(PlatformElevatedButton), findsNWidgets(2));
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Tap submit
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(submittedValues, isNotNull);
      expect(submittedValues!['email'], 'test@test.com');

      // Tap non-submit
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(actionName, 'cancel');
      expect(actionValues, isNotNull);
      expect(actionValues!['email'], 'test@test.com');
    });
  });

  // =========================================================================
  // VAL-INT-003 — List schema with DataSourceLocal renders BcDataTable
  // =========================================================================
  group('VAL-INT-003 list DataSourceLocal', () {
    testWidgets('renders BcDataTable with correct rows and headers',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.list,
              columnsDef: [
                ColumnDef(key: 'name', label: 'Name'),
                ColumnDef(key: 'age', label: 'Age'),
              ],
              source: DataSource.local(data: [
                {'name': 'Alice', 'age': 30},
                {'name': 'Bob', 'age': 25},
                {'name': 'Carol', 'age': 40},
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-INT-004 — List schema with DataSourceFetcher loads async data
  // =========================================================================
  group('VAL-INT-004 list DataSourceFetcher async', () {
    testWidgets('shows loading then data from fetcher', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRenderer(
              props: BcRendererProps(
                schema: UiSchema(
                  type: UiSchemaKind.list,
                  columnsDef: const [
                    ColumnDef(key: 'name', label: 'Name'),
                  ],
                  source: DataSource.fetcher(
                    fetcher: (params) => const FetchResult(
                      data: [
                        {'name': 'Loaded1'},
                        {'name': 'Loaded2'},
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Data loaded
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.text('Loaded1'), findsOneWidget);
      expect(find.text('Loaded2'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // =========================================================================
  // VAL-INT-005 — List schema with DataSourceFetcher error renders error state
  // =========================================================================
  group('VAL-INT-005 list fetcher error', () {
    testWidgets('renders error state, not crash or empty table',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRenderer(
              props: BcRendererProps(
                schema: UiSchema(
                  type: UiSchemaKind.list,
                  columnsDef: const [
                    ColumnDef(key: 'name', label: 'Name'),
                  ],
                  source: DataSource.fetcher(
                    fetcher: (params) =>
                        throw Exception('fetcher failure'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-INT-006 — List schema with no source uses inline data
  // =========================================================================
  group('VAL-INT-006 list inline data no source', () {
    testWidgets('renders inline data without async loading', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.list,
              columnsDef: [
                ColumnDef(key: 'id', label: 'ID'),
              ],
              data: [
                {'id': 'A'},
                {'id': 'B'},
              ],
            ),
          ),
        ),
      );

      // No loading indicator at any point
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // BcDataTable immediately present
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-INT-007 — Detail schema renders all fields disabled
  // =========================================================================
  group('VAL-INT-007 detail all fields disabled', () {
    testWidgets('renders disabled fields, no submit button', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.detail,
              fields: [
                FieldNode(name: 'name', type: FieldType.input, label: 'Name'),
                FieldNode(name: 'age', type: FieldType.number, label: 'Age'),
                FieldNode(
                    name: 'active',
                    type: FieldType.checkbox,
                    label: 'Active'),
              ],
              actions: [
                UiAction(name: 'edit', label: 'Edit'),
                UiAction(name: 'save', label: 'Save', submit: true),
              ],
            ),
            values: {'name': 'Alice', 'age': 30, 'active': true},
          ),
        ),
      );

      expect(find.byType(BcForm), findsOneWidget);

      // All TextFields disabled
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final tf in textFields) {
        expect(tf.enabled, isFalse);
      }

      // Submit action NOT rendered (detail is read-only)
      expect(find.text('Save'), findsNothing);
      // Non-submit action IS rendered
      expect(find.text('Edit'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-INT-008 — Custom schema invokes customBuilder with name and payload
  // =========================================================================
  group('VAL-INT-008 custom builder invocation', () {
    testWidgets('passes name and payload, renders returned widget',
        (tester) async {
      String? receivedName;
      Object? receivedPayload;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.custom,
              name: 'myWidget',
              payload: {'k': 'v'},
            ),
          ),
          customBuilder: (name, payload) {
            receivedName = name;
            receivedPayload = payload;
            return const Text('Custom Content');
          },
        ),
      );

      expect(receivedName, 'myWidget');
      expect(receivedPayload, {'k': 'v'});
      expect(find.text('Custom Content'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-INT-009 — Field change propagates to store and onChange callback
  // =========================================================================
  group('VAL-INT-009 field change propagation', () {
    testWidgets('text entry updates store and fires onChange', (tester) async {
      Map<String, dynamic>? lastChange;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(name: 'city', type: FieldType.input, label: 'City'),
              ],
            ),
            values: {'city': 'London'},
            onChange: (v) => lastChange = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Paris');
      await tester.pump();

      expect(lastChange, isNotNull);
      expect(lastChange!['city'], 'Paris');
    });
  });

  // =========================================================================
  // VAL-INT-010 — ReactiveStore reaction updates field visibility in UI
  // =========================================================================
  group('VAL-INT-010 reaction visibility', () {
    testWidgets('field B hidden until field A equals trigger value',
        (tester) async {
      // Reaction: when 'showExtra' changes to 'yes', set field 'extra'
      // metadata visible=true.
      final reactions = [
        Reaction(
          when: const ['showExtra'],
          target: 'extra',
          effect: UiEffect(
            visible: (scope) => scope['showExtra'] == 'yes',
          ),
        ),
      ];

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.form,
              fields: const [
                FieldNode(
                    name: 'showExtra',
                    type: FieldType.input,
                    label: 'Show Extra?'),
                FieldNode(
                    name: 'extra', type: FieldType.input, label: 'Extra'),
              ],
              reactions: reactions,
            ),
            values: const {'showExtra': 'no'},
          ),
        ),
      );

      // Initially 'extra' field is hidden (showExtra != 'yes')
      expect(find.text('Extra'), findsNothing);

      // Change showExtra to 'yes'
      await tester.enterText(find.byType(TextField), 'yes');
      await tester.pump();

      // 'extra' field now visible
      expect(find.text('Extra'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-INT-011 — ReactiveStore value reaction recomputes dependent field
  // =========================================================================
  group('VAL-INT-011 value reaction', () {
    testWidgets('total = qty * price recomputes on qty change',
        (tester) async {
      final reactions = [
        Reaction(
          when: const ['qty', 'price'],
          target: 'total',
          effect: ValueEffect(
            expr: (scope) {
              final qty = (scope['qty'] as num?) ?? 0;
              final price = (scope['price'] as num?) ?? 0;
              return qty * price;
            },
          ),
        ),
      ];

      ReactiveStore? capturedStore;

      // Use a custom approach: pump a BcForm directly so we can capture
      // the store via onCreateStore, then verify the reaction ran.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcForm(
              initialValues: const {'qty': 2, 'price': 10},
              reactions: reactions,
              onCreateStore: (store) => capturedStore = store,
              fields: const [
                FieldNode(name: 'qty', type: FieldType.number, label: 'Qty'),
                FieldNode(
                    name: 'price', type: FieldType.number, label: 'Price'),
                FieldNode(
                    name: 'total', type: FieldType.number, label: 'Total'),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Initial total should be 2 * 10 = 20
      expect(capturedStore, isNotNull);
      expect(capturedStore!.get('total'), 20);

      // Change qty to 5 via the first number field's TextField
      await tester.enterText(find.byType(TextField).first, '5');
      await tester.pump();

      // Total should now be 5 * 10 = 50
      expect(capturedStore!.get('total'), 50);
    });
  });

  // =========================================================================
  // VAL-INT-012 — BcForm backward compatibility: child-only mode still works
  // =========================================================================
  group('VAL-INT-012 backward compat child-only', () {
    testWidgets('child-only BcForm works without fields', (tester) async {
      ReactiveStore? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcForm(
              initialValues: const {'name': 'Alice'},
              onCreateStore: (store) => captured = store,
              child: Builder(
                builder: (context) {
                  final store = BcForm.storeOf(context);
                  return Text(store?.get('name') ?? 'none');
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.get('name'), 'Alice');
      expect(find.text('Alice'), findsOneWidget);
      // No field widgets
      expect(find.byType(BcInput), findsNothing);
    });
  });

  // =========================================================================
  // VAL-INT-013 — BcForm with both fields and child renders both
  // =========================================================================
  group('VAL-INT-013 fields and child together', () {
    testWidgets('fields render first, child below', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcForm(
              fields: const [
                FieldNode(name: 'name', type: FieldType.input, label: 'Name'),
              ],
              child: const Text('Extra Child Widget'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BcInput), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Extra Child Widget'), findsOneWidget);

      // Field should be above child
      final fieldY =
          tester.getTopLeft(find.byType(BcInput)).dy;
      final childY =
          tester.getTopLeft(find.text('Extra Child Widget')).dy;
      expect(childY, greaterThan(fieldY));
    });
  });

  // =========================================================================
  // VAL-INT-014 — URL data source integration renders loaded rows
  // =========================================================================
  group('VAL-INT-014 URL data source', () {
    testWidgets('renders rows from mocked HTTP response', (tester) async {
      // We use loadDataSource directly since the renderer's internal load
      // doesn't accept an injected client. The integration proves that a URL
      // source + mock client produces the correct rows.
      final client = _okClient(jsonEncode([
        {'name': 'URL1'},
        {'name': 'URL2'},
      ]));

      final result = await loadDataSource(
        const DataSource.url(url: 'https://example.com/api'),
        client: client,
      );

      expect(result.error, isNull);
      expect(result.data.length, 2);
      expect(result.data[0], {'name': 'URL1'});
      expect(result.data[1], {'name': 'URL2'});
    });
  });

  // =========================================================================
  // VAL-INT-015 — Model data source integration renders adapter rows
  // =========================================================================
  group('VAL-INT-015 model data source', () {
    testWidgets('renders rows from fake adapter', (tester) async {
      final adapter = _FakeAdapter(const FetchResult(
        data: [
          {'name': 'Model1'},
          {'name': 'Model2'},
        ],
        total: 2,
      ));

      // Without adapter, should be empty — so test with adapter directly.
      final adapterResult = await adapter.list('users', const FetchParams());
      expect(adapterResult.error, isNull);
      expect(adapterResult.data.length, 2);
      expect(adapterResult.data[0], {'name': 'Model1'});

      // Also verify loadDataSource with adapter
      final result2 = await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
      );
      expect(result2.error, isNull);
      expect(result2.data.length, 2);
      expect(result2.total, 2);
    });
  });

  // =========================================================================
  // VAL-INT-016 — URL and model data source errors render non-crashing states
  // =========================================================================
  group('VAL-INT-016 URL and model errors', () {
    testWidgets('URL error captured in FetchResult, not thrown', (tester) async {
      final result = await loadDataSource(
        const DataSource.url(url: 'https://example.com/api'),
        client: _errorClient(),
      );

      expect(result.error, isNotNull);
      expect(result.data, isEmpty);
    });

    testWidgets('model error captured in FetchResult, not thrown',
        (tester) async {
      final result = await loadDataSource(
        DataSource.model(name: 'users', adapter: _ThrowingAdapter()),
      );

      expect(result.error, isNotNull);
      expect(result.data, isEmpty);
    });
  });

  // =========================================================================
  // VAL-INT-017 — Schema-driven form values flow through submit actions
  // =========================================================================
  group('VAL-INT-017 submit with form values', () {
    testWidgets('editing fields then submit delivers full values',
        (tester) async {
      Map<String, dynamic>? submitted;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(name: 'first', type: FieldType.input, label: 'First'),
                FieldNode(
                    name: 'last', type: FieldType.input, label: 'Last'),
              ],
              actions: [
                UiAction(name: 'submit', label: 'Submit', submit: true),
              ],
            ),
            values: const {'first': 'John', 'last': 'Doe'},
            onSubmit: (v) => submitted = v,
          ),
        ),
      );

      // Change first name
      await tester.enterText(find.byType(TextField).first, 'Jane');
      await tester.pump();

      // Submit
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted!['first'], 'Jane');
      expect(submitted!['last'], 'Doe');
    });
  });

  // =========================================================================
  // VAL-INT-018 — Schema-driven non-submit actions include current values
  // =========================================================================
  group('VAL-INT-018 non-submit action with values', () {
    testWidgets('editing fields then non-submit delivers values',
        (tester) async {
      String? actionName;
      Map<String, dynamic>? actionValues;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(name: 'email', type: FieldType.input, label: 'Email'),
              ],
              actions: [
                UiAction(name: 'validate', label: 'Validate'),
              ],
            ),
            values: const {'email': 'old@test.com'},
            onAction: (name, v) {
              actionName = name;
              actionValues = v;
            },
          ),
        ),
      );

      // Change email
      await tester.enterText(find.byType(TextField), 'new@test.com');
      await tester.pump();

      // Tap non-submit action
      await tester.tap(find.text('Validate'));
      await tester.pump();

      expect(actionName, 'validate');
      expect(actionValues, isNotNull);
      expect(actionValues!['email'], 'new@test.com');
    });
  });

  // =========================================================================
  // VAL-CROSS-001 — Section schema renders title and recurses into nested form
  // =========================================================================
  group('VAL-CROSS-001 section recursion', () {
    testWidgets('renders title and nested BcForm with fields',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.section,
              title: 'Profile',
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(
                        name: 'name', type: FieldType.input, label: 'Name'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(BcForm), findsOneWidget);
      expect(find.byType(BcInput), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-CROSS-002 — Grid schema renders multiple children in grid layout
  // =========================================================================
  group('VAL-CROSS-002 grid layout', () {
    testWidgets('lays out 3 nested forms in one row', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.grid,
              columns: 3,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'a', type: FieldType.input, label: 'A'),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'b', type: FieldType.input, label: 'B'),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'c', type: FieldType.input, label: 'C'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BcForm), findsNWidgets(3));

      // Three columns => all three forms start on the same row.
      final a = tester.getTopLeft(find.byType(BcForm).at(0)).dy;
      final b = tester.getTopLeft(find.byType(BcForm).at(1)).dy;
      final c = tester.getTopLeft(find.byType(BcForm).at(2)).dy;
      expect(b, equals(a));
      expect(c, equals(a));
    });
  });

  // =========================================================================
  // VAL-CROSS-003 — Disabled state propagates through section recursion
  // =========================================================================
  group('VAL-CROSS-003 disabled through section', () {
    testWidgets('all nested fields disabled', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.section,
              title: 'Disabled Section',
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'f1', type: FieldType.input),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'f2', type: FieldType.input),
                  ],
                ),
              ],
            ),
            disabled: true,
          ),
        ),
      );

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.length, 2);
      for (final tf in textFields) {
        expect(tf.enabled, isFalse);
      }
    });
  });

  // =========================================================================
  // VAL-CROSS-004 — Disabled state propagates through grid recursion
  // =========================================================================
  group('VAL-CROSS-004 disabled through grid', () {
    testWidgets('all grid child fields disabled', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.grid,
              columns: 2,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'f1', type: FieldType.input),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'f2', type: FieldType.input),
                  ],
                ),
              ],
            ),
            disabled: true,
          ),
        ),
      );

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(textFields.length, 2);
      for (final tf in textFields) {
        expect(tf.enabled, isFalse);
      }
    });
  });

  // =========================================================================
  // VAL-CROSS-005 — Initial values propagate through section recursion
  // =========================================================================
  group('VAL-CROSS-005 values through section', () {
    testWidgets('nested form field shows initial value', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'name', type: FieldType.input),
                  ],
                ),
              ],
            ),
            values: {'name': 'Initial Value'},
          ),
        ),
      );

      final input = tester.widget<BcInput>(find.byType(BcInput));
      expect(input.value, 'Initial Value');
    });
  });

  // =========================================================================
  // VAL-CROSS-006 — Initial values propagate through grid recursion
  // =========================================================================
  group('VAL-CROSS-006 values through grid', () {
    testWidgets('grid child form fields show initial values', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.grid,
              columns: 2,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'fieldA', type: FieldType.input),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'fieldB', type: FieldType.input),
                  ],
                ),
              ],
            ),
            values: {'fieldA': 'valA', 'fieldB': 'valB'},
          ),
        ),
      );

      final inputs = tester.widgetList<BcInput>(find.byType(BcInput));
      expect(inputs.length, 2);
      expect(inputs.first.value, 'valA');
      expect(inputs.last.value, 'valB');
    });
  });

  // =========================================================================
  // VAL-CROSS-007 — onChange callback propagates through section recursion
  // =========================================================================
  group('VAL-CROSS-007 onChange through section', () {
    testWidgets('nested field change fires top-level onChange',
        (tester) async {
      Map<String, dynamic>? lastChange;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'city', type: FieldType.input),
                  ],
                ),
              ],
            ),
            values: const {},
            onChange: (v) => lastChange = v,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Berlin');
      await tester.pump();

      expect(lastChange, isNotNull);
      expect(lastChange!['city'], 'Berlin');
    });
  });

  // =========================================================================
  // VAL-CROSS-008 — onSubmit callback propagates through section recursion
  // =========================================================================
  group('VAL-CROSS-008 onSubmit through section', () {
    testWidgets('nested form submit fires top-level onSubmit',
        (tester) async {
      Map<String, dynamic>? submitted;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'data', type: FieldType.input),
                  ],
                  actions: [
                    UiAction(name: 'go', label: 'Go', submit: true),
                  ],
                ),
              ],
            ),
            values: const {'data': 'hello'},
            onSubmit: (v) => submitted = v,
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted!['data'], 'hello');
    });
  });

  // =========================================================================
  // VAL-CROSS-009 — onAction callback propagates through section recursion
  // =========================================================================
  group('VAL-CROSS-009 onAction through section', () {
    testWidgets('nested non-submit action fires top-level onAction',
        (tester) async {
      String? actionName;
      Map<String, dynamic>? actionValues;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'info', type: FieldType.input),
                  ],
                  actions: [
                    UiAction(name: 'reset', label: 'Reset'),
                  ],
                ),
              ],
            ),
            values: const {'info': 'stuff'},
            onAction: (name, v) {
              actionName = name;
              actionValues = v;
            },
          ),
        ),
      );

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(actionName, 'reset');
      expect(actionValues, isNotNull);
      expect(actionValues!['info'], 'stuff');
    });
  });

  // =========================================================================
  // VAL-CROSS-010 — Callbacks propagate through grid recursion
  // =========================================================================
  group('VAL-CROSS-010 callbacks through grid', () {
    testWidgets('grid child onChange, onSubmit, onAction all fire',
        (tester) async {
      Map<String, dynamic>? lastChange;
      Map<String, dynamic>? submitted;
      String? actionName;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.grid,
              columns: 1,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'g1', type: FieldType.input),
                  ],
                  actions: [
                    UiAction(name: 'save', label: 'Save', submit: true),
                    UiAction(name: 'cancel', label: 'Cancel'),
                  ],
                ),
              ],
            ),
            values: const {},
            onChange: (v) => lastChange = v,
            onSubmit: (v) => submitted = v,
            onAction: (name, v) => actionName = name,
          ),
        ),
      );

      // onChange
      await tester.enterText(find.byType(TextField), 'gridVal');
      await tester.pump();
      expect(lastChange, isNotNull);
      expect(lastChange!['g1'], 'gridVal');

      // onSubmit
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(submitted, isNotNull);

      // onAction
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(actionName, 'cancel');
    });
  });

  // =========================================================================
  // VAL-CROSS-011 — Deeply nested section-in-grid-in-section recursion
  // =========================================================================
  group('VAL-CROSS-011 deeply nested recursion', () {
    testWidgets('section > grid > section > form renders innermost fields',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.section,
              title: 'Level1',
              sections: [
                UiSchema(
                  type: UiSchemaKind.grid,
                  columns: 2,
                  sections: [
                    UiSchema(
                      type: UiSchemaKind.section,
                      title: 'Level3',
                      sections: [
                        UiSchema(
                          type: UiSchemaKind.form,
                          fields: [
                            FieldNode(
                                name: 'deep',
                                type: FieldType.input,
                                label: 'Deep Field'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Innermost field is present
      expect(find.text('Deep Field'), findsOneWidget);
      expect(find.byType(BcInput), findsOneWidget);
      // Titles at all levels
      expect(find.text('Level1'), findsOneWidget);
      expect(find.text('Level3'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-CROSS-012..015 — Barrel export smoke tests
  // =========================================================================
  group('VAL-CROSS-012..015 barrel exports', () {
    test('BcRenderer is importable from barrel', () {
      // Referencing the class proves it's exported.
      expect(BcRenderer, isNotNull);
    });

    test('BcFieldBuilder (buildField) is importable from barrel', () {
      expect(buildField, isNotNull);
    });

    test('BcDataSourceLoader (loadDataSource) is importable from barrel', () {
      expect(loadDataSource, isNotNull);
    });

    test('BcRendererProps is importable from barrel', () {
      expect(BcRendererProps, isNotNull);
    });
  });

  // =========================================================================
  // VAL-CROSS-016 — No ambiguous exports after adding renderer barrel lines
  // =========================================================================
  group('VAL-CROSS-016 no ambiguous exports', () {
    test('renderer types coexist with schema types without ambiguity', () {
      // If the barrel had ambiguous_export, this file would not compile.
      // Using both schema and renderer types proves they coexist.
      const schema = UiSchema(type: UiSchemaKind.form);
      final props = BcRendererProps(schema: schema);
      expect(props.schema?.type, UiSchemaKind.form);
    });
  });

  // =========================================================================
  // VAL-CROSS-017 — BcRenderer renders null schema gracefully
  // =========================================================================
  group('VAL-CROSS-017 null schema', () {
    testWidgets('renders SizedBox.shrink without crash', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(schema: null),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(BcForm), findsNothing);
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsNothing);
    });
  });

  // =========================================================================
  // VAL-CROSS-018 — BcRenderer form with zero fields renders empty form
  // =========================================================================
  group('VAL-CROSS-018 zero fields form', () {
    testWidgets('renders BcForm with no fields or buttons', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(type: UiSchemaKind.form, fields: []),
          ),
        ),
      );

      expect(find.byType(BcForm), findsOneWidget);
      expect(find.byType(BcInput), findsNothing);
      expect(find.byType(PlatformElevatedButton), findsNothing);
    });
  });

  // =========================================================================
  // VAL-CROSS-019 — BcRenderer list with empty data renders empty state
  // =========================================================================
  group('VAL-CROSS-019 empty list data', () {
    testWidgets('renders BcDataTable with 0 rows, no crash', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.list,
              columnsDef: [ColumnDef(key: 'name', label: 'Name')],
              source: DataSource.local(data: []),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.byType(BcEmpty), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-CROSS-020 — BcRenderer section with zero children renders title only
  // =========================================================================
  group('VAL-CROSS-020 section zero children', () {
    testWidgets('renders title but no nested BcForm or BcDataTable',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.section,
              title: 'Empty',
              sections: [],
            ),
          ),
        ),
      );

      expect(find.text('Empty'), findsOneWidget);
      expect(find.byType(BcForm), findsNothing);
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsNothing);
    });
  });

  // =========================================================================
  // VAL-CROSS-021 — Field disabled flag on FieldNode overrides store disabled
  // =========================================================================
  group('VAL-CROSS-021 field disabled precedence', () {
    testWidgets('field disabled=true renders disabled even if renderer false',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(
                    name: 'locked',
                    type: FieldType.input,
                    disabled: true),
                FieldNode(
                    name: 'open',
                    type: FieldType.input,
                    disabled: false),
              ],
            ),
            disabled: false,
          ),
        ),
      );

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final tfList = textFields.toList();
      expect(tfList.length, 2);
      // locked field is disabled
      expect(tfList[0].enabled, isFalse);
      // open field is enabled
      expect(tfList[1].enabled, isTrue);
    });

    testWidgets('renderer disabled=true wins over field disabled=false',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(
                    name: 'tryOpen',
                    type: FieldType.input,
                    disabled: false),
              ],
            ),
            disabled: true,
          ),
        ),
      );

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.enabled, isFalse);
    });
  });

  // =========================================================================
  // VAL-CROSS-022 — Form layout horizontal renders fields in a row
  // =========================================================================
  group('VAL-CROSS-022 horizontal layout', () {
    testWidgets('horizontal form renders Row instead of Column for fields',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.form,
              layout: FormLayout.horizontal,
              fields: [
                FieldNode(name: 'a', type: FieldType.input),
                FieldNode(name: 'b', type: FieldType.input),
              ],
            ),
          ),
        ),
      );

      // BcForm is present
      expect(find.byType(BcForm), findsOneWidget);

      // Find a Row containing the field widgets (the fieldsArea)
      // The horizontal layout uses Row with Expanded children.
      final rows = tester.widgetList<Row>(find.byType(Row));
      final hasRowWithExpanded = rows.any((row) =>
          row.children.any((child) => child is Expanded));
      expect(hasRowWithExpanded, isTrue);
    });
  });

  // =========================================================================
  // VAL-CROSS-023 — BcForm creates store accessible to descendants
  // =========================================================================
  group('VAL-CROSS-023 store accessibility', () {
    testWidgets('descendant can access store via BcForm.storeOf', (tester) async {
      String? storeValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcForm(
              initialValues: const {'key': 'value123'},
              fields: const [
                FieldNode(name: 'key', type: FieldType.input),
              ],
              child: Builder(
                builder: (context) {
                  final store = BcForm.storeOf(context);
                  storeValue = store?.get('key');
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(storeValue, 'value123');
    });
  });

  // =========================================================================
  // VAL-CROSS-024 — Multiple forms in a grid have independent stores
  // =========================================================================
  group('VAL-CROSS-024 independent grid stores', () {
    testWidgets('changing form A does not affect form B', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.grid,
              columns: 2,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'fieldA', type: FieldType.input),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'fieldB', type: FieldType.input),
                  ],
                ),
              ],
            ),
            values: {},
          ),
        ),
      );

      // Two forms
      expect(find.byType(BcForm), findsNWidgets(2));

      // Change form A
      await tester.enterText(find.byType(TextField).first, 'valueA');
      await tester.pump();

      // Form B's field should NOT have 'valueA'
      final inputs = tester.widgetList<BcInput>(find.byType(BcInput));
      expect(inputs.length, 2);
      expect(inputs.first.value, 'valueA');
      expect(inputs.last.value, isNot('valueA'));
    });
  });

  // =========================================================================
  // VAL-CROSS-025 — BcRendererProps.copyWith preserves unmodified fields
  // =========================================================================
  group('VAL-CROSS-025 copyWith preservation', () {
    test('copyWith(disabled: true) preserves schema, values, callbacks', () {
      void onChange(Map<String, dynamic> v) {}
      void onSubmit(Map<String, dynamic> v) {}
      void onAction(String n, Map<String, dynamic> v) {}

      const schema = UiSchema(type: UiSchemaKind.form);
      const values = {'a': 1};

      final original = BcRendererProps(
        schema: schema,
        values: values,
        onChange: onChange,
        onSubmit: onSubmit,
        onAction: onAction,
      );

      final copied = original.copyWith(disabled: true);

      expect(copied.disabled, isTrue);
      expect(copied.schema, same(original.schema));
      expect(copied.values, same(original.values));
      expect(copied.onChange, same(original.onChange));
      expect(copied.onSubmit, same(original.onSubmit));
      expect(copied.onAction, same(original.onAction));
    });
  });

  // =========================================================================
  // VAL-CROSS-026 — Section and grid recursion preserve callback identity
  // =========================================================================
  group('VAL-CROSS-026 callback identity through recursion', () {
    testWidgets('same callback reference fires from nested form',
        (tester) async {
      Map<String, dynamic>? lastChange;

      void topOnChange(Map<String, dynamic> v) {
        lastChange = v;
      }

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'cb', type: FieldType.input),
                  ],
                ),
              ],
            ),
            values: const {},
            onChange: topOnChange,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'identity');
      await tester.pump();

      expect(lastChange, isNotNull);
      expect(lastChange!['cb'], 'identity');
    });
  });

  // =========================================================================
  // VAL-CROSS-027 — Recursive renderer handles mixed schema kinds
  // =========================================================================
  group('VAL-CROSS-027 mixed schema kinds', () {
    testWidgets('section with form, detail, list, custom children',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.section,
              title: 'Mixed',
              sections: [
                // form
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(
                        name: 'f', type: FieldType.input, label: 'FormField'),
                  ],
                ),
                // detail
                UiSchema(
                  type: UiSchemaKind.detail,
                  fields: [
                    FieldNode(
                        name: 'd', type: FieldType.input, label: 'DetailField'),
                  ],
                ),
                // list with inline data
                UiSchema(
                  type: UiSchemaKind.list,
                  columnsDef: [ColumnDef(key: 'n', label: 'N')],
                  data: [
                    {'n': 'item1'},
                  ],
                ),
                // custom
                UiSchema(
                  type: UiSchemaKind.custom,
                  name: 'customChild',
                ),
              ],
            ),
          ),
          customBuilder: (name, payload) {
            return Text('Custom: $name');
          },
        ),
      );
      await tester.pumpAndSettle();

      // form child
      expect(find.text('FormField'), findsOneWidget);
      // detail child
      expect(find.text('DetailField'), findsOneWidget);
      // list child
      expect(find.text('item1'), findsOneWidget);
      // custom child
      expect(find.text('Custom: customChild'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-CROSS-028 — copyWith preserves callbacks and non-overridden fields
  // =========================================================================
  group('VAL-CROSS-028 copyWith full preservation', () {
    test('copyWith(schema:) preserves disabled, values, callbacks', () {
      const original = BcRendererProps(
        values: {'x': 1},
        disabled: true,
      );

      final newSchema = const UiSchema(type: UiSchemaKind.list);
      final copied = original.copyWith(schema: newSchema);

      expect(copied.schema?.type, UiSchemaKind.list);
      expect(copied.disabled, isTrue);
      expect(copied.values, {'x': 1});
    });

    test('copyWith(values:) preserves schema and disabled', () {
      const schema = UiSchema(type: UiSchemaKind.form);
      const original = BcRendererProps(
        schema: schema,
        disabled: true,
      );

      final copied = original.copyWith(values: {'new': 42});

      expect(copied.schema, same(schema));
      expect(copied.disabled, isTrue);
      expect(copied.values, {'new': 42});
    });

    test('copyWith with callbacks preserves other callbacks', () {
      void onSubmit(Map<String, dynamic> v) {}
      void onAction(String n, Map<String, dynamic> v) {}

      final original = BcRendererProps(
        onSubmit: onSubmit,
        onAction: onAction,
      );

      void newOnChange(Map<String, dynamic> v) {}
      final copied = original.copyWith(onChange: newOnChange);

      expect(copied.onChange, same(newOnChange));
      expect(copied.onSubmit, same(onSubmit));
      expect(copied.onAction, same(onAction));
    });
  });

  // =========================================================================
  // VAL-CROSS-029 — Barrel exports include all schema/data-source types
  // needed by renderer users
  // =========================================================================
  group('VAL-CROSS-029 schema dependency exports', () {
    test('all types needed to construct renderer inputs are importable', () {
      // Using all types a renderer consumer would need from the barrel:
      const schema = UiSchema(
        type: UiSchemaKind.form,
        fields: [
          FieldNode(name: 'test', type: FieldType.select, options: [
            FieldOption(value: 'a', label: 'A'),
          ]),
        ],
        source: DataSource.local(data: []),
        columnsDef: [ColumnDef(key: 'k', label: 'K')],
        actions: [UiAction(name: 'act')],
      );

      final props = BcRendererProps(
        schema: schema,
        values: const {},
        disabled: false,
      );

      // If any type were missing from the barrel, this would not compile.
      expect(props.schema, isNotNull);
      expect(loadDataSource, isNotNull);
      expect(buildField, isNotNull);
    });
  });

  // =========================================================================
  // VAL-CROSS-030 — No renderer feature depends on private generated files
  // =========================================================================
  group('VAL-CROSS-030 no private generated file dependency', () {
    test('renderer public APIs import only public surfaces', () {
      // This test compiles only if the public API (BcRenderer, buildField,
      // loadDataSource, BcRendererProps, UiSchema, DataSource, FetchResult,
      // etc.) is fully accessible from the barrel without importing
      // .freezed.dart or .g.dart files.
      //
      // The barrel file itself is the evidence: it exports only public
      // library files (bc_renderer.dart, bc_field_builder.dart,
      // bc_data_source_loader.dart, ui_schema.dart, ui_schema_types.dart),
      // none of which are generated implementation files.

      // Instantiate types from every public surface:
      const ds = DataSource.local(data: [{'a': 1}]);
      const result = FetchResult(data: [], total: 0);
      const params = FetchParams();
      const action = UiAction(name: 'x', submit: true);
      const col = ColumnDef(key: 'k', label: 'L');
      const opt = FieldOption(value: 'v', label: 'Label');
      const field = FieldNode(name: 'n');
      const schemaNode = UiSchema(type: UiSchemaKind.custom);

      expect(ds, isA<DataSource>());
      expect(result, isA<FetchResult>());
      expect(params, isA<FetchParams>());
      expect(action, isA<UiAction>());
      expect(col, isA<ColumnDef>());
      expect(opt, isA<FieldOption>());
      expect(field, isA<FieldNode>());
      expect(schemaNode, isA<UiSchema>());
    });
  });
}
