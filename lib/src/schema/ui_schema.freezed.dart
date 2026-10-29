// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_schema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FieldOption _$FieldOptionFromJson(Map<String, dynamic> json) {
  return _FieldOption.fromJson(json);
}

/// @nodoc
mixin _$FieldOption {
  String get value => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this FieldOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldOptionCopyWith<FieldOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldOptionCopyWith<$Res> {
  factory $FieldOptionCopyWith(
    FieldOption value,
    $Res Function(FieldOption) then,
  ) = _$FieldOptionCopyWithImpl<$Res, FieldOption>;
  @useResult
  $Res call({String value, String label});
}

/// @nodoc
class _$FieldOptionCopyWithImpl<$Res, $Val extends FieldOption>
    implements $FieldOptionCopyWith<$Res> {
  _$FieldOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldOptionImplCopyWith<$Res>
    implements $FieldOptionCopyWith<$Res> {
  factory _$$FieldOptionImplCopyWith(
    _$FieldOptionImpl value,
    $Res Function(_$FieldOptionImpl) then,
  ) = __$$FieldOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String value, String label});
}

/// @nodoc
class __$$FieldOptionImplCopyWithImpl<$Res>
    extends _$FieldOptionCopyWithImpl<$Res, _$FieldOptionImpl>
    implements _$$FieldOptionImplCopyWith<$Res> {
  __$$FieldOptionImplCopyWithImpl(
    _$FieldOptionImpl _value,
    $Res Function(_$FieldOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? value = null, Object? label = null}) {
    return _then(
      _$FieldOptionImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldOptionImpl implements _FieldOption {
  const _$FieldOptionImpl({required this.value, required this.label});

  factory _$FieldOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldOptionImplFromJson(json);

  @override
  final String value;
  @override
  final String label;

  @override
  String toString() {
    return 'FieldOption(value: $value, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldOptionImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, label);

  /// Create a copy of FieldOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldOptionImplCopyWith<_$FieldOptionImpl> get copyWith =>
      __$$FieldOptionImplCopyWithImpl<_$FieldOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldOptionImplToJson(this);
  }
}

abstract class _FieldOption implements FieldOption {
  const factory _FieldOption({
    required final String value,
    required final String label,
  }) = _$FieldOptionImpl;

  factory _FieldOption.fromJson(Map<String, dynamic> json) =
      _$FieldOptionImpl.fromJson;

  @override
  String get value;
  @override
  String get label;

  /// Create a copy of FieldOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldOptionImplCopyWith<_$FieldOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FieldNode _$FieldNodeFromJson(Map<String, dynamic> json) {
  return _FieldNode.fromJson(json);
}

/// @nodoc
mixin _$FieldNode {
  /// Field name. Unique within the schema. Required.
  String get name => throw _privateConstructorUsedError;

  /// Optional label rendered above (vertical) or beside (horizontal).
  String? get label => throw _privateConstructorUsedError;

  /// Component discriminator. Defaults to [FieldType.input] when null.
  FieldType? get type => throw _privateConstructorUsedError;

  /// Placeholder string forwarded to the underlying input.
  String? get placeholder => throw _privateConstructorUsedError;

  /// Required marker; also added to validation rules at submit time.
  bool get required => throw _privateConstructorUsedError;

  /// Disabled when true; honored by every field renderer.
  bool get disabled => throw _privateConstructorUsedError;

  /// Inline hint shown below the field.
  String? get hint => throw _privateConstructorUsedError;

  /// Inline options for `'select'` fields.
  List<FieldOption> get options => throw _privateConstructorUsedError;

  /// External data source for options (mutually exclusive with [options]).
  DataSource? get optionsSource => throw _privateConstructorUsedError;

  /// `number` min, or string min-length depending on `type`.
  num? get min => throw _privateConstructorUsedError;

  /// `number` max, or string max-length depending on `type`.
  num? get max => throw _privateConstructorUsedError;

  /// Regex source string for `pattern` validation.
  String? get pattern => throw _privateConstructorUsedError;

  /// Validation rules (additional to required/min/max/pattern).
  ///
  /// Excluded from JSON (the [ValidationRule] type carries a function field
  /// `fn` that is not serializable). Consumers wire rules in Dart code.
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ValidationRule> get validation => throw _privateConstructorUsedError;

  /// Serializes this FieldNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldNodeCopyWith<FieldNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldNodeCopyWith<$Res> {
  factory $FieldNodeCopyWith(FieldNode value, $Res Function(FieldNode) then) =
      _$FieldNodeCopyWithImpl<$Res, FieldNode>;
  @useResult
  $Res call({
    String name,
    String? label,
    FieldType? type,
    String? placeholder,
    bool required,
    bool disabled,
    String? hint,
    List<FieldOption> options,
    DataSource? optionsSource,
    num? min,
    num? max,
    String? pattern,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationRule> validation,
  });

  $DataSourceCopyWith<$Res>? get optionsSource;
}

/// @nodoc
class _$FieldNodeCopyWithImpl<$Res, $Val extends FieldNode>
    implements $FieldNodeCopyWith<$Res> {
  _$FieldNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = freezed,
    Object? type = freezed,
    Object? placeholder = freezed,
    Object? required = null,
    Object? disabled = null,
    Object? hint = freezed,
    Object? options = null,
    Object? optionsSource = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? pattern = freezed,
    Object? validation = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as FieldType?,
            placeholder: freezed == placeholder
                ? _value.placeholder
                : placeholder // ignore: cast_nullable_to_non_nullable
                      as String?,
            required: null == required
                ? _value.required
                : required // ignore: cast_nullable_to_non_nullable
                      as bool,
            disabled: null == disabled
                ? _value.disabled
                : disabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            hint: freezed == hint
                ? _value.hint
                : hint // ignore: cast_nullable_to_non_nullable
                      as String?,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<FieldOption>,
            optionsSource: freezed == optionsSource
                ? _value.optionsSource
                : optionsSource // ignore: cast_nullable_to_non_nullable
                      as DataSource?,
            min: freezed == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as num?,
            max: freezed == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as num?,
            pattern: freezed == pattern
                ? _value.pattern
                : pattern // ignore: cast_nullable_to_non_nullable
                      as String?,
            validation: null == validation
                ? _value.validation
                : validation // ignore: cast_nullable_to_non_nullable
                      as List<ValidationRule>,
          )
          as $Val,
    );
  }

  /// Create a copy of FieldNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DataSourceCopyWith<$Res>? get optionsSource {
    if (_value.optionsSource == null) {
      return null;
    }

    return $DataSourceCopyWith<$Res>(_value.optionsSource!, (value) {
      return _then(_value.copyWith(optionsSource: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FieldNodeImplCopyWith<$Res>
    implements $FieldNodeCopyWith<$Res> {
  factory _$$FieldNodeImplCopyWith(
    _$FieldNodeImpl value,
    $Res Function(_$FieldNodeImpl) then,
  ) = __$$FieldNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? label,
    FieldType? type,
    String? placeholder,
    bool required,
    bool disabled,
    String? hint,
    List<FieldOption> options,
    DataSource? optionsSource,
    num? min,
    num? max,
    String? pattern,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ValidationRule> validation,
  });

  @override
  $DataSourceCopyWith<$Res>? get optionsSource;
}

/// @nodoc
class __$$FieldNodeImplCopyWithImpl<$Res>
    extends _$FieldNodeCopyWithImpl<$Res, _$FieldNodeImpl>
    implements _$$FieldNodeImplCopyWith<$Res> {
  __$$FieldNodeImplCopyWithImpl(
    _$FieldNodeImpl _value,
    $Res Function(_$FieldNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = freezed,
    Object? type = freezed,
    Object? placeholder = freezed,
    Object? required = null,
    Object? disabled = null,
    Object? hint = freezed,
    Object? options = null,
    Object? optionsSource = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? pattern = freezed,
    Object? validation = null,
  }) {
    return _then(
      _$FieldNodeImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as FieldType?,
        placeholder: freezed == placeholder
            ? _value.placeholder
            : placeholder // ignore: cast_nullable_to_non_nullable
                  as String?,
        required: null == required
            ? _value.required
            : required // ignore: cast_nullable_to_non_nullable
                  as bool,
        disabled: null == disabled
            ? _value.disabled
            : disabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        hint: freezed == hint
            ? _value.hint
            : hint // ignore: cast_nullable_to_non_nullable
                  as String?,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<FieldOption>,
        optionsSource: freezed == optionsSource
            ? _value.optionsSource
            : optionsSource // ignore: cast_nullable_to_non_nullable
                  as DataSource?,
        min: freezed == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as num?,
        max: freezed == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as num?,
        pattern: freezed == pattern
            ? _value.pattern
            : pattern // ignore: cast_nullable_to_non_nullable
                  as String?,
        validation: null == validation
            ? _value._validation
            : validation // ignore: cast_nullable_to_non_nullable
                  as List<ValidationRule>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$FieldNodeImpl implements _FieldNode {
  const _$FieldNodeImpl({
    required this.name,
    this.label,
    this.type,
    this.placeholder,
    this.required = false,
    this.disabled = false,
    this.hint,
    final List<FieldOption> options = const [],
    this.optionsSource,
    this.min,
    this.max,
    this.pattern,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<ValidationRule> validation = const [],
  }) : _options = options,
       _validation = validation;

  factory _$FieldNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldNodeImplFromJson(json);

  /// Field name. Unique within the schema. Required.
  @override
  final String name;

  /// Optional label rendered above (vertical) or beside (horizontal).
  @override
  final String? label;

  /// Component discriminator. Defaults to [FieldType.input] when null.
  @override
  final FieldType? type;

  /// Placeholder string forwarded to the underlying input.
  @override
  final String? placeholder;

  /// Required marker; also added to validation rules at submit time.
  @override
  @JsonKey()
  final bool required;

  /// Disabled when true; honored by every field renderer.
  @override
  @JsonKey()
  final bool disabled;

  /// Inline hint shown below the field.
  @override
  final String? hint;

  /// Inline options for `'select'` fields.
  final List<FieldOption> _options;

  /// Inline options for `'select'` fields.
  @override
  @JsonKey()
  List<FieldOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  /// External data source for options (mutually exclusive with [options]).
  @override
  final DataSource? optionsSource;

  /// `number` min, or string min-length depending on `type`.
  @override
  final num? min;

  /// `number` max, or string max-length depending on `type`.
  @override
  final num? max;

  /// Regex source string for `pattern` validation.
  @override
  final String? pattern;

  /// Validation rules (additional to required/min/max/pattern).
  ///
  /// Excluded from JSON (the [ValidationRule] type carries a function field
  /// `fn` that is not serializable). Consumers wire rules in Dart code.
  final List<ValidationRule> _validation;

  /// Validation rules (additional to required/min/max/pattern).
  ///
  /// Excluded from JSON (the [ValidationRule] type carries a function field
  /// `fn` that is not serializable). Consumers wire rules in Dart code.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ValidationRule> get validation {
    if (_validation is EqualUnmodifiableListView) return _validation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_validation);
  }

  @override
  String toString() {
    return 'FieldNode(name: $name, label: $label, type: $type, placeholder: $placeholder, required: $required, disabled: $disabled, hint: $hint, options: $options, optionsSource: $optionsSource, min: $min, max: $max, pattern: $pattern, validation: $validation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldNodeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.placeholder, placeholder) ||
                other.placeholder == placeholder) &&
            (identical(other.required, required) ||
                other.required == required) &&
            (identical(other.disabled, disabled) ||
                other.disabled == disabled) &&
            (identical(other.hint, hint) || other.hint == hint) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.optionsSource, optionsSource) ||
                other.optionsSource == optionsSource) &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            const DeepCollectionEquality().equals(
              other._validation,
              _validation,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    label,
    type,
    placeholder,
    required,
    disabled,
    hint,
    const DeepCollectionEquality().hash(_options),
    optionsSource,
    min,
    max,
    pattern,
    const DeepCollectionEquality().hash(_validation),
  );

  /// Create a copy of FieldNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldNodeImplCopyWith<_$FieldNodeImpl> get copyWith =>
      __$$FieldNodeImplCopyWithImpl<_$FieldNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldNodeImplToJson(this);
  }
}

abstract class _FieldNode implements FieldNode {
  const factory _FieldNode({
    required final String name,
    final String? label,
    final FieldType? type,
    final String? placeholder,
    final bool required,
    final bool disabled,
    final String? hint,
    final List<FieldOption> options,
    final DataSource? optionsSource,
    final num? min,
    final num? max,
    final String? pattern,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<ValidationRule> validation,
  }) = _$FieldNodeImpl;

  factory _FieldNode.fromJson(Map<String, dynamic> json) =
      _$FieldNodeImpl.fromJson;

  /// Field name. Unique within the schema. Required.
  @override
  String get name;

  /// Optional label rendered above (vertical) or beside (horizontal).
  @override
  String? get label;

  /// Component discriminator. Defaults to [FieldType.input] when null.
  @override
  FieldType? get type;

  /// Placeholder string forwarded to the underlying input.
  @override
  String? get placeholder;

  /// Required marker; also added to validation rules at submit time.
  @override
  bool get required;

  /// Disabled when true; honored by every field renderer.
  @override
  bool get disabled;

  /// Inline hint shown below the field.
  @override
  String? get hint;

  /// Inline options for `'select'` fields.
  @override
  List<FieldOption> get options;

  /// External data source for options (mutually exclusive with [options]).
  @override
  DataSource? get optionsSource;

  /// `number` min, or string min-length depending on `type`.
  @override
  num? get min;

  /// `number` max, or string max-length depending on `type`.
  @override
  num? get max;

  /// Regex source string for `pattern` validation.
  @override
  String? get pattern;

  /// Validation rules (additional to required/min/max/pattern).
  ///
  /// Excluded from JSON (the [ValidationRule] type carries a function field
  /// `fn` that is not serializable). Consumers wire rules in Dart code.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ValidationRule> get validation;

  /// Create a copy of FieldNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldNodeImplCopyWith<_$FieldNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UiAction _$UiActionFromJson(Map<String, dynamic> json) {
  return _UiAction.fromJson(json);
}

/// @nodoc
mixin _$UiAction {
  /// Stable id, echoed in `onAction(name, values)`.
  String get name => throw _privateConstructorUsedError;

  /// Label shown on the button. Defaults to a humanised `name`.
  String? get label => throw _privateConstructorUsedError;

  /// Visual variant. Defaults to [ComponentVariant.primary] for submit.
  ComponentVariant? get variant => throw _privateConstructorUsedError;

  /// When true the submit handler is invoked (form schemas only).
  bool get submit => throw _privateConstructorUsedError;

  /// Disabled flag.
  bool get disabled => throw _privateConstructorUsedError;

  /// Serializes this UiAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UiAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UiActionCopyWith<UiAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UiActionCopyWith<$Res> {
  factory $UiActionCopyWith(UiAction value, $Res Function(UiAction) then) =
      _$UiActionCopyWithImpl<$Res, UiAction>;
  @useResult
  $Res call({
    String name,
    String? label,
    ComponentVariant? variant,
    bool submit,
    bool disabled,
  });
}

/// @nodoc
class _$UiActionCopyWithImpl<$Res, $Val extends UiAction>
    implements $UiActionCopyWith<$Res> {
  _$UiActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UiAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = freezed,
    Object? variant = freezed,
    Object? submit = null,
    Object? disabled = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            variant: freezed == variant
                ? _value.variant
                : variant // ignore: cast_nullable_to_non_nullable
                      as ComponentVariant?,
            submit: null == submit
                ? _value.submit
                : submit // ignore: cast_nullable_to_non_nullable
                      as bool,
            disabled: null == disabled
                ? _value.disabled
                : disabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UiActionImplCopyWith<$Res>
    implements $UiActionCopyWith<$Res> {
  factory _$$UiActionImplCopyWith(
    _$UiActionImpl value,
    $Res Function(_$UiActionImpl) then,
  ) = __$$UiActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? label,
    ComponentVariant? variant,
    bool submit,
    bool disabled,
  });
}

/// @nodoc
class __$$UiActionImplCopyWithImpl<$Res>
    extends _$UiActionCopyWithImpl<$Res, _$UiActionImpl>
    implements _$$UiActionImplCopyWith<$Res> {
  __$$UiActionImplCopyWithImpl(
    _$UiActionImpl _value,
    $Res Function(_$UiActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UiAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = freezed,
    Object? variant = freezed,
    Object? submit = null,
    Object? disabled = null,
  }) {
    return _then(
      _$UiActionImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        variant: freezed == variant
            ? _value.variant
            : variant // ignore: cast_nullable_to_non_nullable
                  as ComponentVariant?,
        submit: null == submit
            ? _value.submit
            : submit // ignore: cast_nullable_to_non_nullable
                  as bool,
        disabled: null == disabled
            ? _value.disabled
            : disabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UiActionImpl implements _UiAction {
  const _$UiActionImpl({
    required this.name,
    this.label,
    this.variant,
    this.submit = false,
    this.disabled = false,
  });

  factory _$UiActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UiActionImplFromJson(json);

  /// Stable id, echoed in `onAction(name, values)`.
  @override
  final String name;

  /// Label shown on the button. Defaults to a humanised `name`.
  @override
  final String? label;

  /// Visual variant. Defaults to [ComponentVariant.primary] for submit.
  @override
  final ComponentVariant? variant;

  /// When true the submit handler is invoked (form schemas only).
  @override
  @JsonKey()
  final bool submit;

  /// Disabled flag.
  @override
  @JsonKey()
  final bool disabled;

  @override
  String toString() {
    return 'UiAction(name: $name, label: $label, variant: $variant, submit: $submit, disabled: $disabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UiActionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.variant, variant) || other.variant == variant) &&
            (identical(other.submit, submit) || other.submit == submit) &&
            (identical(other.disabled, disabled) ||
                other.disabled == disabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, label, variant, submit, disabled);

  /// Create a copy of UiAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UiActionImplCopyWith<_$UiActionImpl> get copyWith =>
      __$$UiActionImplCopyWithImpl<_$UiActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UiActionImplToJson(this);
  }
}

abstract class _UiAction implements UiAction {
  const factory _UiAction({
    required final String name,
    final String? label,
    final ComponentVariant? variant,
    final bool submit,
    final bool disabled,
  }) = _$UiActionImpl;

  factory _UiAction.fromJson(Map<String, dynamic> json) =
      _$UiActionImpl.fromJson;

  /// Stable id, echoed in `onAction(name, values)`.
  @override
  String get name;

  /// Label shown on the button. Defaults to a humanised `name`.
  @override
  String? get label;

  /// Visual variant. Defaults to [ComponentVariant.primary] for submit.
  @override
  ComponentVariant? get variant;

  /// When true the submit handler is invoked (form schemas only).
  @override
  bool get submit;

  /// Disabled flag.
  @override
  bool get disabled;

  /// Create a copy of UiAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UiActionImplCopyWith<_$UiActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ColumnDef _$ColumnDefFromJson(Map<String, dynamic> json) {
  return _ColumnDef.fromJson(json);
}

/// @nodoc
mixin _$ColumnDef {
  String get key => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  bool get sortable => throw _privateConstructorUsedError;
  bool get filterable => throw _privateConstructorUsedError;
  String? get width => throw _privateConstructorUsedError;
  ColumnAlign get align => throw _privateConstructorUsedError;

  /// Serializes this ColumnDef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ColumnDef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnDefCopyWith<ColumnDef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnDefCopyWith<$Res> {
  factory $ColumnDefCopyWith(ColumnDef value, $Res Function(ColumnDef) then) =
      _$ColumnDefCopyWithImpl<$Res, ColumnDef>;
  @useResult
  $Res call({
    String key,
    String label,
    bool sortable,
    bool filterable,
    String? width,
    ColumnAlign align,
  });
}

/// @nodoc
class _$ColumnDefCopyWithImpl<$Res, $Val extends ColumnDef>
    implements $ColumnDefCopyWith<$Res> {
  _$ColumnDefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColumnDef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? label = null,
    Object? sortable = null,
    Object? filterable = null,
    Object? width = freezed,
    Object? align = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            sortable: null == sortable
                ? _value.sortable
                : sortable // ignore: cast_nullable_to_non_nullable
                      as bool,
            filterable: null == filterable
                ? _value.filterable
                : filterable // ignore: cast_nullable_to_non_nullable
                      as bool,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as String?,
            align: null == align
                ? _value.align
                : align // ignore: cast_nullable_to_non_nullable
                      as ColumnAlign,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ColumnDefImplCopyWith<$Res>
    implements $ColumnDefCopyWith<$Res> {
  factory _$$ColumnDefImplCopyWith(
    _$ColumnDefImpl value,
    $Res Function(_$ColumnDefImpl) then,
  ) = __$$ColumnDefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String key,
    String label,
    bool sortable,
    bool filterable,
    String? width,
    ColumnAlign align,
  });
}

/// @nodoc
class __$$ColumnDefImplCopyWithImpl<$Res>
    extends _$ColumnDefCopyWithImpl<$Res, _$ColumnDefImpl>
    implements _$$ColumnDefImplCopyWith<$Res> {
  __$$ColumnDefImplCopyWithImpl(
    _$ColumnDefImpl _value,
    $Res Function(_$ColumnDefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ColumnDef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? label = null,
    Object? sortable = null,
    Object? filterable = null,
    Object? width = freezed,
    Object? align = null,
  }) {
    return _then(
      _$ColumnDefImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        sortable: null == sortable
            ? _value.sortable
            : sortable // ignore: cast_nullable_to_non_nullable
                  as bool,
        filterable: null == filterable
            ? _value.filterable
            : filterable // ignore: cast_nullable_to_non_nullable
                  as bool,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as String?,
        align: null == align
            ? _value.align
            : align // ignore: cast_nullable_to_non_nullable
                  as ColumnAlign,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ColumnDefImpl implements _ColumnDef {
  const _$ColumnDefImpl({
    required this.key,
    required this.label,
    this.sortable = false,
    this.filterable = false,
    this.width,
    this.align = ColumnAlign.left,
  });

  factory _$ColumnDefImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColumnDefImplFromJson(json);

  @override
  final String key;
  @override
  final String label;
  @override
  @JsonKey()
  final bool sortable;
  @override
  @JsonKey()
  final bool filterable;
  @override
  final String? width;
  @override
  @JsonKey()
  final ColumnAlign align;

  @override
  String toString() {
    return 'ColumnDef(key: $key, label: $label, sortable: $sortable, filterable: $filterable, width: $width, align: $align)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnDefImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.sortable, sortable) ||
                other.sortable == sortable) &&
            (identical(other.filterable, filterable) ||
                other.filterable == filterable) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.align, align) || other.align == align));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, label, sortable, filterable, width, align);

  /// Create a copy of ColumnDef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnDefImplCopyWith<_$ColumnDefImpl> get copyWith =>
      __$$ColumnDefImplCopyWithImpl<_$ColumnDefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColumnDefImplToJson(this);
  }
}

abstract class _ColumnDef implements ColumnDef {
  const factory _ColumnDef({
    required final String key,
    required final String label,
    final bool sortable,
    final bool filterable,
    final String? width,
    final ColumnAlign align,
  }) = _$ColumnDefImpl;

  factory _ColumnDef.fromJson(Map<String, dynamic> json) =
      _$ColumnDefImpl.fromJson;

  @override
  String get key;
  @override
  String get label;
  @override
  bool get sortable;
  @override
  bool get filterable;
  @override
  String? get width;
  @override
  ColumnAlign get align;

  /// Create a copy of ColumnDef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnDefImplCopyWith<_$ColumnDefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UiSchema _$UiSchemaFromJson(Map<String, dynamic> json) {
  return _UiSchema.fromJson(json);
}

/// @nodoc
mixin _$UiSchema {
  /// Schema kind discriminator. Required.
  UiSchemaKind get type => throw _privateConstructorUsedError;

  /// Stable id (debugging + DOM targeting via `data-bc-schema`).
  String? get name => throw _privateConstructorUsedError;

  /// Title shown above sections / forms.
  String? get title => throw _privateConstructorUsedError;

  /// Description shown under the title.
  String? get description =>
      throw _privateConstructorUsedError; // Form / detail
  /// Fields rendered inside a `'form'` / `'detail'` schema.
  List<FieldNode> get fields => throw _privateConstructorUsedError;

  /// Layout mode forwarded to BcForm. Defaults to [FormLayout.vertical].
  FormLayout get layout =>
      throw _privateConstructorUsedError; // Grouping (section / grid)
  /// Nested schemas for `'section'` / `'grid'` kinds.
  List<UiSchema> get sections => throw _privateConstructorUsedError;

  /// Number of columns for `'grid'` kind. Ignored otherwise. Defaults to 2.
  int get columns => throw _privateConstructorUsedError; // List
  /// Columns for `'list'` schemas. Forwarded to BcDataTable.
  List<ColumnDef> get columnsDef => throw _privateConstructorUsedError;

  /// Inline data source for `'list'` schemas.
  List<dynamic> get data => throw _privateConstructorUsedError;

  /// External data source for `'list'` schemas (4-layer per ADR-002).
  DataSource? get source => throw _privateConstructorUsedError;

  /// Page size for `'list'` schemas.
  int? get pageSize =>
      throw _privateConstructorUsedError; // Reactivity (ADR-004)
  /// Reactions wired into a [ReactiveStore] wrapping the rendered subtree.
  ///
  /// Excluded from JSON (reactions carry function effects that are not
  /// serializable). Consumers wire reactions in Dart code.
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Reaction> get reactions => throw _privateConstructorUsedError; // Form actions
  /// Buttons rendered below the fields of a `'form'` / `'detail'` schema.
  List<UiAction> get actions =>
      throw _privateConstructorUsedError; // Custom escape hatch
  /// JSON payload for `'custom'` schemas (DOM portal / pre-processing).
  Object? get payload => throw _privateConstructorUsedError;

  /// Serializes this UiSchema to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UiSchema
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UiSchemaCopyWith<UiSchema> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UiSchemaCopyWith<$Res> {
  factory $UiSchemaCopyWith(UiSchema value, $Res Function(UiSchema) then) =
      _$UiSchemaCopyWithImpl<$Res, UiSchema>;
  @useResult
  $Res call({
    UiSchemaKind type,
    String? name,
    String? title,
    String? description,
    List<FieldNode> fields,
    FormLayout layout,
    List<UiSchema> sections,
    int columns,
    List<ColumnDef> columnsDef,
    List<dynamic> data,
    DataSource? source,
    int? pageSize,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<Reaction> reactions,
    List<UiAction> actions,
    Object? payload,
  });

  $DataSourceCopyWith<$Res>? get source;
}

/// @nodoc
class _$UiSchemaCopyWithImpl<$Res, $Val extends UiSchema>
    implements $UiSchemaCopyWith<$Res> {
  _$UiSchemaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UiSchema
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? fields = null,
    Object? layout = null,
    Object? sections = null,
    Object? columns = null,
    Object? columnsDef = null,
    Object? data = null,
    Object? source = freezed,
    Object? pageSize = freezed,
    Object? reactions = null,
    Object? actions = null,
    Object? payload = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as UiSchemaKind,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            fields: null == fields
                ? _value.fields
                : fields // ignore: cast_nullable_to_non_nullable
                      as List<FieldNode>,
            layout: null == layout
                ? _value.layout
                : layout // ignore: cast_nullable_to_non_nullable
                      as FormLayout,
            sections: null == sections
                ? _value.sections
                : sections // ignore: cast_nullable_to_non_nullable
                      as List<UiSchema>,
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as int,
            columnsDef: null == columnsDef
                ? _value.columnsDef
                : columnsDef // ignore: cast_nullable_to_non_nullable
                      as List<ColumnDef>,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as DataSource?,
            pageSize: freezed == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            reactions: null == reactions
                ? _value.reactions
                : reactions // ignore: cast_nullable_to_non_nullable
                      as List<Reaction>,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<UiAction>,
            payload: freezed == payload ? _value.payload : payload,
          )
          as $Val,
    );
  }

  /// Create a copy of UiSchema
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DataSourceCopyWith<$Res>? get source {
    if (_value.source == null) {
      return null;
    }

    return $DataSourceCopyWith<$Res>(_value.source!, (value) {
      return _then(_value.copyWith(source: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UiSchemaImplCopyWith<$Res>
    implements $UiSchemaCopyWith<$Res> {
  factory _$$UiSchemaImplCopyWith(
    _$UiSchemaImpl value,
    $Res Function(_$UiSchemaImpl) then,
  ) = __$$UiSchemaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UiSchemaKind type,
    String? name,
    String? title,
    String? description,
    List<FieldNode> fields,
    FormLayout layout,
    List<UiSchema> sections,
    int columns,
    List<ColumnDef> columnsDef,
    List<dynamic> data,
    DataSource? source,
    int? pageSize,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<Reaction> reactions,
    List<UiAction> actions,
    Object? payload,
  });

  @override
  $DataSourceCopyWith<$Res>? get source;
}

/// @nodoc
class __$$UiSchemaImplCopyWithImpl<$Res>
    extends _$UiSchemaCopyWithImpl<$Res, _$UiSchemaImpl>
    implements _$$UiSchemaImplCopyWith<$Res> {
  __$$UiSchemaImplCopyWithImpl(
    _$UiSchemaImpl _value,
    $Res Function(_$UiSchemaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UiSchema
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? fields = null,
    Object? layout = null,
    Object? sections = null,
    Object? columns = null,
    Object? columnsDef = null,
    Object? data = null,
    Object? source = freezed,
    Object? pageSize = freezed,
    Object? reactions = null,
    Object? actions = null,
    Object? payload = freezed,
  }) {
    return _then(
      _$UiSchemaImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as UiSchemaKind,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        fields: null == fields
            ? _value._fields
            : fields // ignore: cast_nullable_to_non_nullable
                  as List<FieldNode>,
        layout: null == layout
            ? _value.layout
            : layout // ignore: cast_nullable_to_non_nullable
                  as FormLayout,
        sections: null == sections
            ? _value._sections
            : sections // ignore: cast_nullable_to_non_nullable
                  as List<UiSchema>,
        columns: null == columns
            ? _value.columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as int,
        columnsDef: null == columnsDef
            ? _value._columnsDef
            : columnsDef // ignore: cast_nullable_to_non_nullable
                  as List<ColumnDef>,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as DataSource?,
        pageSize: freezed == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        reactions: null == reactions
            ? _value._reactions
            : reactions // ignore: cast_nullable_to_non_nullable
                  as List<Reaction>,
        actions: null == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<UiAction>,
        payload: freezed == payload ? _value.payload : payload,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$UiSchemaImpl implements _UiSchema {
  const _$UiSchemaImpl({
    required this.type,
    this.name,
    this.title,
    this.description,
    final List<FieldNode> fields = const [],
    this.layout = FormLayout.vertical,
    final List<UiSchema> sections = const [],
    this.columns = 2,
    final List<ColumnDef> columnsDef = const [],
    final List<dynamic> data = const [],
    this.source,
    this.pageSize,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<Reaction> reactions = const [],
    final List<UiAction> actions = const [],
    this.payload,
  }) : _fields = fields,
       _sections = sections,
       _columnsDef = columnsDef,
       _data = data,
       _reactions = reactions,
       _actions = actions;

  factory _$UiSchemaImpl.fromJson(Map<String, dynamic> json) =>
      _$$UiSchemaImplFromJson(json);

  /// Schema kind discriminator. Required.
  @override
  final UiSchemaKind type;

  /// Stable id (debugging + DOM targeting via `data-bc-schema`).
  @override
  final String? name;

  /// Title shown above sections / forms.
  @override
  final String? title;

  /// Description shown under the title.
  @override
  final String? description;
  // Form / detail
  /// Fields rendered inside a `'form'` / `'detail'` schema.
  final List<FieldNode> _fields;
  // Form / detail
  /// Fields rendered inside a `'form'` / `'detail'` schema.
  @override
  @JsonKey()
  List<FieldNode> get fields {
    if (_fields is EqualUnmodifiableListView) return _fields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fields);
  }

  /// Layout mode forwarded to BcForm. Defaults to [FormLayout.vertical].
  @override
  @JsonKey()
  final FormLayout layout;
  // Grouping (section / grid)
  /// Nested schemas for `'section'` / `'grid'` kinds.
  final List<UiSchema> _sections;
  // Grouping (section / grid)
  /// Nested schemas for `'section'` / `'grid'` kinds.
  @override
  @JsonKey()
  List<UiSchema> get sections {
    if (_sections is EqualUnmodifiableListView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sections);
  }

  /// Number of columns for `'grid'` kind. Ignored otherwise. Defaults to 2.
  @override
  @JsonKey()
  final int columns;
  // List
  /// Columns for `'list'` schemas. Forwarded to BcDataTable.
  final List<ColumnDef> _columnsDef;
  // List
  /// Columns for `'list'` schemas. Forwarded to BcDataTable.
  @override
  @JsonKey()
  List<ColumnDef> get columnsDef {
    if (_columnsDef is EqualUnmodifiableListView) return _columnsDef;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_columnsDef);
  }

  /// Inline data source for `'list'` schemas.
  final List<dynamic> _data;

  /// Inline data source for `'list'` schemas.
  @override
  @JsonKey()
  List<dynamic> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  /// External data source for `'list'` schemas (4-layer per ADR-002).
  @override
  final DataSource? source;

  /// Page size for `'list'` schemas.
  @override
  final int? pageSize;
  // Reactivity (ADR-004)
  /// Reactions wired into a [ReactiveStore] wrapping the rendered subtree.
  ///
  /// Excluded from JSON (reactions carry function effects that are not
  /// serializable). Consumers wire reactions in Dart code.
  final List<Reaction> _reactions;
  // Reactivity (ADR-004)
  /// Reactions wired into a [ReactiveStore] wrapping the rendered subtree.
  ///
  /// Excluded from JSON (reactions carry function effects that are not
  /// serializable). Consumers wire reactions in Dart code.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Reaction> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  // Form actions
  /// Buttons rendered below the fields of a `'form'` / `'detail'` schema.
  final List<UiAction> _actions;
  // Form actions
  /// Buttons rendered below the fields of a `'form'` / `'detail'` schema.
  @override
  @JsonKey()
  List<UiAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  // Custom escape hatch
  /// JSON payload for `'custom'` schemas (DOM portal / pre-processing).
  @override
  final Object? payload;

  @override
  String toString() {
    return 'UiSchema(type: $type, name: $name, title: $title, description: $description, fields: $fields, layout: $layout, sections: $sections, columns: $columns, columnsDef: $columnsDef, data: $data, source: $source, pageSize: $pageSize, reactions: $reactions, actions: $actions, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UiSchemaImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._fields, _fields) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            const DeepCollectionEquality().equals(other._sections, _sections) &&
            (identical(other.columns, columns) || other.columns == columns) &&
            const DeepCollectionEquality().equals(
              other._columnsDef,
              _columnsDef,
            ) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            const DeepCollectionEquality().equals(
              other._reactions,
              _reactions,
            ) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            const DeepCollectionEquality().equals(other.payload, payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    name,
    title,
    description,
    const DeepCollectionEquality().hash(_fields),
    layout,
    const DeepCollectionEquality().hash(_sections),
    columns,
    const DeepCollectionEquality().hash(_columnsDef),
    const DeepCollectionEquality().hash(_data),
    source,
    pageSize,
    const DeepCollectionEquality().hash(_reactions),
    const DeepCollectionEquality().hash(_actions),
    const DeepCollectionEquality().hash(payload),
  );

  /// Create a copy of UiSchema
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UiSchemaImplCopyWith<_$UiSchemaImpl> get copyWith =>
      __$$UiSchemaImplCopyWithImpl<_$UiSchemaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UiSchemaImplToJson(this);
  }
}

abstract class _UiSchema implements UiSchema {
  const factory _UiSchema({
    required final UiSchemaKind type,
    final String? name,
    final String? title,
    final String? description,
    final List<FieldNode> fields,
    final FormLayout layout,
    final List<UiSchema> sections,
    final int columns,
    final List<ColumnDef> columnsDef,
    final List<dynamic> data,
    final DataSource? source,
    final int? pageSize,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<Reaction> reactions,
    final List<UiAction> actions,
    final Object? payload,
  }) = _$UiSchemaImpl;

  factory _UiSchema.fromJson(Map<String, dynamic> json) =
      _$UiSchemaImpl.fromJson;

  /// Schema kind discriminator. Required.
  @override
  UiSchemaKind get type;

  /// Stable id (debugging + DOM targeting via `data-bc-schema`).
  @override
  String? get name;

  /// Title shown above sections / forms.
  @override
  String? get title;

  /// Description shown under the title.
  @override
  String? get description; // Form / detail
  /// Fields rendered inside a `'form'` / `'detail'` schema.
  @override
  List<FieldNode> get fields;

  /// Layout mode forwarded to BcForm. Defaults to [FormLayout.vertical].
  @override
  FormLayout get layout; // Grouping (section / grid)
  /// Nested schemas for `'section'` / `'grid'` kinds.
  @override
  List<UiSchema> get sections;

  /// Number of columns for `'grid'` kind. Ignored otherwise. Defaults to 2.
  @override
  int get columns; // List
  /// Columns for `'list'` schemas. Forwarded to BcDataTable.
  @override
  List<ColumnDef> get columnsDef;

  /// Inline data source for `'list'` schemas.
  @override
  List<dynamic> get data;

  /// External data source for `'list'` schemas (4-layer per ADR-002).
  @override
  DataSource? get source;

  /// Page size for `'list'` schemas.
  @override
  int? get pageSize; // Reactivity (ADR-004)
  /// Reactions wired into a [ReactiveStore] wrapping the rendered subtree.
  ///
  /// Excluded from JSON (reactions carry function effects that are not
  /// serializable). Consumers wire reactions in Dart code.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Reaction> get reactions; // Form actions
  /// Buttons rendered below the fields of a `'form'` / `'detail'` schema.
  @override
  List<UiAction> get actions; // Custom escape hatch
  /// JSON payload for `'custom'` schemas (DOM portal / pre-processing).
  @override
  Object? get payload;

  /// Create a copy of UiSchema
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UiSchemaImplCopyWith<_$UiSchemaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
