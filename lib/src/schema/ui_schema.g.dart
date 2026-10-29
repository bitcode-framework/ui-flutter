// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FieldOptionImpl _$$FieldOptionImplFromJson(Map<String, dynamic> json) =>
    _$FieldOptionImpl(
      value: json['value'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$$FieldOptionImplToJson(_$FieldOptionImpl instance) =>
    <String, dynamic>{'value': instance.value, 'label': instance.label};

_$FieldNodeImpl _$$FieldNodeImplFromJson(Map<String, dynamic> json) =>
    _$FieldNodeImpl(
      name: json['name'] as String,
      label: json['label'] as String?,
      type: $enumDecodeNullable(_$FieldTypeEnumMap, json['type']),
      placeholder: json['placeholder'] as String?,
      required: json['required'] as bool? ?? false,
      disabled: json['disabled'] as bool? ?? false,
      hint: json['hint'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => FieldOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      optionsSource: json['optionsSource'] == null
          ? null
          : DataSource.fromJson(json['optionsSource'] as Map<String, dynamic>),
      min: json['min'] as num?,
      max: json['max'] as num?,
      pattern: json['pattern'] as String?,
    );

Map<String, dynamic> _$$FieldNodeImplToJson(_$FieldNodeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'label': instance.label,
      'type': _$FieldTypeEnumMap[instance.type],
      'placeholder': instance.placeholder,
      'required': instance.required,
      'disabled': instance.disabled,
      'hint': instance.hint,
      'options': instance.options.map((e) => e.toJson()).toList(),
      'optionsSource': instance.optionsSource?.toJson(),
      'min': instance.min,
      'max': instance.max,
      'pattern': instance.pattern,
    };

const _$FieldTypeEnumMap = {
  FieldType.input: 'input',
  FieldType.textarea: 'textarea',
  FieldType.select: 'select',
  FieldType.number: 'number',
  FieldType.date: 'date',
  FieldType.toggle: 'toggle',
  FieldType.checkbox: 'checkbox',
  FieldType.email: 'email',
  FieldType.password: 'password',
  FieldType.url: 'url',
  FieldType.tel: 'tel',
};

_$UiActionImpl _$$UiActionImplFromJson(Map<String, dynamic> json) =>
    _$UiActionImpl(
      name: json['name'] as String,
      label: json['label'] as String?,
      variant: $enumDecodeNullable(_$ComponentVariantEnumMap, json['variant']),
      submit: json['submit'] as bool? ?? false,
      disabled: json['disabled'] as bool? ?? false,
    );

Map<String, dynamic> _$$UiActionImplToJson(_$UiActionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'label': instance.label,
      'variant': _$ComponentVariantEnumMap[instance.variant],
      'submit': instance.submit,
      'disabled': instance.disabled,
    };

const _$ComponentVariantEnumMap = {
  ComponentVariant.defaultVariant: 'defaultVariant',
  ComponentVariant.primary: 'primary',
  ComponentVariant.secondary: 'secondary',
  ComponentVariant.destructive: 'destructive',
  ComponentVariant.outline: 'outline',
  ComponentVariant.ghost: 'ghost',
  ComponentVariant.link: 'link',
};

_$ColumnDefImpl _$$ColumnDefImplFromJson(Map<String, dynamic> json) =>
    _$ColumnDefImpl(
      key: json['key'] as String,
      label: json['label'] as String,
      sortable: json['sortable'] as bool? ?? false,
      filterable: json['filterable'] as bool? ?? false,
      width: json['width'] as String?,
      align:
          $enumDecodeNullable(_$ColumnAlignEnumMap, json['align']) ??
          ColumnAlign.left,
    );

Map<String, dynamic> _$$ColumnDefImplToJson(_$ColumnDefImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'sortable': instance.sortable,
      'filterable': instance.filterable,
      'width': instance.width,
      'align': _$ColumnAlignEnumMap[instance.align]!,
    };

const _$ColumnAlignEnumMap = {
  ColumnAlign.left: 'left',
  ColumnAlign.center: 'center',
  ColumnAlign.right: 'right',
};

_$UiSchemaImpl _$$UiSchemaImplFromJson(Map<String, dynamic> json) =>
    _$UiSchemaImpl(
      type: $enumDecode(_$UiSchemaKindEnumMap, json['type']),
      name: json['name'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => FieldNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      layout:
          $enumDecodeNullable(_$FormLayoutEnumMap, json['layout']) ??
          FormLayout.vertical,
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => UiSchema.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      columns: (json['columns'] as num?)?.toInt() ?? 2,
      columnsDef:
          (json['columnsDef'] as List<dynamic>?)
              ?.map((e) => ColumnDef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      data: json['data'] as List<dynamic>? ?? const [],
      source: json['source'] == null
          ? null
          : DataSource.fromJson(json['source'] as Map<String, dynamic>),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => UiAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      payload: json['payload'],
    );

Map<String, dynamic> _$$UiSchemaImplToJson(_$UiSchemaImpl instance) =>
    <String, dynamic>{
      'type': _$UiSchemaKindEnumMap[instance.type]!,
      'name': instance.name,
      'title': instance.title,
      'description': instance.description,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'layout': _$FormLayoutEnumMap[instance.layout]!,
      'sections': instance.sections.map((e) => e.toJson()).toList(),
      'columns': instance.columns,
      'columnsDef': instance.columnsDef.map((e) => e.toJson()).toList(),
      'data': instance.data,
      'source': instance.source?.toJson(),
      'pageSize': instance.pageSize,
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'payload': instance.payload,
    };

const _$UiSchemaKindEnumMap = {
  UiSchemaKind.form: 'form',
  UiSchemaKind.list: 'list',
  UiSchemaKind.detail: 'detail',
  UiSchemaKind.section: 'section',
  UiSchemaKind.grid: 'grid',
  UiSchemaKind.custom: 'custom',
};

const _$FormLayoutEnumMap = {
  FormLayout.vertical: 'vertical',
  FormLayout.horizontal: 'horizontal',
};
