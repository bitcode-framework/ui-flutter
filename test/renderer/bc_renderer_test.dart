import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/src/components/bc_data_table.dart';
import 'package:bc_ui_flutter/src/components/bc_empty.dart';
import 'package:bc_ui_flutter/src/components/bc_form.dart';
import 'package:bc_ui_flutter/src/components/bc_input.dart';
import 'package:bc_ui_flutter/src/renderer/bc_renderer.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema_types.dart';

// ---------------------------------------------------------------------------
// Helper: pump BcRenderer inside a MaterialApp + Scaffold.
// ---------------------------------------------------------------------------

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

void main() {
  // =========================================================================
  // VAL-RENDER-001 — Form kind renders BcForm with fields
  // =========================================================================
  group('VAL-RENDER-001 form kind', () {
    testWidgets('renders BcForm with fields and values', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(name: 'name', type: FieldType.input, label: 'Name'),
              ],
            ),
            values: {'name': 'Alice'},
          ),
        ),
      );

      expect(find.byType(BcForm), findsOneWidget);
      expect(find.byType(BcInput), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-RENDER-002 — Form kind shows title and description
  // =========================================================================
  group('VAL-RENDER-002 form title/description', () {
    testWidgets('renders title and description above fields', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              title: 'User Profile',
              description: 'Edit your personal information',
              fields: [FieldNode(name: 'name', label: 'Name')],
            ),
          ),
        ),
      );

      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Edit your personal information'), findsOneWidget);

      final titleRect = tester.getTopLeft(find.text('User Profile'));
      final descRect =
          tester.getTopLeft(find.text('Edit your personal information'));
      final fieldRect = tester.getTopLeft(find.text('Name'));
      expect(descRect.dy, greaterThan(titleRect.dy));
      expect(fieldRect.dy, greaterThan(descRect.dy));
    });

    testWidgets('null title and description render neither', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [FieldNode(name: 'name')],
            ),
          ),
        ),
      );

      // No title/desc text (only the field label if any)
      expect(find.byType(BcForm), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-RENDER-003 — Detail kind renders disabled form
  // =========================================================================
  group('VAL-RENDER-003 detail kind', () {
    testWidgets('renders disabled form with fields', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.detail,
              title: 'Order Details',
              fields: [
                FieldNode(name: 'order_id', type: FieldType.input),
              ],
              actions: [
                UiAction(name: 'save', label: 'Save', submit: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BcForm), findsOneWidget);
      // Fields should be disabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
      // Title should be visible
      expect(find.text('Order Details'), findsOneWidget);
    });

    testWidgets('detail does not fire onSubmit when tapping submit action',
        (tester) async {
      Map<String, dynamic>? submitted;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.detail,
              fields: [FieldNode(name: 'f')],
              actions: [
                UiAction(name: 'go', label: 'Go', submit: true),
              ],
            ),
            onSubmit: (v) => submitted = v,
          ),
        ),
      );

      // Submit actions should be filtered out for detail kind
      expect(find.text('Go'), findsNothing);
      expect(submitted, isNull);
    });
  });

  // =========================================================================
  // VAL-RENDER-004 — List kind renders BcDataTable with inline data
  // =========================================================================
  group('VAL-RENDER-004 list inline data', () {
    testWidgets('renders BcDataTable with columns and rows', (tester) async {
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
              data: [
                {'name': 'Alice', 'age': 30},
                {'name': 'Bob', 'age': 25},
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // =========================================================================
  // VAL-RENDER-005 — List kind with DataSource shows loading then data
  // =========================================================================
  group('VAL-RENDER-005 list with datasource', () {
    testWidgets('shows loading then data from DataSource.local',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.list,
              columnsDef: [
                ColumnDef(key: 'name', label: 'Name'),
              ],
              source: DataSource.local(data: [
                {'name': 'X'},
              ]),
            ),
          ),
        ),
      );

      // After pumping, the async load should have completed.
      await tester.pumpAndSettle();

      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially with fetcher source',
        (tester) async {
      // Pump widget without the extra pump() so microtasks haven't flushed.
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
                        {'name': 'Y'},
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Initially loading — the fetcher's microtask hasn't completed yet.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // After loading completes, data is shown
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // =========================================================================
  // VAL-RENDER-006 — List kind with DataSource error shows error state
  // =========================================================================
  group('VAL-RENDER-006 list error state', () {
    testWidgets('shows error state on fetcher error', (tester) async {
      // Pump widget without the extra pump() so microtasks haven't flushed.
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
                    fetcher: (params) => throw Exception('Network failure'),
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

      // After error, error state is shown
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows error state on FetchResult with error', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: UiSchema(
              type: UiSchemaKind.list,
              columnsDef: const [
                ColumnDef(key: 'name', label: 'Name'),
              ],
              source: DataSource.fetcher(
                fetcher: (params) =>
                    const FetchResult(error: 'load failed'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-RENDER-007 — List kind shows title and description
  // =========================================================================
  group('VAL-RENDER-007 list title/description', () {
    testWidgets('renders title and description above table', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.list,
              title: 'Contacts',
              description: 'All registered contacts',
              columnsDef: [ColumnDef(key: 'name', label: 'Name')],
              data: [
                {'name': 'Alice'},
              ],
            ),
          ),
        ),
      );

      expect(find.text('Contacts'), findsOneWidget);
      expect(find.text('All registered contacts'), findsOneWidget);

      final titleRect = tester.getTopLeft(find.text('Contacts'));
      final tableRect = tester.getTopLeft(find.byType(BcDataTable<Map<String, dynamic>>));
      expect(tableRect.dy, greaterThan(titleRect.dy));
    });

    testWidgets('null title/description renders neither', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.list,
              columnsDef: [ColumnDef(key: 'name', label: 'Name')],
              data: [],
            ),
          ),
        ),
      );

      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-RENDER-008 — Section kind renders Column with nested BcRenderer
  // =========================================================================
  group('VAL-RENDER-008 section kind', () {
    testWidgets('renders Column with nested BcRenderer children',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'a', label: 'FieldA')],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'b', label: 'FieldB')],
                ),
              ],
            ),
          ),
        ),
      );

      // Multiple BcRenderer widgets: parent + 2 children
      expect(find.byType(BcRenderer), findsNWidgets(3));
      // Both child form fields are visible
      expect(find.text('FieldA'), findsOneWidget);
      expect(find.text('FieldB'), findsOneWidget);
      // A Column contains the nested renderers
      expect(find.byType(Column), findsWidgets);
    });
  });

  // =========================================================================
  // VAL-RENDER-009 — Section kind shows title and description
  // =========================================================================
  group('VAL-RENDER-009 section title/description', () {
    testWidgets('renders title and description above children',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              title: 'Address Section',
              description: 'Mailing address details',
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'street', label: 'Street')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Address Section'), findsOneWidget);
      expect(find.text('Mailing address details'), findsOneWidget);

      final titleRect = tester.getTopLeft(find.text('Address Section'));
      final fieldRect = tester.getTopLeft(find.text('Street'));
      expect(fieldRect.dy, greaterThan(titleRect.dy));
    });

    testWidgets('null title/description still renders children',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'f', label: 'F')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('F'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-RENDER-010 — Grid kind lays children out in `columns` columns
  // =========================================================================
  group('VAL-RENDER-010 grid kind', () {
    testWidgets('lays children out in 3 columns', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.grid,
              columns: 3,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'a', label: 'A')],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'b', label: 'B')],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'c', label: 'C')],
                ),
              ],
            ),
          ),
        ),
      );

      // All three labels share one row, in left-to-right order.
      final a = tester.getTopLeft(find.text('A'));
      final b = tester.getTopLeft(find.text('B'));
      final c = tester.getTopLeft(find.text('C'));
      expect(b.dy, equals(a.dy));
      expect(c.dy, equals(a.dy));
      expect(b.dx, greaterThan(a.dx));
      expect(c.dx, greaterThan(b.dx));

      // Nested BcRenderer for each child
      expect(find.byType(BcRenderer), findsNWidgets(4));
    });

    testWidgets('default columns = 2', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.grid,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'a', label: 'A')],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'b', label: 'B')],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'c', label: 'C')],
                ),
              ],
            ),
          ),
        ),
      );

      // Default is two columns: A and B share a row, C wraps to the next.
      final a = tester.getTopLeft(find.text('A'));
      final b = tester.getTopLeft(find.text('B'));
      final c = tester.getTopLeft(find.text('C'));
      expect(b.dy, equals(a.dy));
      expect(b.dx, greaterThan(a.dx));
      expect(c.dy, greaterThan(a.dy));
      expect(c.dx, equals(a.dx));
    });
  });

  // =========================================================================
  // VAL-RENDER-011 — Grid kind shows title and description
  // =========================================================================
  group('VAL-RENDER-011 grid title/description', () {
    testWidgets('renders title and description above the grid', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.grid,
              title: 'Dashboard',
              description: 'Overview widgets',
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'a', label: 'A')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Overview widgets'), findsOneWidget);

      final titleRect = tester.getTopLeft(find.text('Dashboard'));
      final gridRect = tester.getTopLeft(find.text('A'));
      expect(gridRect.dy, greaterThan(titleRect.dy));
    });

    testWidgets('null title/description still renders grid', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.grid,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'a', label: 'A')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-RENDER-012 — Custom kind invokes customBuilder callback
  // =========================================================================
  group('VAL-RENDER-012 custom kind', () {
    testWidgets('invokes customBuilder with name and payload', (tester) async {
      String? builderName;
      Object? builderPayload;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.custom,
              name: 'widget1',
              payload: {'key': 'val'},
            ),
          ),
          customBuilder: (name, payload) {
            builderName = name;
            builderPayload = payload;
            return Text('Custom: $name');
          },
        ),
      );

      expect(find.text('Custom: widget1'), findsOneWidget);
      expect(builderName, 'widget1');
      expect(builderPayload, {'key': 'val'});
    });

    testWidgets('null customBuilder renders fallback without crash',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.custom,
              name: 'fallback',
            ),
          ),
        ),
      );

      // No crash, minimal widget rendered
      expect(find.byType(BcForm), findsNothing);
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsNothing);
    });
  });

  // =========================================================================
  // VAL-RENDER-013 — Recursive rendering propagates values
  // =========================================================================
  group('VAL-RENDER-013 value propagation', () {
    testWidgets('values propagate to nested child forms', (tester) async {
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
                    FieldNode(name: 'shared', type: FieldType.input),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'shared', type: FieldType.input),
                  ],
                ),
              ],
            ),
            values: {'shared': 'init'},
          ),
        ),
      );

      // Both child forms should have the initial value 'init' in their stores
      final inputs = tester.widgetList<BcInput>(find.byType(BcInput));
      for (final input in inputs) {
        expect(input.value, 'init');
      }
    });

    testWidgets('field change fires onChange at top level', (tester) async {
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
            values: {},
            onChange: (values) => lastChange = values,
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
  // VAL-RENDER-014 — Recursive rendering propagates disabled state
  // =========================================================================
  group('VAL-RENDER-014 disabled propagation', () {
    testWidgets('disabled=true propagates to section children',
        (tester) async {
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
                    FieldNode(name: 'f', type: FieldType.input),
                  ],
                ),
              ],
            ),
            disabled: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('disabled=false leaves children editable', (tester) async {
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
                    FieldNode(name: 'f', type: FieldType.input),
                  ],
                ),
              ],
            ),
            disabled: false,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isTrue);
    });

    testWidgets('disabled=true propagates to grid children', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.grid,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'a', type: FieldType.input),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'b', type: FieldType.input),
                  ],
                ),
              ],
            ),
            disabled: true,
          ),
        ),
      );

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final tf in textFields) {
        expect(tf.enabled, isFalse);
      }
    });
  });

  // =========================================================================
  // VAL-RENDER-015 — Recursive rendering propagates callbacks
  // =========================================================================
  group('VAL-RENDER-015 callback propagation', () {
    testWidgets('onChange fires at top level from child', (tester) async {
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
                    FieldNode(name: 'f', type: FieldType.input),
                  ],
                ),
              ],
            ),
            onChange: (values) => lastChange = values,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'val');
      await tester.pump();

      expect(lastChange, isNotNull);
      expect(lastChange!['f'], 'val');
    });

    testWidgets('onSubmit fires at top level from child submit action',
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
                  fields: [FieldNode(name: 'f')],
                  actions: [
                    UiAction(name: 'save', label: 'Save', submit: true),
                  ],
                ),
              ],
            ),
            values: {'f': 'data'},
            onSubmit: (values) => submitted = values,
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!['f'], 'data');
    });

    testWidgets('onAction fires at top level from child non-submit action',
        (tester) async {
      String? actionName;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [FieldNode(name: 'f')],
                  actions: [
                    UiAction(name: 'cancel', label: 'Cancel'),
                  ],
                ),
              ],
            ),
            onAction: (name, values) => actionName = name,
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(actionName, 'cancel');
    });
  });

  // =========================================================================
  // VAL-RENDER-016 — Null schema renders nothing or placeholder
  // =========================================================================
  group('VAL-RENDER-016 null schema', () {
    testWidgets('renders placeholder without crash', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: const BcRendererProps(schema: null),
        ),
      );

      expect(find.byType(BcForm), findsNothing);
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  // =========================================================================
  // VAL-RENDER-017 — Action buttons fire callbacks through BcRenderer
  // =========================================================================
  group('VAL-RENDER-017 action callbacks through renderer', () {
    testWidgets('submit action fires onSubmit, non-submit fires onAction',
        (tester) async {
      Map<String, dynamic>? submittedValues;
      String? actionName;
      Map<String, dynamic>? submittedViaAction;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [FieldNode(name: 'title')],
              actions: [
                UiAction(name: 'save', label: 'Save', submit: true),
                UiAction(name: 'draft', label: 'Draft'),
              ],
            ),
            values: {'title': 'Test'},
            onSubmit: (v) => submittedValues = v,
            onAction: (name, v) {
              actionName = name;
              submittedViaAction = v;
            },
          ),
        ),
      );

      // Tap Save (submit)
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(submittedValues, isNotNull);
      expect(submittedValues!['title'], 'Test');

      // Tap Draft (non-submit)
      await tester.tap(find.text('Draft'));
      await tester.pumpAndSettle();
      expect(actionName, 'draft');
      expect(submittedViaAction!['title'], 'Test');
    });
  });

  // =========================================================================
  // VAL-RENDER-018 — Direct form disabled propagation
  // =========================================================================
  group('VAL-RENDER-018 direct form disabled', () {
    testWidgets('disabled=true on form schema disables all fields',
        (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              fields: [
                FieldNode(name: 'a', type: FieldType.input),
                FieldNode(name: 'b', type: FieldType.input),
              ],
            ),
            disabled: true,
          ),
        ),
      );

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final tf in textFields) {
        expect(tf.enabled, isFalse);
      }
    });
  });

  // =========================================================================
  // VAL-RENDER-019 — Form layout propagates from schema to BcForm
  // =========================================================================
  group('VAL-RENDER-019 form layout propagation', () {
    testWidgets('vertical layout renders fields stacked', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              layout: FormLayout.vertical,
              fields: [
                FieldNode(name: 'a', type: FieldType.input, label: 'A'),
                FieldNode(name: 'b', type: FieldType.input, label: 'B'),
              ],
            ),
          ),
        ),
      );

      final aRect = tester.getTopLeft(find.text('A'));
      final bRect = tester.getTopLeft(find.text('B'));
      expect(bRect.dy, greaterThan(aRect.dy));
    });

    testWidgets('horizontal layout renders fields side by side', (tester) async {
      tester.view.physicalSize = const Size(2400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.form,
              layout: FormLayout.horizontal,
              fields: [
                FieldNode(name: 'a', type: FieldType.input, label: 'A'),
                FieldNode(name: 'b', type: FieldType.input, label: 'B'),
              ],
            ),
          ),
        ),
      );

      final aRect = tester.getTopLeft(find.byType(BcInput).first);
      final bRect = tester.getTopLeft(find.byType(BcInput).at(1));
      expect(bRect.dx, greaterThan(aRect.dx));
    });
  });

  // =========================================================================
  // VAL-RENDER-020 — Empty list data renders deterministic empty state
  // =========================================================================
  group('VAL-RENDER-020 empty list state', () {
    testWidgets('empty inline data renders empty state', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.list,
              columnsDef: [ColumnDef(key: 'name', label: 'Name')],
              data: [],
            ),
          ),
        ),
      );

      // BcDataTable with empty rows should show empty state
      expect(find.byType(BcDataTable<Map<String, dynamic>>), findsOneWidget);
      expect(find.byType(BcEmpty), findsOneWidget);
    });
  });

  // =========================================================================
  // VAL-RENDER-021 — Custom builder in recursive rendering
  // =========================================================================
  group('VAL-RENDER-021 custom in recursion', () {
    testWidgets('custom schema inside section invokes customBuilder',
        (tester) async {
      String? receivedName;
      Object? receivedPayload;

      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.section,
              sections: [
                UiSchema(
                  type: UiSchemaKind.custom,
                  name: 'nested_custom',
                  payload: {'nested': true},
                ),
              ],
            ),
          ),
          customBuilder: (name, payload) {
            receivedName = name;
            receivedPayload = payload;
            return Text('Nested: $name');
          },
        ),
      );

      expect(find.text('Nested: nested_custom'), findsOneWidget);
      expect(receivedName, 'nested_custom');
      expect(receivedPayload, {'nested': true});
    });
  });

  // =========================================================================
  // VAL-RENDER-022 — Detail schemas do not render mutating action buttons
  // =========================================================================
  group('VAL-RENDER-022 detail no mutating actions', () {
    testWidgets('detail schema does not render submit actions', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.detail,
              fields: [FieldNode(name: 'f', label: 'F')],
              actions: [
                UiAction(name: 'edit', label: 'Edit'),
                UiAction(name: 'save', label: 'Save', submit: true),
              ],
            ),
          ),
        ),
      );

      // Non-submit action is rendered
      expect(find.text('Edit'), findsOneWidget);
      // Submit action is NOT rendered
      expect(find.text('Save'), findsNothing);
    });
  });

  // =========================================================================
  // VAL-RENDER-023 — Renderer store sharing is explicit, not accidental
  // =========================================================================
  group('VAL-RENDER-023 independent stores', () {
    testWidgets('grid forms have independent stores', (tester) async {
      await _pumpRenderer(
        tester,
        BcRenderer(
          props: BcRendererProps(
            schema: const UiSchema(
              type: UiSchemaKind.grid,
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

      // Two BcForm instances (independent stores)
      expect(find.byType(BcForm), findsNWidgets(2));

      // Enter text in form A's field
      await tester.enterText(find.byType(TextField).first, 'valueA');
      await tester.pump();

      // Form B's field should NOT have 'valueA'
      final inputs = tester.widgetList<BcInput>(find.byType(BcInput));
      expect(inputs.length, 2);
      expect(inputs.first.value, 'valueA');
      expect(inputs.last.value, isNot('valueA'));
    });

    testWidgets('section forms have independent stores', (tester) async {
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
                    FieldNode(name: 'x', type: FieldType.input),
                  ],
                ),
                UiSchema(
                  type: UiSchemaKind.form,
                  fields: [
                    FieldNode(name: 'y', type: FieldType.input),
                  ],
                ),
              ],
            ),
            values: {'x': 'initX', 'y': 'initY'},
          ),
        ),
      );

      // Both forms get their initial values
      final inputs = tester.widgetList<BcInput>(find.byType(BcInput));
      expect(inputs.length, 2);
      expect(inputs.first.value, 'initX');
      expect(inputs.last.value, 'initY');

      // Change form A's field — form B should not be affected
      await tester.enterText(find.byType(TextField).first, 'changedX');
      await tester.pump();

      final inputsAfter = tester.widgetList<BcInput>(find.byType(BcInput));
      expect(inputsAfter.first.value, 'changedX');
      expect(inputsAfter.last.value, 'initY');
    });
  });
}
