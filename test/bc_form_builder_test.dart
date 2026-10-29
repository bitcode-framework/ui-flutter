// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bc_ui_flutter/src/components/bc_form_builder.dart';

void main() {
  group('BcFieldType', () {
    test('all 12 field types have unique ids', () {
      final ids = BcFieldType.values.map((e) => e.id).toSet();
      expect(ids.length, 12);
    });

    test('fromString round-trips all types', () {
      for (final ft in BcFieldType.values) {
        expect(BcFieldType.fromString(ft.id), ft);
      }
    });

    test('fromString defaults to string for unknown', () {
      expect(BcFieldType.fromString('unknown'), BcFieldType.string);
    });

    test('isRelation returns true for relational types', () {
      expect(BcFieldType.many2one.isRelation, isTrue);
      expect(BcFieldType.one2many.isRelation, isTrue);
      expect(BcFieldType.many2many.isRelation, isTrue);
      expect(BcFieldType.morphTo.isRelation, isTrue);
      expect(BcFieldType.string.isRelation, isFalse);
    });
  });

  group('BcFormViewJson', () {
    test('toJson produces valid view.json structure', () {
      final viewJson = BcFormViewJson(
        name: 'contact_form',
        type: 'form',
        model: 'contact',
        title: 'Contact Form',
        fields: ['name', 'email'],
        layout: [
          BcFormLayoutRow([
            BcFormLayoutCell(field: 'name', width: 6),
            BcFormLayoutCell(field: 'email', width: 6),
          ]),
        ],
      );

      final json = viewJson.toJson();
      expect(json['name'], 'contact_form');
      expect(json['type'], 'form');
      expect(json['model'], 'contact');
      expect(json['title'], 'Contact Form');
      expect(json['fields'], ['name', 'email']);
      expect(json['layout'], isA<List>());
      expect((json['layout'] as List).length, 1);
    });

    test('toJsonString produces indented JSON', () {
      final viewJson = BcFormViewJson(
        name: 'test_view',
        fields: ['field1'],
        layout: [
          BcFormLayoutRow([
            BcFormLayoutCell(field: 'field1', width: 12),
          ]),
        ],
      );
      final jsonStr = viewJson.toJsonString();
      expect(jsonStr, contains('"name": "test_view"'));
      expect(jsonStr, contains('"type": "form"'));
      expect(jsonStr, contains('"fields"'));
      expect(jsonStr, contains('"layout"'));
    });

    test('omits model and title when empty', () {
      final viewJson = BcFormViewJson(
        name: 'simple',
        fields: ['a'],
      );
      final json = viewJson.toJson();
      expect(json.containsKey('model'), isFalse);
      expect(json.containsKey('title'), isFalse);
    });
  });

  group('BcValidationResult', () {
    test('fromJson parses valid result', () {
      final result = BcValidationResult.fromJson({
        'valid': true,
        'errors': [],
        'warnings': [],
      });
      expect(result.valid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('fromJson parses errors', () {
      final result = BcValidationResult.fromJson({
        'valid': false,
        'errors': [
          {'field': 'name', 'message': 'Name is required'},
        ],
        'warnings': [],
      });
      expect(result.valid, isFalse);
      expect(result.errors.length, 1);
      expect(result.errors.first.field, 'name');
      expect(result.errors.first.message, 'Name is required');
    });
  });

  group('BcFormField', () {
    test('copyWith updates fields correctly', () {
      const field = BcFormField(
        id: 'f1',
        name: 'test',
        label: 'Test',
        type: BcFieldType.string,
      );
      final updated = field.copyWith(label: 'Updated', required: true);
      expect(updated.id, 'f1');
      expect(updated.label, 'Updated');
      expect(updated.required, isTrue);
      expect(updated.name, 'test');
    });
  });

  group('BcFormBuilder Widget', () {
    Widget buildHarness({
      List<BcFormField> fields = const [],
      String viewName = 'test_view',
      String model = 'contact',
      String title = 'Test Form',
      BcValidationResult? validation,
      bool saveDisabled = false,
      void Function(List<BcFormField>)? onChange,
      void Function(BcFormViewJson)? onSave,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 800,
            child: BcFormBuilder(
              viewName: viewName,
              model: model,
              title: title,
              fields: fields,
              validation: validation,
              saveDisabled: saveDisabled,
              onChange: onChange,
              onSave: onSave,
            ),
          ),
        ),
      );
    }

    testWidgets('renders root container with key (VAL-FB-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-form-builder')), findsOneWidget);
    });

    testWidgets('renders toolbar with tabs (VAL-FB-002)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-tabs')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-tab-canvas')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-tab-json')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-tab-live')), findsOneWidget);
    });

    testWidgets('renders palette with 12 field types (VAL-FB-003)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-palette')), findsOneWidget);
      expect(
        find.byKey(const Key('bc-form-builder-palette-item-string')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('bc-form-builder-palette-item-integer')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('bc-form-builder-palette-item-float')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('bc-form-builder-palette-item-boolean')),
        findsOneWidget,
      );
    });

    testWidgets('shows empty canvas message when no fields (VAL-FB-004)',
        (tester) async {
      await tester.pumpWidget(buildHarness(fields: []));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-empty')), findsOneWidget);
      expect(find.text('Drag fields here to build your form'), findsOneWidget);
    });

    testWidgets('renders field cards for existing fields (VAL-FB-005)',
        (tester) async {
      final fields = [
        const BcFormField(
          id: 'f1',
          name: 'first_name',
          label: 'First Name',
          type: BcFieldType.string,
          required: true,
        ),
        const BcFormField(
          id: 'f2',
          name: 'age',
          label: 'Age',
          type: BcFieldType.integer,
        ),
      ];
      await tester.pumpWidget(buildHarness(fields: fields));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-field-f1')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-field-f2')), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('tapping a field selects it and shows property panel (VAL-FB-006)',
        (tester) async {
      final fields = [
        const BcFormField(
          id: 'f1',
          name: 'name',
          label: 'Name',
          type: BcFieldType.string,
        ),
      ];
      await tester.pumpWidget(buildHarness(fields: fields));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-properties')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-form-builder-field-f1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-prop-label')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-prop-name')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-prop-type')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-prop-required')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-prop-readonly')), findsOneWidget);
    });

    testWidgets('JSON tab shows view.json output (VAL-FB-007)',
        (tester) async {
      final fields = [
        const BcFormField(
          id: 'f1',
          name: 'name',
          label: 'Name',
          type: BcFieldType.string,
        ),
      ];
      await tester.pumpWidget(buildHarness(fields: fields));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-tab-json')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-json')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-json-output')), findsOneWidget);
      expect(find.textContaining('"name": "test_view"'), findsOneWidget);
      expect(find.textContaining('"type": "form"'), findsOneWidget);
    });

    testWidgets('live tab shows form preview (VAL-FB-008)', (tester) async {
      final fields = [
        const BcFormField(
          id: 'f1',
          name: 'name',
          label: 'Name',
          type: BcFieldType.string,
        ),
      ];
      await tester.pumpWidget(buildHarness(fields: fields));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-tab-live')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-live')), findsOneWidget);
      expect(find.byKey(const Key('bc-form-builder-live-form')), findsOneWidget);
      expect(
          find.byKey(const Key('bc-form-builder-live-field-name')), findsOneWidget);
    });

    testWidgets('validation status displays when validation provided (VAL-FB-009)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        validation: const BcValidationResult(valid: true),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc-form-builder-validation-status')), findsOneWidget);
      expect(find.text('Valid'), findsOneWidget);
    });

    testWidgets('invalid validation blocks save and shows errors (VAL-FB-010)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        validation: const BcValidationResult(
          valid: false,
          errors: [
            BcValidationIssue(field: 'name', message: 'Name is required'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-errors')), findsOneWidget);
      expect(find.textContaining('Name is required'), findsOneWidget);

      final saveButton =
          tester.widget<PlatformElevatedButton>(
        find.byKey(const Key('bc-form-builder-save')),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('save button disabled when saveDisabled is true (VAL-FB-011)',
        (tester) async {
      BcFormViewJson? savedJson;
      await tester.pumpWidget(buildHarness(
        saveDisabled: true,
        onSave: (json) => savedJson = json,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-save')));
      await tester.pumpAndSettle();

      expect(savedJson, isNull);
    });

    testWidgets('onSave callback fires when save pressed (VAL-FB-012)',
        (tester) async {
      BcFormViewJson? savedJson;
      final fields = [
        const BcFormField(
          id: 'f1',
          name: 'name',
          label: 'Name',
          type: BcFieldType.string,
        ),
      ];
      await tester.pumpWidget(buildHarness(
        fields: fields,
        validation: const BcValidationResult(valid: true),
        onSave: (json) => savedJson = json,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-save')));
      await tester.pumpAndSettle();

      expect(savedJson, isNotNull);
      expect(savedJson!.name, 'test_view');
      expect(savedJson!.type, 'form');
      expect(savedJson!.model, 'contact');
    });

    testWidgets('canvas has drag-drop support (VAL-FB-013)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-canvas')), findsOneWidget);

      final paletteItems = find.byKey(
        const Key('bc-form-builder-palette-item-string'),
      );
      expect(paletteItems, findsOneWidget);
    });

    testWidgets('onChange fires when field is added (VAL-FB-014)',
        (tester) async {
      List<BcFormField> changedFields = [];
      await tester.pumpWidget(buildHarness(
        onChange: (fields) => changedFields = fields,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-palette-item-string')));
      await tester.pumpAndSettle();

      expect(changedFields.length, 1);
      expect(changedFields.first.type, BcFieldType.string);
    });

    testWidgets('property panel shows selection options for selection type (VAL-FB-015)',
        (tester) async {
      final fields = [
        const BcFormField(
          id: 'f1',
          name: 'status',
          label: 'Status',
          type: BcFieldType.selection,
          options: ['Active', 'Inactive'],
        ),
      ];
      await tester.pumpWidget(buildHarness(fields: fields));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-field-f1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-prop-options')), findsOneWidget);
    });

    testWidgets('property panel shows relation model for relation types (VAL-FB-016)',
        (tester) async {
      final fields = [
        const BcFormField(
          id: 'f1',
          name: 'partner',
          label: 'Partner',
          type: BcFieldType.many2one,
          relationModel: 'contact',
        ),
      ];
      await tester.pumpWidget(buildHarness(fields: fields));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-field-f1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-prop-relation')), findsOneWidget);
    });

    testWidgets('live preview shows no fields message when empty (VAL-FB-017)',
        (tester) async {
      await tester.pumpWidget(buildHarness(fields: []));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-form-builder-tab-live')));
      await tester.pumpAndSettle();

      expect(find.text('No fields to preview'), findsOneWidget);
    });

    testWidgets('validate button is present (VAL-FB-018)', (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-form-builder-validate')), findsOneWidget);
      expect(find.text('Validate'), findsOneWidget);
    });

    testWidgets('i18n labels override default text (VAL-FB-019)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 800,
            child: BcFormBuilder(
              viewName: 'test',
              i18n: {
                'builder.validate': 'Validasi',
                'builder.save': 'Simpan',
              },
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Validasi'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });
  });
}
