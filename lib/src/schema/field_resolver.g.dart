// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_resolver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResolvedFormFieldImpl _$$ResolvedFormFieldImplFromJson(
  Map<String, dynamic> json,
) => _$ResolvedFormFieldImpl(
  name: json['name'] as String,
  label: json['label'] as String?,
  type: json['type'] as String,
  placeholder: json['placeholder'] as String?,
  required: json['required'] as bool? ?? false,
  disabled: json['disabled'] as bool? ?? false,
  hint: json['hint'] as String?,
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => FieldOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  min: json['min'] as num?,
  max: json['max'] as num?,
  pattern: json['pattern'] as String?,
);

Map<String, dynamic> _$$ResolvedFormFieldImplToJson(
  _$ResolvedFormFieldImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'label': instance.label,
  'type': instance.type,
  'placeholder': instance.placeholder,
  'required': instance.required,
  'disabled': instance.disabled,
  'hint': instance.hint,
  'options': instance.options,
  'min': instance.min,
  'max': instance.max,
  'pattern': instance.pattern,
};
