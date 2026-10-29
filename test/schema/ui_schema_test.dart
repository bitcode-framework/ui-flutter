import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema_types.dart';

void main() {
  group('UiSchemaKind', () {
    test('has all six kinds', () {
      expect(UiSchemaKind.values.length, 6);
      expect(UiSchemaKind.values, contains(UiSchemaKind.form));
      expect(UiSchemaKind.values, contains(UiSchemaKind.list));
      expect(UiSchemaKind.values, contains(UiSchemaKind.detail));
      expect(UiSchemaKind.values, contains(UiSchemaKind.section));
      expect(UiSchemaKind.values, contains(UiSchemaKind.grid));
      expect(UiSchemaKind.values, contains(UiSchemaKind.custom));
    });
  });

  group('FieldType', () {
    test('has all eleven types', () {
      expect(FieldType.values.length, 11);
      expect(FieldType.values, contains(FieldType.input));
      expect(FieldType.values, contains(FieldType.textarea));
      expect(FieldType.values, contains(FieldType.select));
      expect(FieldType.values, contains(FieldType.number));
      expect(FieldType.values, contains(FieldType.date));
      expect(FieldType.values, contains(FieldType.toggle));
      expect(FieldType.values, contains(FieldType.checkbox));
      expect(FieldType.values, contains(FieldType.email));
      expect(FieldType.values, contains(FieldType.password));
      expect(FieldType.values, contains(FieldType.url));
      expect(FieldType.values, contains(FieldType.tel));
    });
  });

  group('FieldNode', () {
    test('constructs with required name only and sensible defaults', () {
      const node = FieldNode(name: 'username');
      expect(node.name, 'username');
      expect(node.label, isNull);
      expect(node.type, isNull);
      expect(node.required, isFalse);
      expect(node.disabled, isFalse);
      expect(node.options, isEmpty);
      expect(node.validation, isEmpty);
    });

    test('copyWith preserves untouched fields', () {
      const node = FieldNode(
        name: 'email',
        label: 'Email',
        type: FieldType.email,
        required: true,
      );
      final copied = node.copyWith(label: 'Work Email');
      expect(copied.name, 'email');
      expect(copied.label, 'Work Email');
      expect(copied.type, FieldType.email);
      expect(copied.required, isTrue);
    });

    test('equality based on all fields', () {
      const a = FieldNode(name: 'x', label: 'X', type: FieldType.input);
      const b = FieldNode(name: 'x', label: 'X', type: FieldType.input);
      const c = FieldNode(name: 'x', label: 'Y', type: FieldType.input);
      expect(a == b, isTrue);
      expect(a == c, isFalse);
      expect(a.hashCode, b.hashCode);
    });

    test('JSON round-trip preserves data', () {
      const node = FieldNode(
        name: 'age',
        label: 'Age',
        type: FieldType.number,
        required: true,
        min: 0,
        max: 150,
        options: [FieldOption(value: 'a', label: 'A')],
      );
      final json = node.toJson();
      final restored = FieldNode.fromJson(json);
      expect(restored, node);
    });
  });

  group('UiAction', () {
    test('defaults: submit false, disabled false', () {
      const action = UiAction(name: 'save');
      expect(action.name, 'save');
      expect(action.submit, isFalse);
      expect(action.disabled, isFalse);
      expect(action.variant, isNull);
    });

    test('JSON round-trip', () {
      const action = UiAction(
        name: 'submit',
        label: 'Submit',
        variant: ComponentVariant.primary,
        submit: true,
      );
      final restored = UiAction.fromJson(action.toJson());
      expect(restored, action);
    });
  });

  group('ColumnDef', () {
    test('defaults: sortable/filterable false, align left', () {
      const col = ColumnDef(key: 'name', label: 'Name');
      expect(col.sortable, isFalse);
      expect(col.filterable, isFalse);
      expect(col.align, ColumnAlign.left);
    });

    test('JSON round-trip', () {
      const col = ColumnDef(
        key: 'price',
        label: 'Price',
        sortable: true,
        align: ColumnAlign.right,
        width: '120px',
      );
      final restored = ColumnDef.fromJson(col.toJson());
      expect(restored, col);
    });
  });

  group('UiSchema', () {
    test('form schema with fields + actions', () {
      const schema = UiSchema(
        type: UiSchemaKind.form,
        name: 'login',
        title: 'Login',
        fields: [
          FieldNode(name: 'email', type: FieldType.email, required: true),
          FieldNode(name: 'password', type: FieldType.password, required: true),
        ],
        actions: [UiAction(name: 'submit', submit: true)],
      );
      expect(schema.type, UiSchemaKind.form);
      expect(schema.fields.length, 2);
      expect(schema.actions.length, 1);
      expect(schema.actions.first.submit, isTrue);
      expect(schema.layout, FormLayout.vertical);
    });

    test('recursive sections for grouping kinds', () {
      const schema = UiSchema(
        type: UiSchemaKind.section,
        title: 'Profile',
        sections: [
          UiSchema(
            type: UiSchemaKind.form,
            title: 'Basic',
            fields: [FieldNode(name: 'name')],
          ),
          UiSchema(type: UiSchemaKind.form, title: 'Contact'),
        ],
      );
      expect(schema.sections.length, 2);
      expect(schema.sections.first.fields.first.name, 'name');
    });

    test('grid schema columns default is 2', () {
      const schema = UiSchema(type: UiSchemaKind.grid);
      expect(schema.columns, 2);
    });

    test('list schema with columns_def + inline data', () {
      const schema = UiSchema(
        type: UiSchemaKind.list,
        columnsDef: [
          ColumnDef(key: 'id', label: 'ID'),
          ColumnDef(key: 'name', label: 'Name', sortable: true),
        ],
        data: [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'},
        ],
        pageSize: 10,
      );
      expect(schema.columnsDef.length, 2);
      expect(schema.data.length, 2);
      expect(schema.pageSize, 10);
    });

    test('JSON round-trip preserves form + sections', () {
      const schema = UiSchema(
        type: UiSchemaKind.section,
        title: 'Root',
        sections: [
          UiSchema(
            type: UiSchemaKind.form,
            fields: [FieldNode(name: 'x', type: FieldType.number)],
          ),
        ],
      );
      final restored = UiSchema.fromJson(schema.toJson());
      expect(restored, schema);
    });
  });

  group('BcRendererProps', () {
    test('defaults: empty values, disabled false', () {
      const props = BcRendererProps();
      expect(props.schema, isNull);
      expect(props.values, isEmpty);
      expect(props.disabled, isFalse);
    });

    test('copyWith replaces only provided fields', () {
      var captured = <String, dynamic>{};
      const props = BcRendererProps(values: {'a': 1});
      final copied = props.copyWith(
        onChange: (v) => captured = v,
        disabled: true,
      );
      expect(copied.values, {'a': 1});
      expect(copied.disabled, isTrue);
      expect(copied.onChange, isNotNull);
      copied.onChange!({'b': 2});
      expect(captured, {'b': 2});
      // original untouched
      expect(props.disabled, isFalse);
      expect(props.onChange, isNull);
    });
  });

  group('DataSource sealed class', () {
    test('local variant round-trips', () {
      const ds = DataSource.local(data: [1, 2, 3]);
      final restored = DataSource.fromJson(ds.toJson());
      expect(restored, isA<DataSourceLocal>());
      expect((restored as DataSourceLocal).data, [1, 2, 3]);
    });

    test('url variant round-trips with headers', () {
      const ds = DataSource.url(
        url: 'https://example.com/api',
        headers: {'Authorization': 'Bearer x'},
      );
      final restored = DataSource.fromJson(ds.toJson());
      expect(restored, isA<DataSourceUrl>());
      expect((restored as DataSourceUrl).url, 'https://example.com/api');
      expect(restored.headers['Authorization'], 'Bearer x');
    });

    test('fetcher variant constructed in Dart (no JSON)', () {
      final ds = DataSource.fetcher(
        fetcher: (params) => const FetchResult(data: [42], total: 1),
      );
      expect(ds, isA<DataSourceFetcher>());
      expect((ds as DataSourceFetcher).fetcher, isNotNull);
    });

    test('model variant constructed in Dart', () {
      const ds = DataSource.model(name: 'crm.contact');
      expect(ds, isA<DataSourceModel>());
      expect((ds as DataSourceModel).name, 'crm.contact');
      expect(ds.adapter, isNull);
    });
  });

  group('FetchParams / FetchResult', () {
    test('FetchParams defaults', () {
      const params = FetchParams();
      expect(params.sort, isEmpty);
      expect(params.filters, isEmpty);
      expect(params.dependValues, isEmpty);
    });

    test('FetchResult JSON round-trip', () {
      const result = FetchResult(data: [1, 2], total: 2);
      final restored = FetchResult.fromJson(result.toJson());
      expect(restored, result);
    });

    test('SortRule defaults to asc', () {
      const rule = SortRule(field: 'name');
      expect(rule.direction, SortDirection.asc);
    });
  });

  group('BcSelection sealed class', () {
    test('all variant', () {
      const sel = BcSelection.all();
      expect(sel, isA<BcSelectionAll>());
    });

    test('set variant', () {
      const sel = BcSelection.set({1, 2, 3});
      expect(sel, isA<BcSelectionSet>());
      expect((sel as BcSelectionSet).keys.length, 3);
    });

    test('list variant', () {
      const sel = BcSelection.list(['a', 'b']);
      expect(sel, isA<BcSelectionList>());
      expect((sel as BcSelectionList).keys.length, 2);
    });
  });

  group('Enums', () {
    test('ThemeMode has 3 values', () {
      expect(ThemeMode.values.length, 3);
    });

    test('ResolvedTheme has 2 values', () {
      expect(ResolvedTheme.values.length, 2);
    });

    test('ComponentSize has sm/md/lg', () {
      expect(ComponentSize.values.length, 3);
    });

    test('ComponentVariant has 7 values', () {
      expect(ComponentVariant.values.length, 7);
    });

    test('InputType has 13 values', () {
      expect(InputType.values.length, 13);
      expect(InputType.values, contains(InputType.datetimeLocal));
    });

    test('InputSize has 3 values', () {
      expect(InputSize.values.length, 3);
    });

    test('ValidationStatus has 4 values', () {
      expect(ValidationStatus.values.length, 4);
    });
  });
}
