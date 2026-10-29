/// Renderer field resolver ported from
/// @bitcode/ui-schema/src/schema/resolver.ts (ADR-005 §2 FieldResolver).
///
/// Maps a [FieldNode] to a BcForm-compatible [ResolvedFormField] so the
/// renderer can hand a single `fields[]` array to BcForm and reuse all of its
/// validation + reactive plumbing.
///
/// Pure functions — no rendering, no Flutter imports. Testable via `dart test`.

library field_resolver;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ui_schema.dart';

part 'field_resolver.freezed.dart';
part 'field_resolver.g.dart';

/// BcForm-compatible field def (mirrors `FormFieldDef` in BcForm.lite.tsx).
///
/// `type` is a plain [String] (native input type, or `'textarea'` /
/// `'select'`) so BcForm doesn't need to import the [FieldType] enum.
@freezed
class ResolvedFormField with _$ResolvedFormField {
  const factory ResolvedFormField({
    required String name,
    String? label,
    required String type,
    String? placeholder,
    @Default(false) bool required,
    @Default(false) bool disabled,
    String? hint,
    @Default([]) List<FieldOption> options,
    num? min,
    num? max,
    String? pattern,
  }) = _ResolvedFormField;

  factory ResolvedFormField.fromJson(Map<String, dynamic> json) =>
      _$ResolvedFormFieldFromJson(json);
}

/// Convert a schema [FieldType] to a BcForm `type` string.
///
/// Most types map directly; a few (toggle, checkbox, password, email, url,
/// tel) reuse the native HTML input type so BcForm renders the right input.
/// Mirrors TS `resolveFieldType`.
String resolveFieldType(FieldType? type) {
  switch (type) {
    case FieldType.textarea:
      return 'textarea';
    case FieldType.select:
      return 'select';
    case FieldType.number:
      return 'number';
    case FieldType.date:
      return 'date';
    case FieldType.email:
      return 'email';
    case FieldType.password:
      return 'password';
    case FieldType.url:
      return 'url';
    case FieldType.tel:
      return 'tel';
    case FieldType.toggle:
    case FieldType.checkbox:
      return 'checkbox';
    case FieldType.input:
    case null:
      return 'text';
  }
}

/// Convert a [FieldNode] into a BcForm field def. Mirrors TS `resolveField`.
///
/// Inline option lists pass through unchanged; `DataSource` options are
/// dropped here because BcForm Phase 0 does not yet take live data sources
/// for choice fields. Consumers needing live options should preprocess the
/// schema.
ResolvedFormField resolveField(FieldNode node) {
  return ResolvedFormField(
    name: node.name,
    label: node.label,
    type: resolveFieldType(node.type),
    placeholder: node.placeholder,
    required: node.required,
    disabled: node.disabled,
    hint: node.hint,
    min: node.min,
    max: node.max,
    pattern: node.pattern,
    options: node.options,
  );
}

/// Resolve every field in a list. Pure; returns a fresh array so the input
/// schema stays unmutated. Mirrors TS `resolveFields`.
List<ResolvedFormField> resolveFields(List<FieldNode>? fields) {
  return (fields ?? const []).map(resolveField).toList(growable: false);
}

/// Pluggable resolver hook. Mirrors TS `FieldResolver`.
///
/// Hosts that need custom field types (lookup, file-upload, signature-pad,
/// ...) can pre-process the schema by mapping unknown `node.type` values to a
/// known [FieldType] before handing the schema to the renderer.
typedef FieldResolver = ResolvedFormField Function(FieldNode node);

/// The default resolver is a thin wrapper around [resolveField].
/// Mirrors TS `defaultFieldResolver`.
ResolvedFormField defaultFieldResolver(FieldNode node) => resolveField(node);
