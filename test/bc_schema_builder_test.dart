// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_schema_builder.dart';

void main() {
  group('BcSchemaFieldType', () {
    test('all 12 field types have unique ids', () {
      final ids = BcSchemaFieldType.values.map((e) => e.id).toSet();
      expect(ids.length, 12);
    });

    test('fromString round-trips all types', () {
      for (final ft in BcSchemaFieldType.values) {
        expect(BcSchemaFieldType.fromString(ft.id), ft);
      }
    });

    test('fromString defaults to string for unknown', () {
      expect(BcSchemaFieldType.fromString('unknown'), BcSchemaFieldType.string);
    });

    test('isRelation returns true for relational types', () {
      expect(BcSchemaFieldType.many2one.isRelation, isTrue);
      expect(BcSchemaFieldType.one2many.isRelation, isTrue);
      expect(BcSchemaFieldType.many2many.isRelation, isTrue);
      expect(BcSchemaFieldType.morphTo.isRelation, isTrue);
      expect(BcSchemaFieldType.string.isRelation, isFalse);
    });

    test('morph_to id is correct', () {
      expect(BcSchemaFieldType.morphTo.id, 'morph_to');
    });
  });

  group('BcModelJson', () {
    test('toJson produces valid model.json structure', () {
      final modelJson = BcModelJson(
        name: 'contact',
        module: 'base',
        label: 'Contact',
        fields: {
          'name': {'type': 'string', 'required': true, 'max': 200},
          'partner_id': {'type': 'many2one', 'model': 'partner'},
        },
      );

      final json = modelJson.toJson();
      expect(json['name'], 'contact');
      expect(json['module'], 'base');
      expect(json['label'], 'Contact');
      expect(json['fields'], isA<Map>());
      expect((json['fields'] as Map)['name'], isA<Map>());
    });

    test('toJsonString produces indented JSON', () {
      final modelJson = BcModelJson(
        name: 'test',
        fields: {
          'field1': {'type': 'string'},
        },
      );

      final str = modelJson.toJsonString();
      expect(str, contains('"name"'));
      expect(str, contains('"test"'));
      expect(str, contains('"fields"'));
      expect(str, contains('"type"'));
    });

    test('toJson omits empty module and label', () {
      final modelJson = BcModelJson(
        name: 'test',
        module: '',
        label: '',
        fields: {},
      );

      final json = modelJson.toJson();
      expect(json.containsKey('module'), isFalse);
      expect(json.containsKey('label'), isFalse);
    });
  });

  group('BcSchemaField', () {
    test('copyWith updates specified fields', () {
      final field = BcSchemaField(
        id: '1',
        name: 'name',
        label: 'Name',
        type: BcSchemaFieldType.string,
      );

      final updated = field.copyWith(label: 'Full Name', required: true);
      expect(updated.label, 'Full Name');
      expect(updated.required, isTrue);
      expect(updated.name, 'name');
      expect(updated.type, BcSchemaFieldType.string);
    });
  });

  group('BcSchemaValidationResult', () {
    test('fromJson parses valid result', () {
      final json = {
        'valid': true,
        'errors': [],
        'warnings': [],
      };

      final result = BcSchemaValidationResult.fromJson(json);
      expect(result.valid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
    });

    test('fromJson parses invalid result with errors', () {
      final json = {
        'valid': false,
        'errors': [
          {'field': 'name', 'message': 'Model name is required'},
        ],
        'warnings': [],
      };

      final result = BcSchemaValidationResult.fromJson(json);
      expect(result.valid, isFalse);
      expect(result.errors.length, 1);
      expect(result.errors.first.field, 'name');
      expect(result.errors.first.message, 'Model name is required');
    });
  });

  group('BcSchemaBuilder widget', () {
    testWidgets('renders with key bc-schema-builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(
              modelName: 'contact',
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-schema-builder')), findsOneWidget);
    });

    testWidgets('shows palette with field types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(modelName: 'contact'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-schema-builder-palette')), findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-palette-item-string')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-palette-item-integer')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-palette-item-float')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-palette-item-boolean')),
          findsOneWidget);
    });

    testWidgets('shows empty state when no fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(modelName: 'contact'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-schema-builder-empty')), findsOneWidget);
    });

    testWidgets('shows toolbar with validate and save buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(modelName: 'contact'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-schema-builder-validate')), findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-save')), findsOneWidget);
    });

    testWidgets('tapping a palette item adds a field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(modelName: 'contact'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-schema-builder-empty')), findsOneWidget);

      await tester.tap(
          find.byKey(const Key('bc-schema-builder-palette-item-string')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-schema-builder-empty')), findsNothing);
      expect(find.byKey(const Key('bc-schema-builder-canvas')), findsOneWidget);
    });

    testWidgets('JSON tab shows model.json output', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(modelName: 'contact'),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-schema-builder-tab-json')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-schema-builder-json')), findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-json-output')),
          findsOneWidget);
    });

    testWidgets('onChange callback fires when field is added', (tester) async {
      List<BcSchemaField>? changedFields;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(
              modelName: 'contact',
              onChange: (fields) {
                changedFields = fields;
              },
            ),
          ),
        ),
      );

      await tester.tap(
          find.byKey(const Key('bc-schema-builder-palette-item-integer')));
      await tester.pumpAndSettle();

      expect(changedFields, isNotNull);
      expect(changedFields!.length, 1);
      expect(changedFields!.first.type, BcSchemaFieldType.integer);
    });

    testWidgets('renders provided fields from props', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(
              modelName: 'contact',
              fields: [
                BcSchemaField(
                  id: 'f1',
                  name: 'first_name',
                  label: 'First Name',
                  type: BcSchemaFieldType.string,
                  required: true,
                ),
                BcSchemaField(
                  id: 'f2',
                  name: 'partner',
                  label: 'Partner',
                  type: BcSchemaFieldType.many2one,
                  relationModel: 'partner',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Partner'), findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-field-f1')), findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-field-f2')), findsOneWidget);
    });

    testWidgets('selecting a field shows property panel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(
              modelName: 'contact',
              fields: [
                BcSchemaField(
                  id: 'f1',
                  name: 'name',
                  label: 'Name',
                  type: BcSchemaFieldType.string,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-schema-builder-field-f1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-schema-builder-prop-label')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-prop-name')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-prop-type')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-prop-required')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-prop-unique')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-prop-index')),
          findsOneWidget);
    });

    testWidgets('validation status shows when validation prop is set',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcSchemaBuilder(
              modelName: 'contact',
              validation: BcSchemaValidationResult(
                valid: false,
                errors: [
                  BcSchemaValidationIssue(
                      field: 'name', message: 'Required'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-schema-builder-validation-status')),
          findsOneWidget);
      expect(find.byKey(const Key('bc-schema-builder-errors')), findsOneWidget);
      expect(find.textContaining('Required'), findsOneWidget);
    });
  });
}
