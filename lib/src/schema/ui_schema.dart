/// UiSchema document types ported from @bitcode/ui-schema/src/schema/types.ts.
///
/// Domain-agnostic renderer schema (ADR-005). A [UiSchema] document is a tree
/// of `form` / `list` / `detail` / `section` / `grid` / `custom` nodes that a
/// renderer walks to produce a widget tree wired to a [ReactiveStore].
///
/// Freezed + json_serializable so the same JSON the TS renderer consumes can
/// be loaded directly in Dart.

library ui_schema;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/reactive_store.dart' show ValidationRule, Reaction;
import 'ui_schema_types.dart';

part 'ui_schema.freezed.dart';
part 'ui_schema.g.dart';

/// Top-level schema kind discriminator. Mirrors TS `UiSchemaKind`.
enum UiSchemaKind {
  form,
  list,
  detail,
  section,
  grid,
  custom,
}

/// Field type discriminator. Mirrors TS `FieldType`.
///
/// Maps 1:1 onto components in the default resolver ([field_resolver.dart]).
/// Component-specific knobs live on the [FieldNode] itself rather than
/// expanding this enum.
enum FieldType {
  input,
  textarea,
  select,
  number,
  date,
  toggle,
  checkbox,
  email,
  password,
  url,
  tel,
}

/// Option entry for `select` fields. Mirrors the inline
/// `{ value: string; label: string }` shape on `FieldNode.options`.
@freezed
class FieldOption with _$FieldOption {
  const factory FieldOption({
    required String value,
    required String label,
  }) = _FieldOption;

  factory FieldOption.fromJson(Map<String, dynamic> json) =>
      _$FieldOptionFromJson(json);
}

/// A single field in a form/detail schema. Mirrors TS `FieldNode`.
///
/// Fields are flat (no children) — group via `section` schemas instead.
/// `options` is either an inline list ([List<FieldOption>]) or a [DataSource]
/// (ADR-002 4-layer source). freezed cannot model the discriminated union at
/// the field level, so both shapes are exposed and the renderer picks the
/// non-null one at runtime.
@freezed
class FieldNode with _$FieldNode {
  @JsonSerializable(explicitToJson: true)
  const factory FieldNode({
    /// Field name. Unique within the schema. Required.
    required String name,

    /// Optional label rendered above (vertical) or beside (horizontal).
    String? label,

    /// Component discriminator. Defaults to [FieldType.input] when null.
    FieldType? type,

    /// Placeholder string forwarded to the underlying input.
    String? placeholder,

    /// Required marker; also added to validation rules at submit time.
    @Default(false) bool required,

    /// Disabled when true; honored by every field renderer.
    @Default(false) bool disabled,

    /// Inline hint shown below the field.
    String? hint,

    /// Inline options for `'select'` fields.
    @Default([]) List<FieldOption> options,

    /// External data source for options (mutually exclusive with [options]).
    DataSource? optionsSource,

    /// `number` min, or string min-length depending on `type`.
    num? min,

    /// `number` max, or string max-length depending on `type`.
    num? max,

    /// Regex source string for `pattern` validation.
    String? pattern,

    /// Validation rules (additional to required/min/max/pattern).
    ///
    /// Excluded from JSON (the [ValidationRule] type carries a function field
    /// `fn` that is not serializable). Consumers wire rules in Dart code.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default([])
    List<ValidationRule> validation,
  }) = _FieldNode;

  factory FieldNode.fromJson(Map<String, dynamic> json) =>
      _$FieldNodeFromJson(json);
}

/// A button or action link rendered by `'form'` / `'detail'` schemas.
/// Mirrors TS `UiAction`.
@freezed
class UiAction with _$UiAction {
  const factory UiAction({
    /// Stable id, echoed in `onAction(name, values)`.
    required String name,

    /// Label shown on the button. Defaults to a humanised `name`.
    String? label,

    /// Visual variant. Defaults to [ComponentVariant.primary] for submit.
    ComponentVariant? variant,

    /// When true the submit handler is invoked (form schemas only).
    @Default(false) bool submit,

    /// Disabled flag.
    @Default(false) bool disabled,
  }) = _UiAction;

  factory UiAction.fromJson(Map<String, dynamic> json) =>
      _$UiActionFromJson(json);
}

/// Column definition for `'list'` schemas. Mirrors the inline
/// `columns_def` array entry type on [UiSchema].
@freezed
class ColumnDef with _$ColumnDef {
  const factory ColumnDef({
    required String key,
    required String label,
    @Default(false) bool sortable,
    @Default(false) bool filterable,
    String? width,
    @Default(ColumnAlign.left) ColumnAlign align,
  }) = _ColumnDef;

  factory ColumnDef.fromJson(Map<String, dynamic> json) =>
      _$ColumnDefFromJson(json);
}

/// Cell text alignment for [ColumnDef].
enum ColumnAlign { left, center, right }

/// Form layout mode. Mirrors TS `'vertical' | 'horizontal'`.
enum FormLayout { vertical, horizontal }

/// The schema document itself. Mirrors TS `UiSchema`.
///
/// A schema is either a "leaf" (`form` / `list` / `detail` / `custom`) or a
/// "grouping" (`section` / `grid`) that holds nested schemas via [sections].
@freezed
class UiSchema with _$UiSchema {
  @JsonSerializable(explicitToJson: true)
  const factory UiSchema({
    /// Schema kind discriminator. Required.
    required UiSchemaKind type,

    /// Stable id (debugging + DOM targeting via `data-bc-schema`).
    String? name,

    /// Title shown above sections / forms.
    String? title,

    /// Description shown under the title.
    String? description,

    // Form / detail
    /// Fields rendered inside a `'form'` / `'detail'` schema.
    @Default([]) List<FieldNode> fields,

    /// Layout mode forwarded to BcForm. Defaults to [FormLayout.vertical].
    @Default(FormLayout.vertical) FormLayout layout,

    // Grouping (section / grid)
    /// Nested schemas for `'section'` / `'grid'` kinds.
    @Default([]) List<UiSchema> sections,

    /// Number of columns for `'grid'` kind. Ignored otherwise. Defaults to 2.
    @Default(2) int columns,

    // List
    /// Columns for `'list'` schemas. Forwarded to BcDataTable.
    @Default([]) List<ColumnDef> columnsDef,

    /// Inline data source for `'list'` schemas.
    @Default([]) List<dynamic> data,

    /// External data source for `'list'` schemas (4-layer per ADR-002).
    DataSource? source,

    /// Page size for `'list'` schemas.
    int? pageSize,

    // Reactivity (ADR-004)
    /// Reactions wired into a [ReactiveStore] wrapping the rendered subtree.
    ///
    /// Excluded from JSON (reactions carry function effects that are not
    /// serializable). Consumers wire reactions in Dart code.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default([])
    List<Reaction> reactions,

    // Form actions
    /// Buttons rendered below the fields of a `'form'` / `'detail'` schema.
    @Default([]) List<UiAction> actions,

    // Custom escape hatch
    /// JSON payload for `'custom'` schemas (DOM portal / pre-processing).
    Object? payload,
  }) = _UiSchema;

  factory UiSchema.fromJson(Map<String, dynamic> json) =>
      _$UiSchemaFromJson(json);
}

/// Top-level renderer props. Mirrors TS `BcRendererProps`.
///
/// The simplest schema (`type: 'form'`) drops in next to existing forms with
/// zero extra wiring. Callbacks are typed as function fields (not freezed
/// class fields) so they stay nullable + non-serialized.
class BcRendererProps {
  final UiSchema? schema;
  final Map<String, dynamic> values;
  final bool disabled;

  /// Fired whenever any field value changes (form mode).
  final void Function(Map<String, dynamic> values)? onChange;

  /// Fired when a `submit: true` action runs and validation passes.
  final void Function(Map<String, dynamic> values)? onSubmit;

  /// Fired when any non-submit action button is clicked.
  final void Function(String name, Map<String, dynamic> values)? onAction;

  const BcRendererProps({
    this.schema,
    this.values = const {},
    this.disabled = false,
    this.onChange,
    this.onSubmit,
    this.onAction,
  });

  /// Returns a copy with the provided fields replaced.
  BcRendererProps copyWith({
    UiSchema? schema,
    Map<String, dynamic>? values,
    bool? disabled,
    void Function(Map<String, dynamic> values)? onChange,
    void Function(Map<String, dynamic> values)? onSubmit,
    void Function(String name, Map<String, dynamic> values)? onAction,
  }) {
    return BcRendererProps(
      schema: schema ?? this.schema,
      values: values ?? this.values,
      disabled: disabled ?? this.disabled,
      onChange: onChange ?? this.onChange,
      onSubmit: onSubmit ?? this.onSubmit,
      onAction: onAction ?? this.onAction,
    );
  }
}
