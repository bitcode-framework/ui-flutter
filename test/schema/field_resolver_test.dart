import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/schema/field_resolver.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema.dart';

void main() {
  group('resolveFieldType', () {
    test('returns "text" for null (default input)', () {
      expect(resolveFieldType(null), 'text');
    });

    test('returns "text" for FieldType.input', () {
      expect(resolveFieldType(FieldType.input), 'text');
    });

    test('maps textarea / select / number / date directly', () {
      expect(resolveFieldType(FieldType.textarea), 'textarea');
      expect(resolveFieldType(FieldType.select), 'select');
      expect(resolveFieldType(FieldType.number), 'number');
      expect(resolveFieldType(FieldType.date), 'date');
    });

    test('maps email / password / url / tel to native input types', () {
      expect(resolveFieldType(FieldType.email), 'email');
      expect(resolveFieldType(FieldType.password), 'password');
      expect(resolveFieldType(FieldType.url), 'url');
      expect(resolveFieldType(FieldType.tel), 'tel');
    });

    test('folds toggle + checkbox into "checkbox"', () {
      expect(resolveFieldType(FieldType.toggle), 'checkbox');
      expect(resolveFieldType(FieldType.checkbox), 'checkbox');
    });

    test('exhaustive: covers all 11 FieldType values', () {
      for (final t in FieldType.values) {
        // Must not throw — every enum value has a branch.
        final result = resolveFieldType(t);
        expect(result, isNotEmpty);
      }
    });
  });

  group('resolveField', () {
    test('maps minimal FieldNode (name only)', () {
      const node = FieldNode(name: 'username');
      final resolved = resolveField(node);
      expect(resolved.name, 'username');
      expect(resolved.type, 'text');
      expect(resolved.label, isNull);
      expect(resolved.required, isFalse);
      expect(resolved.options, isEmpty);
    });

    test('preserves all simple props', () {
      const node = FieldNode(
        name: 'age',
        label: 'Age',
        type: FieldType.number,
        placeholder: 'Enter age',
        required: true,
        disabled: false,
        hint: 'Must be 18+',
        min: 18,
        max: 99,
        pattern: r'^\d+$',
      );
      final resolved = resolveField(node);
      expect(resolved.name, 'age');
      expect(resolved.label, 'Age');
      expect(resolved.type, 'number');
      expect(resolved.placeholder, 'Enter age');
      expect(resolved.required, isTrue);
      expect(resolved.disabled, isFalse);
      expect(resolved.hint, 'Must be 18+');
      expect(resolved.min, 18);
      expect(resolved.max, 99);
      expect(resolved.pattern, r'^\d+$');
    });

    test('passes inline options through unchanged', () {
      const node = FieldNode(
        name: 'country',
        type: FieldType.select,
        options: [
          FieldOption(value: 'id', label: 'Indonesia'),
          FieldOption(value: 'us', label: 'United States'),
        ],
      );
      final resolved = resolveField(node);
      expect(resolved.options.length, 2);
      expect(resolved.options.first.value, 'id');
      expect(resolved.options.first.label, 'Indonesia');
    });

    test('select type resolves to "select"', () {
      const node = FieldNode(name: 'x', type: FieldType.select);
      expect(resolveField(node).type, 'select');
    });

    test('toggle resolves to "checkbox" type', () {
      const node = FieldNode(name: 'agree', type: FieldType.toggle);
      expect(resolveField(node).type, 'checkbox');
    });
  });

  group('resolveFields', () {
    test('returns empty list for null input', () {
      expect(resolveFields(null), isEmpty);
    });

    test('returns empty list for empty input', () {
      expect(resolveFields(const []), isEmpty);
    });

    test('resolves every field preserving order', () {
      const fields = [
        FieldNode(name: 'a', type: FieldType.input),
        FieldNode(name: 'b', type: FieldType.number),
        FieldNode(name: 'c', type: FieldType.select),
      ];
      final resolved = resolveFields(fields);
      expect(resolved.length, 3);
      expect(resolved[0].name, 'a');
      expect(resolved[0].type, 'text');
      expect(resolved[1].name, 'b');
      expect(resolved[1].type, 'number');
      expect(resolved[2].name, 'c');
      expect(resolved[2].type, 'select');
    });

    test('returns unmodifiable-length list (growable: false)', () {
      final resolved = resolveFields(const [FieldNode(name: 'x')]);
      expect(() => resolved.add(const ResolvedFormField(name: 'y', type: 'text')),
          throwsUnsupportedError);
    });

    test('does not mutate the input list', () {
      const fields = [FieldNode(name: 'a')];
      resolveFields(fields);
      expect(fields.length, 1);
      expect(fields.first.name, 'a');
    });
  });

  group('defaultFieldResolver', () {
    test('is a FieldResolver typedef that wraps resolveField', () {
      const node = FieldNode(name: 'email', type: FieldType.email);
      final result = defaultFieldResolver(node);
      expect(result, isA<ResolvedFormField>());
      expect(result.name, 'email');
      expect(result.type, 'email');
    });

    test('can be assigned to a FieldResolver-typed variable', () {
      FieldResolver resolver = defaultFieldResolver;
      const node = FieldNode(name: 'x', type: FieldType.url);
      expect(resolver(node).type, 'url');
    });
  });

  group('ResolvedFormField', () {
    test('JSON round-trip', () {
      const field = ResolvedFormField(
        name: 'qty',
        label: 'Quantity',
        type: 'number',
        required: true,
        min: 0,
      );
      final restored = ResolvedFormField.fromJson(field.toJson());
      expect(restored, field);
    });

    test('copyWith', () {
      const field = ResolvedFormField(name: 'x', type: 'text');
      final copied = field.copyWith(label: 'X');
      expect(copied.name, 'x');
      expect(copied.label, 'X');
      expect(copied.type, 'text');
    });

    test('equality', () {
      const a = ResolvedFormField(name: 'x', type: 'text');
      const b = ResolvedFormField(name: 'x', type: 'text');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });
  });
}
