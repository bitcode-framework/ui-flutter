// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_schema_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BcEventBaseImpl _$$BcEventBaseImplFromJson(Map<String, dynamic> json) =>
    _$BcEventBaseImpl(
      name: json['name'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$$BcEventBaseImplToJson(_$BcEventBaseImpl instance) =>
    <String, dynamic>{'name': instance.name, 'timestamp': instance.timestamp};

_$FieldChangeEventImpl _$$FieldChangeEventImplFromJson(
  Map<String, dynamic> json,
) => _$FieldChangeEventImpl(
  name: json['name'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  value: json['value'],
  oldValue: json['oldValue'],
);

Map<String, dynamic> _$$FieldChangeEventImplToJson(
  _$FieldChangeEventImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'timestamp': instance.timestamp,
  'value': instance.value,
  'oldValue': instance.oldValue,
};

_$FieldFocusEventImpl _$$FieldFocusEventImplFromJson(
  Map<String, dynamic> json,
) => _$FieldFocusEventImpl(
  name: json['name'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  value: json['value'],
);

Map<String, dynamic> _$$FieldFocusEventImplToJson(
  _$FieldFocusEventImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'timestamp': instance.timestamp,
  'value': instance.value,
};

_$FieldBlurEventImpl _$$FieldBlurEventImplFromJson(Map<String, dynamic> json) =>
    _$FieldBlurEventImpl(
      name: json['name'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      value: json['value'],
      dirty: json['dirty'] as bool? ?? false,
      touched: json['touched'] as bool? ?? false,
    );

Map<String, dynamic> _$$FieldBlurEventImplToJson(
  _$FieldBlurEventImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'timestamp': instance.timestamp,
  'value': instance.value,
  'dirty': instance.dirty,
  'touched': instance.touched,
};

_$FieldClearEventImpl _$$FieldClearEventImplFromJson(
  Map<String, dynamic> json,
) => _$FieldClearEventImpl(
  name: json['name'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  oldValue: json['oldValue'],
);

Map<String, dynamic> _$$FieldClearEventImplToJson(
  _$FieldClearEventImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'timestamp': instance.timestamp,
  'oldValue': instance.oldValue,
};

_$FieldInputEventImpl _$$FieldInputEventImplFromJson(
  Map<String, dynamic> json,
) => _$FieldInputEventImpl(
  name: json['name'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  value: json['value'],
);

Map<String, dynamic> _$$FieldInputEventImplToJson(
  _$FieldInputEventImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'timestamp': instance.timestamp,
  'value': instance.value,
};

_$FieldKeyEventImpl _$$FieldKeyEventImplFromJson(Map<String, dynamic> json) =>
    _$FieldKeyEventImpl(
      name: json['name'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      value: json['value'],
      key: json['key'] as String,
    );

Map<String, dynamic> _$$FieldKeyEventImplToJson(_$FieldKeyEventImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'timestamp': instance.timestamp,
      'value': instance.value,
      'key': instance.key,
    };

_$FieldValidateEventImpl _$$FieldValidateEventImplFromJson(
  Map<String, dynamic> json,
) => _$FieldValidateEventImpl(
  name: json['name'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  value: json['value'],
  valid: json['valid'] as bool? ?? false,
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$$FieldValidateEventImplToJson(
  _$FieldValidateEventImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'timestamp': instance.timestamp,
  'value': instance.value,
  'valid': instance.valid,
  'message': instance.message,
};
