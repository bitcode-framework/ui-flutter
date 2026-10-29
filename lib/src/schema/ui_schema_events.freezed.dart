// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_schema_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BcEventBase _$BcEventBaseFromJson(Map<String, dynamic> json) {
  return _BcEventBase.fromJson(json);
}

/// @nodoc
mixin _$BcEventBase {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;

  /// Serializes this BcEventBase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BcEventBase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BcEventBaseCopyWith<BcEventBase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BcEventBaseCopyWith<$Res> {
  factory $BcEventBaseCopyWith(
    BcEventBase value,
    $Res Function(BcEventBase) then,
  ) = _$BcEventBaseCopyWithImpl<$Res, BcEventBase>;
  @useResult
  $Res call({String name, int timestamp});
}

/// @nodoc
class _$BcEventBaseCopyWithImpl<$Res, $Val extends BcEventBase>
    implements $BcEventBaseCopyWith<$Res> {
  _$BcEventBaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BcEventBase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BcEventBaseImplCopyWith<$Res>
    implements $BcEventBaseCopyWith<$Res> {
  factory _$$BcEventBaseImplCopyWith(
    _$BcEventBaseImpl value,
    $Res Function(_$BcEventBaseImpl) then,
  ) = __$$BcEventBaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int timestamp});
}

/// @nodoc
class __$$BcEventBaseImplCopyWithImpl<$Res>
    extends _$BcEventBaseCopyWithImpl<$Res, _$BcEventBaseImpl>
    implements _$$BcEventBaseImplCopyWith<$Res> {
  __$$BcEventBaseImplCopyWithImpl(
    _$BcEventBaseImpl _value,
    $Res Function(_$BcEventBaseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BcEventBase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? timestamp = null}) {
    return _then(
      _$BcEventBaseImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BcEventBaseImpl implements _BcEventBase {
  const _$BcEventBaseImpl({required this.name, required this.timestamp});

  factory _$BcEventBaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BcEventBaseImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;

  @override
  String toString() {
    return 'BcEventBase(name: $name, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BcEventBaseImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, timestamp);

  /// Create a copy of BcEventBase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BcEventBaseImplCopyWith<_$BcEventBaseImpl> get copyWith =>
      __$$BcEventBaseImplCopyWithImpl<_$BcEventBaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BcEventBaseImplToJson(this);
  }
}

abstract class _BcEventBase implements BcEventBase {
  const factory _BcEventBase({
    required final String name,
    required final int timestamp,
  }) = _$BcEventBaseImpl;

  factory _BcEventBase.fromJson(Map<String, dynamic> json) =
      _$BcEventBaseImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;

  /// Create a copy of BcEventBase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BcEventBaseImplCopyWith<_$BcEventBaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldChangeEvent _$FieldChangeEventFromJson(Map<String, dynamic> json) {
  return _FieldChangeEvent.fromJson(json);
}

/// @nodoc
mixin _$FieldChangeEvent {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  Object? get value => throw _privateConstructorUsedError;
  Object? get oldValue => throw _privateConstructorUsedError;

  /// Serializes this FieldChangeEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldChangeEventCopyWith<FieldChangeEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldChangeEventCopyWith<$Res> {
  factory $FieldChangeEventCopyWith(
    FieldChangeEvent value,
    $Res Function(FieldChangeEvent) then,
  ) = _$FieldChangeEventCopyWithImpl<$Res, FieldChangeEvent>;
  @useResult
  $Res call({String name, int timestamp, Object? value, Object? oldValue});
}

/// @nodoc
class _$FieldChangeEventCopyWithImpl<$Res, $Val extends FieldChangeEvent>
    implements $FieldChangeEventCopyWith<$Res> {
  _$FieldChangeEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? oldValue = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            value: freezed == value ? _value.value : value,
            oldValue: freezed == oldValue ? _value.oldValue : oldValue,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldChangeEventImplCopyWith<$Res>
    implements $FieldChangeEventCopyWith<$Res> {
  factory _$$FieldChangeEventImplCopyWith(
    _$FieldChangeEventImpl value,
    $Res Function(_$FieldChangeEventImpl) then,
  ) = __$$FieldChangeEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int timestamp, Object? value, Object? oldValue});
}

/// @nodoc
class __$$FieldChangeEventImplCopyWithImpl<$Res>
    extends _$FieldChangeEventCopyWithImpl<$Res, _$FieldChangeEventImpl>
    implements _$$FieldChangeEventImplCopyWith<$Res> {
  __$$FieldChangeEventImplCopyWithImpl(
    _$FieldChangeEventImpl _value,
    $Res Function(_$FieldChangeEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? oldValue = freezed,
  }) {
    return _then(
      _$FieldChangeEventImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        value: freezed == value ? _value.value : value,
        oldValue: freezed == oldValue ? _value.oldValue : oldValue,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldChangeEventImpl implements _FieldChangeEvent {
  const _$FieldChangeEventImpl({
    required this.name,
    required this.timestamp,
    required this.value,
    required this.oldValue,
  });

  factory _$FieldChangeEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldChangeEventImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;
  @override
  final Object? value;
  @override
  final Object? oldValue;

  @override
  String toString() {
    return 'FieldChangeEvent(name: $name, timestamp: $timestamp, value: $value, oldValue: $oldValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldChangeEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            const DeepCollectionEquality().equals(other.oldValue, oldValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    timestamp,
    const DeepCollectionEquality().hash(value),
    const DeepCollectionEquality().hash(oldValue),
  );

  /// Create a copy of FieldChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldChangeEventImplCopyWith<_$FieldChangeEventImpl> get copyWith =>
      __$$FieldChangeEventImplCopyWithImpl<_$FieldChangeEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldChangeEventImplToJson(this);
  }
}

abstract class _FieldChangeEvent implements FieldChangeEvent {
  const factory _FieldChangeEvent({
    required final String name,
    required final int timestamp,
    required final Object? value,
    required final Object? oldValue,
  }) = _$FieldChangeEventImpl;

  factory _FieldChangeEvent.fromJson(Map<String, dynamic> json) =
      _$FieldChangeEventImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;
  @override
  Object? get value;
  @override
  Object? get oldValue;

  /// Create a copy of FieldChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldChangeEventImplCopyWith<_$FieldChangeEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldFocusEvent _$FieldFocusEventFromJson(Map<String, dynamic> json) {
  return _FieldFocusEvent.fromJson(json);
}

/// @nodoc
mixin _$FieldFocusEvent {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  Object? get value => throw _privateConstructorUsedError;

  /// Serializes this FieldFocusEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldFocusEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldFocusEventCopyWith<FieldFocusEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldFocusEventCopyWith<$Res> {
  factory $FieldFocusEventCopyWith(
    FieldFocusEvent value,
    $Res Function(FieldFocusEvent) then,
  ) = _$FieldFocusEventCopyWithImpl<$Res, FieldFocusEvent>;
  @useResult
  $Res call({String name, int timestamp, Object? value});
}

/// @nodoc
class _$FieldFocusEventCopyWithImpl<$Res, $Val extends FieldFocusEvent>
    implements $FieldFocusEventCopyWith<$Res> {
  _$FieldFocusEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldFocusEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            value: freezed == value ? _value.value : value,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldFocusEventImplCopyWith<$Res>
    implements $FieldFocusEventCopyWith<$Res> {
  factory _$$FieldFocusEventImplCopyWith(
    _$FieldFocusEventImpl value,
    $Res Function(_$FieldFocusEventImpl) then,
  ) = __$$FieldFocusEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int timestamp, Object? value});
}

/// @nodoc
class __$$FieldFocusEventImplCopyWithImpl<$Res>
    extends _$FieldFocusEventCopyWithImpl<$Res, _$FieldFocusEventImpl>
    implements _$$FieldFocusEventImplCopyWith<$Res> {
  __$$FieldFocusEventImplCopyWithImpl(
    _$FieldFocusEventImpl _value,
    $Res Function(_$FieldFocusEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldFocusEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
  }) {
    return _then(
      _$FieldFocusEventImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        value: freezed == value ? _value.value : value,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldFocusEventImpl implements _FieldFocusEvent {
  const _$FieldFocusEventImpl({
    required this.name,
    required this.timestamp,
    required this.value,
  });

  factory _$FieldFocusEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldFocusEventImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;
  @override
  final Object? value;

  @override
  String toString() {
    return 'FieldFocusEvent(name: $name, timestamp: $timestamp, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldFocusEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    timestamp,
    const DeepCollectionEquality().hash(value),
  );

  /// Create a copy of FieldFocusEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldFocusEventImplCopyWith<_$FieldFocusEventImpl> get copyWith =>
      __$$FieldFocusEventImplCopyWithImpl<_$FieldFocusEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldFocusEventImplToJson(this);
  }
}

abstract class _FieldFocusEvent implements FieldFocusEvent {
  const factory _FieldFocusEvent({
    required final String name,
    required final int timestamp,
    required final Object? value,
  }) = _$FieldFocusEventImpl;

  factory _FieldFocusEvent.fromJson(Map<String, dynamic> json) =
      _$FieldFocusEventImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;
  @override
  Object? get value;

  /// Create a copy of FieldFocusEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldFocusEventImplCopyWith<_$FieldFocusEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldBlurEvent _$FieldBlurEventFromJson(Map<String, dynamic> json) {
  return _FieldBlurEvent.fromJson(json);
}

/// @nodoc
mixin _$FieldBlurEvent {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  Object? get value => throw _privateConstructorUsedError;
  bool get dirty => throw _privateConstructorUsedError;
  bool get touched => throw _privateConstructorUsedError;

  /// Serializes this FieldBlurEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldBlurEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldBlurEventCopyWith<FieldBlurEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldBlurEventCopyWith<$Res> {
  factory $FieldBlurEventCopyWith(
    FieldBlurEvent value,
    $Res Function(FieldBlurEvent) then,
  ) = _$FieldBlurEventCopyWithImpl<$Res, FieldBlurEvent>;
  @useResult
  $Res call({
    String name,
    int timestamp,
    Object? value,
    bool dirty,
    bool touched,
  });
}

/// @nodoc
class _$FieldBlurEventCopyWithImpl<$Res, $Val extends FieldBlurEvent>
    implements $FieldBlurEventCopyWith<$Res> {
  _$FieldBlurEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldBlurEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? dirty = null,
    Object? touched = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            value: freezed == value ? _value.value : value,
            dirty: null == dirty
                ? _value.dirty
                : dirty // ignore: cast_nullable_to_non_nullable
                      as bool,
            touched: null == touched
                ? _value.touched
                : touched // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldBlurEventImplCopyWith<$Res>
    implements $FieldBlurEventCopyWith<$Res> {
  factory _$$FieldBlurEventImplCopyWith(
    _$FieldBlurEventImpl value,
    $Res Function(_$FieldBlurEventImpl) then,
  ) = __$$FieldBlurEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int timestamp,
    Object? value,
    bool dirty,
    bool touched,
  });
}

/// @nodoc
class __$$FieldBlurEventImplCopyWithImpl<$Res>
    extends _$FieldBlurEventCopyWithImpl<$Res, _$FieldBlurEventImpl>
    implements _$$FieldBlurEventImplCopyWith<$Res> {
  __$$FieldBlurEventImplCopyWithImpl(
    _$FieldBlurEventImpl _value,
    $Res Function(_$FieldBlurEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldBlurEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? dirty = null,
    Object? touched = null,
  }) {
    return _then(
      _$FieldBlurEventImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        value: freezed == value ? _value.value : value,
        dirty: null == dirty
            ? _value.dirty
            : dirty // ignore: cast_nullable_to_non_nullable
                  as bool,
        touched: null == touched
            ? _value.touched
            : touched // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldBlurEventImpl implements _FieldBlurEvent {
  const _$FieldBlurEventImpl({
    required this.name,
    required this.timestamp,
    required this.value,
    this.dirty = false,
    this.touched = false,
  });

  factory _$FieldBlurEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldBlurEventImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;
  @override
  final Object? value;
  @override
  @JsonKey()
  final bool dirty;
  @override
  @JsonKey()
  final bool touched;

  @override
  String toString() {
    return 'FieldBlurEvent(name: $name, timestamp: $timestamp, value: $value, dirty: $dirty, touched: $touched)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldBlurEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.dirty, dirty) || other.dirty == dirty) &&
            (identical(other.touched, touched) || other.touched == touched));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    timestamp,
    const DeepCollectionEquality().hash(value),
    dirty,
    touched,
  );

  /// Create a copy of FieldBlurEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldBlurEventImplCopyWith<_$FieldBlurEventImpl> get copyWith =>
      __$$FieldBlurEventImplCopyWithImpl<_$FieldBlurEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldBlurEventImplToJson(this);
  }
}

abstract class _FieldBlurEvent implements FieldBlurEvent {
  const factory _FieldBlurEvent({
    required final String name,
    required final int timestamp,
    required final Object? value,
    final bool dirty,
    final bool touched,
  }) = _$FieldBlurEventImpl;

  factory _FieldBlurEvent.fromJson(Map<String, dynamic> json) =
      _$FieldBlurEventImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;
  @override
  Object? get value;
  @override
  bool get dirty;
  @override
  bool get touched;

  /// Create a copy of FieldBlurEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldBlurEventImplCopyWith<_$FieldBlurEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldClearEvent _$FieldClearEventFromJson(Map<String, dynamic> json) {
  return _FieldClearEvent.fromJson(json);
}

/// @nodoc
mixin _$FieldClearEvent {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  Object? get oldValue => throw _privateConstructorUsedError;

  /// Serializes this FieldClearEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldClearEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldClearEventCopyWith<FieldClearEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldClearEventCopyWith<$Res> {
  factory $FieldClearEventCopyWith(
    FieldClearEvent value,
    $Res Function(FieldClearEvent) then,
  ) = _$FieldClearEventCopyWithImpl<$Res, FieldClearEvent>;
  @useResult
  $Res call({String name, int timestamp, Object? oldValue});
}

/// @nodoc
class _$FieldClearEventCopyWithImpl<$Res, $Val extends FieldClearEvent>
    implements $FieldClearEventCopyWith<$Res> {
  _$FieldClearEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldClearEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? oldValue = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            oldValue: freezed == oldValue ? _value.oldValue : oldValue,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldClearEventImplCopyWith<$Res>
    implements $FieldClearEventCopyWith<$Res> {
  factory _$$FieldClearEventImplCopyWith(
    _$FieldClearEventImpl value,
    $Res Function(_$FieldClearEventImpl) then,
  ) = __$$FieldClearEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int timestamp, Object? oldValue});
}

/// @nodoc
class __$$FieldClearEventImplCopyWithImpl<$Res>
    extends _$FieldClearEventCopyWithImpl<$Res, _$FieldClearEventImpl>
    implements _$$FieldClearEventImplCopyWith<$Res> {
  __$$FieldClearEventImplCopyWithImpl(
    _$FieldClearEventImpl _value,
    $Res Function(_$FieldClearEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldClearEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? oldValue = freezed,
  }) {
    return _then(
      _$FieldClearEventImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        oldValue: freezed == oldValue ? _value.oldValue : oldValue,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldClearEventImpl implements _FieldClearEvent {
  const _$FieldClearEventImpl({
    required this.name,
    required this.timestamp,
    required this.oldValue,
  });

  factory _$FieldClearEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldClearEventImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;
  @override
  final Object? oldValue;

  @override
  String toString() {
    return 'FieldClearEvent(name: $name, timestamp: $timestamp, oldValue: $oldValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldClearEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other.oldValue, oldValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    timestamp,
    const DeepCollectionEquality().hash(oldValue),
  );

  /// Create a copy of FieldClearEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldClearEventImplCopyWith<_$FieldClearEventImpl> get copyWith =>
      __$$FieldClearEventImplCopyWithImpl<_$FieldClearEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldClearEventImplToJson(this);
  }
}

abstract class _FieldClearEvent implements FieldClearEvent {
  const factory _FieldClearEvent({
    required final String name,
    required final int timestamp,
    required final Object? oldValue,
  }) = _$FieldClearEventImpl;

  factory _FieldClearEvent.fromJson(Map<String, dynamic> json) =
      _$FieldClearEventImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;
  @override
  Object? get oldValue;

  /// Create a copy of FieldClearEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldClearEventImplCopyWith<_$FieldClearEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldInputEvent _$FieldInputEventFromJson(Map<String, dynamic> json) {
  return _FieldInputEvent.fromJson(json);
}

/// @nodoc
mixin _$FieldInputEvent {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  Object? get value => throw _privateConstructorUsedError;

  /// Serializes this FieldInputEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldInputEventCopyWith<FieldInputEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldInputEventCopyWith<$Res> {
  factory $FieldInputEventCopyWith(
    FieldInputEvent value,
    $Res Function(FieldInputEvent) then,
  ) = _$FieldInputEventCopyWithImpl<$Res, FieldInputEvent>;
  @useResult
  $Res call({String name, int timestamp, Object? value});
}

/// @nodoc
class _$FieldInputEventCopyWithImpl<$Res, $Val extends FieldInputEvent>
    implements $FieldInputEventCopyWith<$Res> {
  _$FieldInputEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            value: freezed == value ? _value.value : value,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldInputEventImplCopyWith<$Res>
    implements $FieldInputEventCopyWith<$Res> {
  factory _$$FieldInputEventImplCopyWith(
    _$FieldInputEventImpl value,
    $Res Function(_$FieldInputEventImpl) then,
  ) = __$$FieldInputEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int timestamp, Object? value});
}

/// @nodoc
class __$$FieldInputEventImplCopyWithImpl<$Res>
    extends _$FieldInputEventCopyWithImpl<$Res, _$FieldInputEventImpl>
    implements _$$FieldInputEventImplCopyWith<$Res> {
  __$$FieldInputEventImplCopyWithImpl(
    _$FieldInputEventImpl _value,
    $Res Function(_$FieldInputEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
  }) {
    return _then(
      _$FieldInputEventImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        value: freezed == value ? _value.value : value,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldInputEventImpl implements _FieldInputEvent {
  const _$FieldInputEventImpl({
    required this.name,
    required this.timestamp,
    required this.value,
  });

  factory _$FieldInputEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldInputEventImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;
  @override
  final Object? value;

  @override
  String toString() {
    return 'FieldInputEvent(name: $name, timestamp: $timestamp, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldInputEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    timestamp,
    const DeepCollectionEquality().hash(value),
  );

  /// Create a copy of FieldInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldInputEventImplCopyWith<_$FieldInputEventImpl> get copyWith =>
      __$$FieldInputEventImplCopyWithImpl<_$FieldInputEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldInputEventImplToJson(this);
  }
}

abstract class _FieldInputEvent implements FieldInputEvent {
  const factory _FieldInputEvent({
    required final String name,
    required final int timestamp,
    required final Object? value,
  }) = _$FieldInputEventImpl;

  factory _FieldInputEvent.fromJson(Map<String, dynamic> json) =
      _$FieldInputEventImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;
  @override
  Object? get value;

  /// Create a copy of FieldInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldInputEventImplCopyWith<_$FieldInputEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldKeyEvent _$FieldKeyEventFromJson(Map<String, dynamic> json) {
  return _FieldKeyEvent.fromJson(json);
}

/// @nodoc
mixin _$FieldKeyEvent {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  Object? get value => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;

  /// Serializes this FieldKeyEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldKeyEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldKeyEventCopyWith<FieldKeyEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldKeyEventCopyWith<$Res> {
  factory $FieldKeyEventCopyWith(
    FieldKeyEvent value,
    $Res Function(FieldKeyEvent) then,
  ) = _$FieldKeyEventCopyWithImpl<$Res, FieldKeyEvent>;
  @useResult
  $Res call({String name, int timestamp, Object? value, String key});
}

/// @nodoc
class _$FieldKeyEventCopyWithImpl<$Res, $Val extends FieldKeyEvent>
    implements $FieldKeyEventCopyWith<$Res> {
  _$FieldKeyEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldKeyEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? key = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            value: freezed == value ? _value.value : value,
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldKeyEventImplCopyWith<$Res>
    implements $FieldKeyEventCopyWith<$Res> {
  factory _$$FieldKeyEventImplCopyWith(
    _$FieldKeyEventImpl value,
    $Res Function(_$FieldKeyEventImpl) then,
  ) = __$$FieldKeyEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int timestamp, Object? value, String key});
}

/// @nodoc
class __$$FieldKeyEventImplCopyWithImpl<$Res>
    extends _$FieldKeyEventCopyWithImpl<$Res, _$FieldKeyEventImpl>
    implements _$$FieldKeyEventImplCopyWith<$Res> {
  __$$FieldKeyEventImplCopyWithImpl(
    _$FieldKeyEventImpl _value,
    $Res Function(_$FieldKeyEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldKeyEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? key = null,
  }) {
    return _then(
      _$FieldKeyEventImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        value: freezed == value ? _value.value : value,
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldKeyEventImpl implements _FieldKeyEvent {
  const _$FieldKeyEventImpl({
    required this.name,
    required this.timestamp,
    required this.value,
    required this.key,
  });

  factory _$FieldKeyEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldKeyEventImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;
  @override
  final Object? value;
  @override
  final String key;

  @override
  String toString() {
    return 'FieldKeyEvent(name: $name, timestamp: $timestamp, value: $value, key: $key)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldKeyEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.key, key) || other.key == key));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    timestamp,
    const DeepCollectionEquality().hash(value),
    key,
  );

  /// Create a copy of FieldKeyEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldKeyEventImplCopyWith<_$FieldKeyEventImpl> get copyWith =>
      __$$FieldKeyEventImplCopyWithImpl<_$FieldKeyEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldKeyEventImplToJson(this);
  }
}

abstract class _FieldKeyEvent implements FieldKeyEvent {
  const factory _FieldKeyEvent({
    required final String name,
    required final int timestamp,
    required final Object? value,
    required final String key,
  }) = _$FieldKeyEventImpl;

  factory _FieldKeyEvent.fromJson(Map<String, dynamic> json) =
      _$FieldKeyEventImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;
  @override
  Object? get value;
  @override
  String get key;

  /// Create a copy of FieldKeyEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldKeyEventImplCopyWith<_$FieldKeyEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldValidateEvent _$FieldValidateEventFromJson(Map<String, dynamic> json) {
  return _FieldValidateEvent.fromJson(json);
}

/// @nodoc
mixin _$FieldValidateEvent {
  String get name => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  Object? get value => throw _privateConstructorUsedError;
  bool get valid => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this FieldValidateEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldValidateEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldValidateEventCopyWith<FieldValidateEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldValidateEventCopyWith<$Res> {
  factory $FieldValidateEventCopyWith(
    FieldValidateEvent value,
    $Res Function(FieldValidateEvent) then,
  ) = _$FieldValidateEventCopyWithImpl<$Res, FieldValidateEvent>;
  @useResult
  $Res call({
    String name,
    int timestamp,
    Object? value,
    bool valid,
    String message,
  });
}

/// @nodoc
class _$FieldValidateEventCopyWithImpl<$Res, $Val extends FieldValidateEvent>
    implements $FieldValidateEventCopyWith<$Res> {
  _$FieldValidateEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldValidateEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? valid = null,
    Object? message = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            value: freezed == value ? _value.value : value,
            valid: null == valid
                ? _value.valid
                : valid // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldValidateEventImplCopyWith<$Res>
    implements $FieldValidateEventCopyWith<$Res> {
  factory _$$FieldValidateEventImplCopyWith(
    _$FieldValidateEventImpl value,
    $Res Function(_$FieldValidateEventImpl) then,
  ) = __$$FieldValidateEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int timestamp,
    Object? value,
    bool valid,
    String message,
  });
}

/// @nodoc
class __$$FieldValidateEventImplCopyWithImpl<$Res>
    extends _$FieldValidateEventCopyWithImpl<$Res, _$FieldValidateEventImpl>
    implements _$$FieldValidateEventImplCopyWith<$Res> {
  __$$FieldValidateEventImplCopyWithImpl(
    _$FieldValidateEventImpl _value,
    $Res Function(_$FieldValidateEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldValidateEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? timestamp = null,
    Object? value = freezed,
    Object? valid = null,
    Object? message = null,
  }) {
    return _then(
      _$FieldValidateEventImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        value: freezed == value ? _value.value : value,
        valid: null == valid
            ? _value.valid
            : valid // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldValidateEventImpl implements _FieldValidateEvent {
  const _$FieldValidateEventImpl({
    required this.name,
    required this.timestamp,
    required this.value,
    this.valid = false,
    this.message = '',
  });

  factory _$FieldValidateEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldValidateEventImplFromJson(json);

  @override
  final String name;
  @override
  final int timestamp;
  @override
  final Object? value;
  @override
  @JsonKey()
  final bool valid;
  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'FieldValidateEvent(name: $name, timestamp: $timestamp, value: $value, valid: $valid, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldValidateEventImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.valid, valid) || other.valid == valid) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    timestamp,
    const DeepCollectionEquality().hash(value),
    valid,
    message,
  );

  /// Create a copy of FieldValidateEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldValidateEventImplCopyWith<_$FieldValidateEventImpl> get copyWith =>
      __$$FieldValidateEventImplCopyWithImpl<_$FieldValidateEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldValidateEventImplToJson(this);
  }
}

abstract class _FieldValidateEvent implements FieldValidateEvent {
  const factory _FieldValidateEvent({
    required final String name,
    required final int timestamp,
    required final Object? value,
    final bool valid,
    final String message,
  }) = _$FieldValidateEventImpl;

  factory _FieldValidateEvent.fromJson(Map<String, dynamic> json) =
      _$FieldValidateEventImpl.fromJson;

  @override
  String get name;
  @override
  int get timestamp;
  @override
  Object? get value;
  @override
  bool get valid;
  @override
  String get message;

  /// Create a copy of FieldValidateEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldValidateEventImplCopyWith<_$FieldValidateEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
