// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_schema_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BcSelection {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() all,
    required TResult Function(Set<Object> keys) set,
    required TResult Function(List<Object> keys) list,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? all,
    TResult? Function(Set<Object> keys)? set,
    TResult? Function(List<Object> keys)? list,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? all,
    TResult Function(Set<Object> keys)? set,
    TResult Function(List<Object> keys)? list,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BcSelectionAll value) all,
    required TResult Function(BcSelectionSet value) set,
    required TResult Function(BcSelectionList value) list,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BcSelectionAll value)? all,
    TResult? Function(BcSelectionSet value)? set,
    TResult? Function(BcSelectionList value)? list,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BcSelectionAll value)? all,
    TResult Function(BcSelectionSet value)? set,
    TResult Function(BcSelectionList value)? list,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BcSelectionCopyWith<$Res> {
  factory $BcSelectionCopyWith(
    BcSelection value,
    $Res Function(BcSelection) then,
  ) = _$BcSelectionCopyWithImpl<$Res, BcSelection>;
}

/// @nodoc
class _$BcSelectionCopyWithImpl<$Res, $Val extends BcSelection>
    implements $BcSelectionCopyWith<$Res> {
  _$BcSelectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$BcSelectionAllImplCopyWith<$Res> {
  factory _$$BcSelectionAllImplCopyWith(
    _$BcSelectionAllImpl value,
    $Res Function(_$BcSelectionAllImpl) then,
  ) = __$$BcSelectionAllImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BcSelectionAllImplCopyWithImpl<$Res>
    extends _$BcSelectionCopyWithImpl<$Res, _$BcSelectionAllImpl>
    implements _$$BcSelectionAllImplCopyWith<$Res> {
  __$$BcSelectionAllImplCopyWithImpl(
    _$BcSelectionAllImpl _value,
    $Res Function(_$BcSelectionAllImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BcSelectionAllImpl implements BcSelectionAll {
  const _$BcSelectionAllImpl();

  @override
  String toString() {
    return 'BcSelection.all()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BcSelectionAllImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() all,
    required TResult Function(Set<Object> keys) set,
    required TResult Function(List<Object> keys) list,
  }) {
    return all();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? all,
    TResult? Function(Set<Object> keys)? set,
    TResult? Function(List<Object> keys)? list,
  }) {
    return all?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? all,
    TResult Function(Set<Object> keys)? set,
    TResult Function(List<Object> keys)? list,
    required TResult orElse(),
  }) {
    if (all != null) {
      return all();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BcSelectionAll value) all,
    required TResult Function(BcSelectionSet value) set,
    required TResult Function(BcSelectionList value) list,
  }) {
    return all(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BcSelectionAll value)? all,
    TResult? Function(BcSelectionSet value)? set,
    TResult? Function(BcSelectionList value)? list,
  }) {
    return all?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BcSelectionAll value)? all,
    TResult Function(BcSelectionSet value)? set,
    TResult Function(BcSelectionList value)? list,
    required TResult orElse(),
  }) {
    if (all != null) {
      return all(this);
    }
    return orElse();
  }
}

abstract class BcSelectionAll implements BcSelection {
  const factory BcSelectionAll() = _$BcSelectionAllImpl;
}

/// @nodoc
abstract class _$$BcSelectionSetImplCopyWith<$Res> {
  factory _$$BcSelectionSetImplCopyWith(
    _$BcSelectionSetImpl value,
    $Res Function(_$BcSelectionSetImpl) then,
  ) = __$$BcSelectionSetImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Set<Object> keys});
}

/// @nodoc
class __$$BcSelectionSetImplCopyWithImpl<$Res>
    extends _$BcSelectionCopyWithImpl<$Res, _$BcSelectionSetImpl>
    implements _$$BcSelectionSetImplCopyWith<$Res> {
  __$$BcSelectionSetImplCopyWithImpl(
    _$BcSelectionSetImpl _value,
    $Res Function(_$BcSelectionSetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? keys = null}) {
    return _then(
      _$BcSelectionSetImpl(
        null == keys
            ? _value._keys
            : keys // ignore: cast_nullable_to_non_nullable
                  as Set<Object>,
      ),
    );
  }
}

/// @nodoc

class _$BcSelectionSetImpl implements BcSelectionSet {
  const _$BcSelectionSetImpl(final Set<Object> keys) : _keys = keys;

  final Set<Object> _keys;
  @override
  Set<Object> get keys {
    if (_keys is EqualUnmodifiableSetView) return _keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_keys);
  }

  @override
  String toString() {
    return 'BcSelection.set(keys: $keys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BcSelectionSetImpl &&
            const DeepCollectionEquality().equals(other._keys, _keys));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_keys));

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BcSelectionSetImplCopyWith<_$BcSelectionSetImpl> get copyWith =>
      __$$BcSelectionSetImplCopyWithImpl<_$BcSelectionSetImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() all,
    required TResult Function(Set<Object> keys) set,
    required TResult Function(List<Object> keys) list,
  }) {
    return set(keys);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? all,
    TResult? Function(Set<Object> keys)? set,
    TResult? Function(List<Object> keys)? list,
  }) {
    return set?.call(keys);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? all,
    TResult Function(Set<Object> keys)? set,
    TResult Function(List<Object> keys)? list,
    required TResult orElse(),
  }) {
    if (set != null) {
      return set(keys);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BcSelectionAll value) all,
    required TResult Function(BcSelectionSet value) set,
    required TResult Function(BcSelectionList value) list,
  }) {
    return set(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BcSelectionAll value)? all,
    TResult? Function(BcSelectionSet value)? set,
    TResult? Function(BcSelectionList value)? list,
  }) {
    return set?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BcSelectionAll value)? all,
    TResult Function(BcSelectionSet value)? set,
    TResult Function(BcSelectionList value)? list,
    required TResult orElse(),
  }) {
    if (set != null) {
      return set(this);
    }
    return orElse();
  }
}

abstract class BcSelectionSet implements BcSelection {
  const factory BcSelectionSet(final Set<Object> keys) = _$BcSelectionSetImpl;

  Set<Object> get keys;

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BcSelectionSetImplCopyWith<_$BcSelectionSetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BcSelectionListImplCopyWith<$Res> {
  factory _$$BcSelectionListImplCopyWith(
    _$BcSelectionListImpl value,
    $Res Function(_$BcSelectionListImpl) then,
  ) = __$$BcSelectionListImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Object> keys});
}

/// @nodoc
class __$$BcSelectionListImplCopyWithImpl<$Res>
    extends _$BcSelectionCopyWithImpl<$Res, _$BcSelectionListImpl>
    implements _$$BcSelectionListImplCopyWith<$Res> {
  __$$BcSelectionListImplCopyWithImpl(
    _$BcSelectionListImpl _value,
    $Res Function(_$BcSelectionListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? keys = null}) {
    return _then(
      _$BcSelectionListImpl(
        null == keys
            ? _value._keys
            : keys // ignore: cast_nullable_to_non_nullable
                  as List<Object>,
      ),
    );
  }
}

/// @nodoc

class _$BcSelectionListImpl implements BcSelectionList {
  const _$BcSelectionListImpl(final List<Object> keys) : _keys = keys;

  final List<Object> _keys;
  @override
  List<Object> get keys {
    if (_keys is EqualUnmodifiableListView) return _keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keys);
  }

  @override
  String toString() {
    return 'BcSelection.list(keys: $keys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BcSelectionListImpl &&
            const DeepCollectionEquality().equals(other._keys, _keys));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_keys));

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BcSelectionListImplCopyWith<_$BcSelectionListImpl> get copyWith =>
      __$$BcSelectionListImplCopyWithImpl<_$BcSelectionListImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() all,
    required TResult Function(Set<Object> keys) set,
    required TResult Function(List<Object> keys) list,
  }) {
    return list(keys);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? all,
    TResult? Function(Set<Object> keys)? set,
    TResult? Function(List<Object> keys)? list,
  }) {
    return list?.call(keys);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? all,
    TResult Function(Set<Object> keys)? set,
    TResult Function(List<Object> keys)? list,
    required TResult orElse(),
  }) {
    if (list != null) {
      return list(keys);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BcSelectionAll value) all,
    required TResult Function(BcSelectionSet value) set,
    required TResult Function(BcSelectionList value) list,
  }) {
    return list(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BcSelectionAll value)? all,
    TResult? Function(BcSelectionSet value)? set,
    TResult? Function(BcSelectionList value)? list,
  }) {
    return list?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BcSelectionAll value)? all,
    TResult Function(BcSelectionSet value)? set,
    TResult Function(BcSelectionList value)? list,
    required TResult orElse(),
  }) {
    if (list != null) {
      return list(this);
    }
    return orElse();
  }
}

abstract class BcSelectionList implements BcSelection {
  const factory BcSelectionList(final List<Object> keys) =
      _$BcSelectionListImpl;

  List<Object> get keys;

  /// Create a copy of BcSelection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BcSelectionListImplCopyWith<_$BcSelectionListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FetchParams _$FetchParamsFromJson(Map<String, dynamic> json) {
  return _FetchParams.fromJson(json);
}

/// @nodoc
mixin _$FetchParams {
  int? get page => throw _privateConstructorUsedError;
  int? get pageSize => throw _privateConstructorUsedError;
  List<SortRule> get sort => throw _privateConstructorUsedError;
  Map<String, dynamic> get filters => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  Map<String, dynamic> get dependValues => throw _privateConstructorUsedError;
  int? get retry => throw _privateConstructorUsedError;

  /// Serializes this FetchParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FetchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FetchParamsCopyWith<FetchParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FetchParamsCopyWith<$Res> {
  factory $FetchParamsCopyWith(
    FetchParams value,
    $Res Function(FetchParams) then,
  ) = _$FetchParamsCopyWithImpl<$Res, FetchParams>;
  @useResult
  $Res call({
    int? page,
    int? pageSize,
    List<SortRule> sort,
    Map<String, dynamic> filters,
    String? search,
    Map<String, dynamic> dependValues,
    int? retry,
  });
}

/// @nodoc
class _$FetchParamsCopyWithImpl<$Res, $Val extends FetchParams>
    implements $FetchParamsCopyWith<$Res> {
  _$FetchParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FetchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? pageSize = freezed,
    Object? sort = null,
    Object? filters = null,
    Object? search = freezed,
    Object? dependValues = null,
    Object? retry = freezed,
  }) {
    return _then(
      _value.copyWith(
            page: freezed == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int?,
            pageSize: freezed == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            sort: null == sort
                ? _value.sort
                : sort // ignore: cast_nullable_to_non_nullable
                      as List<SortRule>,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            search: freezed == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String?,
            dependValues: null == dependValues
                ? _value.dependValues
                : dependValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            retry: freezed == retry
                ? _value.retry
                : retry // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FetchParamsImplCopyWith<$Res>
    implements $FetchParamsCopyWith<$Res> {
  factory _$$FetchParamsImplCopyWith(
    _$FetchParamsImpl value,
    $Res Function(_$FetchParamsImpl) then,
  ) = __$$FetchParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? page,
    int? pageSize,
    List<SortRule> sort,
    Map<String, dynamic> filters,
    String? search,
    Map<String, dynamic> dependValues,
    int? retry,
  });
}

/// @nodoc
class __$$FetchParamsImplCopyWithImpl<$Res>
    extends _$FetchParamsCopyWithImpl<$Res, _$FetchParamsImpl>
    implements _$$FetchParamsImplCopyWith<$Res> {
  __$$FetchParamsImplCopyWithImpl(
    _$FetchParamsImpl _value,
    $Res Function(_$FetchParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FetchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? pageSize = freezed,
    Object? sort = null,
    Object? filters = null,
    Object? search = freezed,
    Object? dependValues = null,
    Object? retry = freezed,
  }) {
    return _then(
      _$FetchParamsImpl(
        page: freezed == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int?,
        pageSize: freezed == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        sort: null == sort
            ? _value._sort
            : sort // ignore: cast_nullable_to_non_nullable
                  as List<SortRule>,
        filters: null == filters
            ? _value._filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        search: freezed == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String?,
        dependValues: null == dependValues
            ? _value._dependValues
            : dependValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        retry: freezed == retry
            ? _value.retry
            : retry // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FetchParamsImpl implements _FetchParams {
  const _$FetchParamsImpl({
    this.page,
    this.pageSize,
    final List<SortRule> sort = const [],
    final Map<String, dynamic> filters = const {},
    this.search,
    final Map<String, dynamic> dependValues = const {},
    this.retry,
  }) : _sort = sort,
       _filters = filters,
       _dependValues = dependValues;

  factory _$FetchParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FetchParamsImplFromJson(json);

  @override
  final int? page;
  @override
  final int? pageSize;
  final List<SortRule> _sort;
  @override
  @JsonKey()
  List<SortRule> get sort {
    if (_sort is EqualUnmodifiableListView) return _sort;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sort);
  }

  final Map<String, dynamic> _filters;
  @override
  @JsonKey()
  Map<String, dynamic> get filters {
    if (_filters is EqualUnmodifiableMapView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_filters);
  }

  @override
  final String? search;
  final Map<String, dynamic> _dependValues;
  @override
  @JsonKey()
  Map<String, dynamic> get dependValues {
    if (_dependValues is EqualUnmodifiableMapView) return _dependValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dependValues);
  }

  @override
  final int? retry;

  @override
  String toString() {
    return 'FetchParams(page: $page, pageSize: $pageSize, sort: $sort, filters: $filters, search: $search, dependValues: $dependValues, retry: $retry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchParamsImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            const DeepCollectionEquality().equals(other._sort, _sort) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.search, search) || other.search == search) &&
            const DeepCollectionEquality().equals(
              other._dependValues,
              _dependValues,
            ) &&
            (identical(other.retry, retry) || other.retry == retry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    page,
    pageSize,
    const DeepCollectionEquality().hash(_sort),
    const DeepCollectionEquality().hash(_filters),
    search,
    const DeepCollectionEquality().hash(_dependValues),
    retry,
  );

  /// Create a copy of FetchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchParamsImplCopyWith<_$FetchParamsImpl> get copyWith =>
      __$$FetchParamsImplCopyWithImpl<_$FetchParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FetchParamsImplToJson(this);
  }
}

abstract class _FetchParams implements FetchParams {
  const factory _FetchParams({
    final int? page,
    final int? pageSize,
    final List<SortRule> sort,
    final Map<String, dynamic> filters,
    final String? search,
    final Map<String, dynamic> dependValues,
    final int? retry,
  }) = _$FetchParamsImpl;

  factory _FetchParams.fromJson(Map<String, dynamic> json) =
      _$FetchParamsImpl.fromJson;

  @override
  int? get page;
  @override
  int? get pageSize;
  @override
  List<SortRule> get sort;
  @override
  Map<String, dynamic> get filters;
  @override
  String? get search;
  @override
  Map<String, dynamic> get dependValues;
  @override
  int? get retry;

  /// Create a copy of FetchParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FetchParamsImplCopyWith<_$FetchParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SortRule _$SortRuleFromJson(Map<String, dynamic> json) {
  return _SortRule.fromJson(json);
}

/// @nodoc
mixin _$SortRule {
  String get field => throw _privateConstructorUsedError;
  SortDirection get direction => throw _privateConstructorUsedError;

  /// Serializes this SortRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SortRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SortRuleCopyWith<SortRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SortRuleCopyWith<$Res> {
  factory $SortRuleCopyWith(SortRule value, $Res Function(SortRule) then) =
      _$SortRuleCopyWithImpl<$Res, SortRule>;
  @useResult
  $Res call({String field, SortDirection direction});
}

/// @nodoc
class _$SortRuleCopyWithImpl<$Res, $Val extends SortRule>
    implements $SortRuleCopyWith<$Res> {
  _$SortRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SortRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field = null, Object? direction = null}) {
    return _then(
      _value.copyWith(
            field: null == field
                ? _value.field
                : field // ignore: cast_nullable_to_non_nullable
                      as String,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as SortDirection,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SortRuleImplCopyWith<$Res>
    implements $SortRuleCopyWith<$Res> {
  factory _$$SortRuleImplCopyWith(
    _$SortRuleImpl value,
    $Res Function(_$SortRuleImpl) then,
  ) = __$$SortRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field, SortDirection direction});
}

/// @nodoc
class __$$SortRuleImplCopyWithImpl<$Res>
    extends _$SortRuleCopyWithImpl<$Res, _$SortRuleImpl>
    implements _$$SortRuleImplCopyWith<$Res> {
  __$$SortRuleImplCopyWithImpl(
    _$SortRuleImpl _value,
    $Res Function(_$SortRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SortRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field = null, Object? direction = null}) {
    return _then(
      _$SortRuleImpl(
        field: null == field
            ? _value.field
            : field // ignore: cast_nullable_to_non_nullable
                  as String,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as SortDirection,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SortRuleImpl implements _SortRule {
  const _$SortRuleImpl({
    required this.field,
    this.direction = SortDirection.asc,
  });

  factory _$SortRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$SortRuleImplFromJson(json);

  @override
  final String field;
  @override
  @JsonKey()
  final SortDirection direction;

  @override
  String toString() {
    return 'SortRule(field: $field, direction: $direction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SortRuleImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.direction, direction) ||
                other.direction == direction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, field, direction);

  /// Create a copy of SortRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SortRuleImplCopyWith<_$SortRuleImpl> get copyWith =>
      __$$SortRuleImplCopyWithImpl<_$SortRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SortRuleImplToJson(this);
  }
}

abstract class _SortRule implements SortRule {
  const factory _SortRule({
    required final String field,
    final SortDirection direction,
  }) = _$SortRuleImpl;

  factory _SortRule.fromJson(Map<String, dynamic> json) =
      _$SortRuleImpl.fromJson;

  @override
  String get field;
  @override
  SortDirection get direction;

  /// Create a copy of SortRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SortRuleImplCopyWith<_$SortRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FetchResult _$FetchResultFromJson(Map<String, dynamic> json) {
  return _FetchResult.fromJson(json);
}

/// @nodoc
mixin _$FetchResult {
  List<dynamic> get data => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  Object? get error => throw _privateConstructorUsedError;

  /// Serializes this FetchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FetchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FetchResultCopyWith<FetchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FetchResultCopyWith<$Res> {
  factory $FetchResultCopyWith(
    FetchResult value,
    $Res Function(FetchResult) then,
  ) = _$FetchResultCopyWithImpl<$Res, FetchResult>;
  @useResult
  $Res call({List<dynamic> data, int total, Object? error});
}

/// @nodoc
class _$FetchResultCopyWithImpl<$Res, $Val extends FetchResult>
    implements $FetchResultCopyWith<$Res> {
  _$FetchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FetchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? total = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            error: freezed == error ? _value.error : error,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FetchResultImplCopyWith<$Res>
    implements $FetchResultCopyWith<$Res> {
  factory _$$FetchResultImplCopyWith(
    _$FetchResultImpl value,
    $Res Function(_$FetchResultImpl) then,
  ) = __$$FetchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<dynamic> data, int total, Object? error});
}

/// @nodoc
class __$$FetchResultImplCopyWithImpl<$Res>
    extends _$FetchResultCopyWithImpl<$Res, _$FetchResultImpl>
    implements _$$FetchResultImplCopyWith<$Res> {
  __$$FetchResultImplCopyWithImpl(
    _$FetchResultImpl _value,
    $Res Function(_$FetchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FetchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? total = null,
    Object? error = freezed,
  }) {
    return _then(
      _$FetchResultImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FetchResultImpl implements _FetchResult {
  const _$FetchResultImpl({
    final List<dynamic> data = const [],
    this.total = 0,
    this.error,
  }) : _data = data;

  factory _$FetchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FetchResultImplFromJson(json);

  final List<dynamic> _data;
  @override
  @JsonKey()
  List<dynamic> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  @JsonKey()
  final int total;
  @override
  final Object? error;

  @override
  String toString() {
    return 'FetchResult(data: $data, total: $total, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchResultImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    total,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of FetchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchResultImplCopyWith<_$FetchResultImpl> get copyWith =>
      __$$FetchResultImplCopyWithImpl<_$FetchResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FetchResultImplToJson(this);
  }
}

abstract class _FetchResult implements FetchResult {
  const factory _FetchResult({
    final List<dynamic> data,
    final int total,
    final Object? error,
  }) = _$FetchResultImpl;

  factory _FetchResult.fromJson(Map<String, dynamic> json) =
      _$FetchResultImpl.fromJson;

  @override
  List<dynamic> get data;
  @override
  int get total;
  @override
  Object? get error;

  /// Create a copy of FetchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FetchResultImplCopyWith<_$FetchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DataSource _$DataSourceFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'local':
      return DataSourceLocal.fromJson(json);
    case 'fetcher':
      return DataSourceFetcher.fromJson(json);
    case 'url':
      return DataSourceUrl.fromJson(json);
    case 'model':
      return DataSourceModel.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'DataSource',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$DataSource {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<dynamic> data) local,
    required TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )
    fetcher,
    required TResult Function(String url, Map<String, String> headers) url,
    required TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )
    model,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<dynamic> data)? local,
    TResult? Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult? Function(String url, Map<String, String> headers)? url,
    TResult? Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<dynamic> data)? local,
    TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult Function(String url, Map<String, String> headers)? url,
    TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataSourceLocal value) local,
    required TResult Function(DataSourceFetcher value) fetcher,
    required TResult Function(DataSourceUrl value) url,
    required TResult Function(DataSourceModel value) model,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataSourceLocal value)? local,
    TResult? Function(DataSourceFetcher value)? fetcher,
    TResult? Function(DataSourceUrl value)? url,
    TResult? Function(DataSourceModel value)? model,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataSourceLocal value)? local,
    TResult Function(DataSourceFetcher value)? fetcher,
    TResult Function(DataSourceUrl value)? url,
    TResult Function(DataSourceModel value)? model,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this DataSource to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataSourceCopyWith<$Res> {
  factory $DataSourceCopyWith(
    DataSource value,
    $Res Function(DataSource) then,
  ) = _$DataSourceCopyWithImpl<$Res, DataSource>;
}

/// @nodoc
class _$DataSourceCopyWithImpl<$Res, $Val extends DataSource>
    implements $DataSourceCopyWith<$Res> {
  _$DataSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DataSourceLocalImplCopyWith<$Res> {
  factory _$$DataSourceLocalImplCopyWith(
    _$DataSourceLocalImpl value,
    $Res Function(_$DataSourceLocalImpl) then,
  ) = __$$DataSourceLocalImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<dynamic> data});
}

/// @nodoc
class __$$DataSourceLocalImplCopyWithImpl<$Res>
    extends _$DataSourceCopyWithImpl<$Res, _$DataSourceLocalImpl>
    implements _$$DataSourceLocalImplCopyWith<$Res> {
  __$$DataSourceLocalImplCopyWithImpl(
    _$DataSourceLocalImpl _value,
    $Res Function(_$DataSourceLocalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$DataSourceLocalImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DataSourceLocalImpl implements DataSourceLocal {
  const _$DataSourceLocalImpl({
    final List<dynamic> data = const [],
    final String? $type,
  }) : _data = data,
       $type = $type ?? 'local';

  factory _$DataSourceLocalImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataSourceLocalImplFromJson(json);

  final List<dynamic> _data;
  @override
  @JsonKey()
  List<dynamic> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'DataSource.local(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataSourceLocalImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataSourceLocalImplCopyWith<_$DataSourceLocalImpl> get copyWith =>
      __$$DataSourceLocalImplCopyWithImpl<_$DataSourceLocalImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<dynamic> data) local,
    required TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )
    fetcher,
    required TResult Function(String url, Map<String, String> headers) url,
    required TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )
    model,
  }) {
    return local(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<dynamic> data)? local,
    TResult? Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult? Function(String url, Map<String, String> headers)? url,
    TResult? Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
  }) {
    return local?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<dynamic> data)? local,
    TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult Function(String url, Map<String, String> headers)? url,
    TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataSourceLocal value) local,
    required TResult Function(DataSourceFetcher value) fetcher,
    required TResult Function(DataSourceUrl value) url,
    required TResult Function(DataSourceModel value) model,
  }) {
    return local(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataSourceLocal value)? local,
    TResult? Function(DataSourceFetcher value)? fetcher,
    TResult? Function(DataSourceUrl value)? url,
    TResult? Function(DataSourceModel value)? model,
  }) {
    return local?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataSourceLocal value)? local,
    TResult Function(DataSourceFetcher value)? fetcher,
    TResult Function(DataSourceUrl value)? url,
    TResult Function(DataSourceModel value)? model,
    required TResult orElse(),
  }) {
    if (local != null) {
      return local(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DataSourceLocalImplToJson(this);
  }
}

abstract class DataSourceLocal implements DataSource {
  const factory DataSourceLocal({final List<dynamic> data}) =
      _$DataSourceLocalImpl;

  factory DataSourceLocal.fromJson(Map<String, dynamic> json) =
      _$DataSourceLocalImpl.fromJson;

  List<dynamic> get data;

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataSourceLocalImplCopyWith<_$DataSourceLocalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DataSourceFetcherImplCopyWith<$Res> {
  factory _$$DataSourceFetcherImplCopyWith(
    _$DataSourceFetcherImpl value,
    $Res Function(_$DataSourceFetcherImpl) then,
  ) = __$$DataSourceFetcherImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false)
    FetchResult Function(FetchParams)? fetcher,
  });
}

/// @nodoc
class __$$DataSourceFetcherImplCopyWithImpl<$Res>
    extends _$DataSourceCopyWithImpl<$Res, _$DataSourceFetcherImpl>
    implements _$$DataSourceFetcherImplCopyWith<$Res> {
  __$$DataSourceFetcherImplCopyWithImpl(
    _$DataSourceFetcherImpl _value,
    $Res Function(_$DataSourceFetcherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? fetcher = freezed}) {
    return _then(
      _$DataSourceFetcherImpl(
        fetcher: freezed == fetcher
            ? _value.fetcher
            : fetcher // ignore: cast_nullable_to_non_nullable
                  as FetchResult Function(FetchParams)?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DataSourceFetcherImpl implements DataSourceFetcher {
  const _$DataSourceFetcherImpl({
    @JsonKey(includeFromJson: false, includeToJson: false) this.fetcher,
    final String? $type,
  }) : $type = $type ?? 'fetcher';

  factory _$DataSourceFetcherImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataSourceFetcherImplFromJson(json);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final FetchResult Function(FetchParams)? fetcher;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'DataSource.fetcher(fetcher: $fetcher)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataSourceFetcherImpl &&
            (identical(other.fetcher, fetcher) || other.fetcher == fetcher));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fetcher);

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataSourceFetcherImplCopyWith<_$DataSourceFetcherImpl> get copyWith =>
      __$$DataSourceFetcherImplCopyWithImpl<_$DataSourceFetcherImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<dynamic> data) local,
    required TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )
    fetcher,
    required TResult Function(String url, Map<String, String> headers) url,
    required TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )
    model,
  }) {
    return fetcher(this.fetcher);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<dynamic> data)? local,
    TResult? Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult? Function(String url, Map<String, String> headers)? url,
    TResult? Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
  }) {
    return fetcher?.call(this.fetcher);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<dynamic> data)? local,
    TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult Function(String url, Map<String, String> headers)? url,
    TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
    required TResult orElse(),
  }) {
    if (fetcher != null) {
      return fetcher(this.fetcher);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataSourceLocal value) local,
    required TResult Function(DataSourceFetcher value) fetcher,
    required TResult Function(DataSourceUrl value) url,
    required TResult Function(DataSourceModel value) model,
  }) {
    return fetcher(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataSourceLocal value)? local,
    TResult? Function(DataSourceFetcher value)? fetcher,
    TResult? Function(DataSourceUrl value)? url,
    TResult? Function(DataSourceModel value)? model,
  }) {
    return fetcher?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataSourceLocal value)? local,
    TResult Function(DataSourceFetcher value)? fetcher,
    TResult Function(DataSourceUrl value)? url,
    TResult Function(DataSourceModel value)? model,
    required TResult orElse(),
  }) {
    if (fetcher != null) {
      return fetcher(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DataSourceFetcherImplToJson(this);
  }
}

abstract class DataSourceFetcher implements DataSource {
  const factory DataSourceFetcher({
    @JsonKey(includeFromJson: false, includeToJson: false)
    final FetchResult Function(FetchParams)? fetcher,
  }) = _$DataSourceFetcherImpl;

  factory DataSourceFetcher.fromJson(Map<String, dynamic> json) =
      _$DataSourceFetcherImpl.fromJson;

  @JsonKey(includeFromJson: false, includeToJson: false)
  FetchResult Function(FetchParams)? get fetcher;

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataSourceFetcherImplCopyWith<_$DataSourceFetcherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DataSourceUrlImplCopyWith<$Res> {
  factory _$$DataSourceUrlImplCopyWith(
    _$DataSourceUrlImpl value,
    $Res Function(_$DataSourceUrlImpl) then,
  ) = __$$DataSourceUrlImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String url, Map<String, String> headers});
}

/// @nodoc
class __$$DataSourceUrlImplCopyWithImpl<$Res>
    extends _$DataSourceCopyWithImpl<$Res, _$DataSourceUrlImpl>
    implements _$$DataSourceUrlImplCopyWith<$Res> {
  __$$DataSourceUrlImplCopyWithImpl(
    _$DataSourceUrlImpl _value,
    $Res Function(_$DataSourceUrlImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? url = null, Object? headers = null}) {
    return _then(
      _$DataSourceUrlImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        headers: null == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DataSourceUrlImpl implements DataSourceUrl {
  const _$DataSourceUrlImpl({
    required this.url,
    final Map<String, String> headers = const {},
    final String? $type,
  }) : _headers = headers,
       $type = $type ?? 'url';

  factory _$DataSourceUrlImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataSourceUrlImplFromJson(json);

  @override
  final String url;
  final Map<String, String> _headers;
  @override
  @JsonKey()
  Map<String, String> get headers {
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_headers);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'DataSource.url(url: $url, headers: $headers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataSourceUrlImpl &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._headers, _headers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    url,
    const DeepCollectionEquality().hash(_headers),
  );

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataSourceUrlImplCopyWith<_$DataSourceUrlImpl> get copyWith =>
      __$$DataSourceUrlImplCopyWithImpl<_$DataSourceUrlImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<dynamic> data) local,
    required TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )
    fetcher,
    required TResult Function(String url, Map<String, String> headers) url,
    required TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )
    model,
  }) {
    return url(this.url, headers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<dynamic> data)? local,
    TResult? Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult? Function(String url, Map<String, String> headers)? url,
    TResult? Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
  }) {
    return url?.call(this.url, headers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<dynamic> data)? local,
    TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult Function(String url, Map<String, String> headers)? url,
    TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
    required TResult orElse(),
  }) {
    if (url != null) {
      return url(this.url, headers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataSourceLocal value) local,
    required TResult Function(DataSourceFetcher value) fetcher,
    required TResult Function(DataSourceUrl value) url,
    required TResult Function(DataSourceModel value) model,
  }) {
    return url(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataSourceLocal value)? local,
    TResult? Function(DataSourceFetcher value)? fetcher,
    TResult? Function(DataSourceUrl value)? url,
    TResult? Function(DataSourceModel value)? model,
  }) {
    return url?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataSourceLocal value)? local,
    TResult Function(DataSourceFetcher value)? fetcher,
    TResult Function(DataSourceUrl value)? url,
    TResult Function(DataSourceModel value)? model,
    required TResult orElse(),
  }) {
    if (url != null) {
      return url(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DataSourceUrlImplToJson(this);
  }
}

abstract class DataSourceUrl implements DataSource {
  const factory DataSourceUrl({
    required final String url,
    final Map<String, String> headers,
  }) = _$DataSourceUrlImpl;

  factory DataSourceUrl.fromJson(Map<String, dynamic> json) =
      _$DataSourceUrlImpl.fromJson;

  String get url;
  Map<String, String> get headers;

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataSourceUrlImplCopyWith<_$DataSourceUrlImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DataSourceModelImplCopyWith<$Res> {
  factory _$$DataSourceModelImplCopyWith(
    _$DataSourceModelImpl value,
    $Res Function(_$DataSourceModelImpl) then,
  ) = __$$DataSourceModelImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String name,
    @JsonKey(includeFromJson: false, includeToJson: false)
    ModelAdapter? adapter,
  });
}

/// @nodoc
class __$$DataSourceModelImplCopyWithImpl<$Res>
    extends _$DataSourceCopyWithImpl<$Res, _$DataSourceModelImpl>
    implements _$$DataSourceModelImplCopyWith<$Res> {
  __$$DataSourceModelImplCopyWithImpl(
    _$DataSourceModelImpl _value,
    $Res Function(_$DataSourceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? adapter = freezed}) {
    return _then(
      _$DataSourceModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        adapter: freezed == adapter
            ? _value.adapter
            : adapter // ignore: cast_nullable_to_non_nullable
                  as ModelAdapter?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DataSourceModelImpl implements DataSourceModel {
  const _$DataSourceModelImpl({
    required this.name,
    @JsonKey(includeFromJson: false, includeToJson: false) this.adapter,
    final String? $type,
  }) : $type = $type ?? 'model';

  factory _$DataSourceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataSourceModelImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ModelAdapter? adapter;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'DataSource.model(name: $name, adapter: $adapter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataSourceModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.adapter, adapter) || other.adapter == adapter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, adapter);

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataSourceModelImplCopyWith<_$DataSourceModelImpl> get copyWith =>
      __$$DataSourceModelImplCopyWithImpl<_$DataSourceModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<dynamic> data) local,
    required TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )
    fetcher,
    required TResult Function(String url, Map<String, String> headers) url,
    required TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )
    model,
  }) {
    return model(name, adapter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<dynamic> data)? local,
    TResult? Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult? Function(String url, Map<String, String> headers)? url,
    TResult? Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
  }) {
    return model?.call(name, adapter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<dynamic> data)? local,
    TResult Function(
      @JsonKey(includeFromJson: false, includeToJson: false)
      FetchResult Function(FetchParams)? fetcher,
    )?
    fetcher,
    TResult Function(String url, Map<String, String> headers)? url,
    TResult Function(
      String name,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ModelAdapter? adapter,
    )?
    model,
    required TResult orElse(),
  }) {
    if (model != null) {
      return model(name, adapter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataSourceLocal value) local,
    required TResult Function(DataSourceFetcher value) fetcher,
    required TResult Function(DataSourceUrl value) url,
    required TResult Function(DataSourceModel value) model,
  }) {
    return model(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataSourceLocal value)? local,
    TResult? Function(DataSourceFetcher value)? fetcher,
    TResult? Function(DataSourceUrl value)? url,
    TResult? Function(DataSourceModel value)? model,
  }) {
    return model?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataSourceLocal value)? local,
    TResult Function(DataSourceFetcher value)? fetcher,
    TResult Function(DataSourceUrl value)? url,
    TResult Function(DataSourceModel value)? model,
    required TResult orElse(),
  }) {
    if (model != null) {
      return model(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DataSourceModelImplToJson(this);
  }
}

abstract class DataSourceModel implements DataSource {
  const factory DataSourceModel({
    required final String name,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final ModelAdapter? adapter,
  }) = _$DataSourceModelImpl;

  factory DataSourceModel.fromJson(Map<String, dynamic> json) =
      _$DataSourceModelImpl.fromJson;

  String get name;
  @JsonKey(includeFromJson: false, includeToJson: false)
  ModelAdapter? get adapter;

  /// Create a copy of DataSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataSourceModelImplCopyWith<_$DataSourceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
