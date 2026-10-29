// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_schema_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FetchParamsImpl _$$FetchParamsImplFromJson(Map<String, dynamic> json) =>
    _$FetchParamsImpl(
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      sort:
          (json['sort'] as List<dynamic>?)
              ?.map((e) => SortRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      filters: json['filters'] as Map<String, dynamic>? ?? const {},
      search: json['search'] as String?,
      dependValues: json['dependValues'] as Map<String, dynamic>? ?? const {},
      retry: (json['retry'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$FetchParamsImplToJson(_$FetchParamsImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'sort': instance.sort,
      'filters': instance.filters,
      'search': instance.search,
      'dependValues': instance.dependValues,
      'retry': instance.retry,
    };

_$SortRuleImpl _$$SortRuleImplFromJson(Map<String, dynamic> json) =>
    _$SortRuleImpl(
      field: json['field'] as String,
      direction:
          $enumDecodeNullable(_$SortDirectionEnumMap, json['direction']) ??
          SortDirection.asc,
    );

Map<String, dynamic> _$$SortRuleImplToJson(_$SortRuleImpl instance) =>
    <String, dynamic>{
      'field': instance.field,
      'direction': _$SortDirectionEnumMap[instance.direction]!,
    };

const _$SortDirectionEnumMap = {
  SortDirection.asc: 'asc',
  SortDirection.desc: 'desc',
};

_$FetchResultImpl _$$FetchResultImplFromJson(Map<String, dynamic> json) =>
    _$FetchResultImpl(
      data: json['data'] as List<dynamic>? ?? const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      error: json['error'],
    );

Map<String, dynamic> _$$FetchResultImplToJson(_$FetchResultImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'error': instance.error,
    };

_$DataSourceLocalImpl _$$DataSourceLocalImplFromJson(
  Map<String, dynamic> json,
) => _$DataSourceLocalImpl(
  data: json['data'] as List<dynamic>? ?? const [],
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$DataSourceLocalImplToJson(
  _$DataSourceLocalImpl instance,
) => <String, dynamic>{'data': instance.data, 'runtimeType': instance.$type};

_$DataSourceFetcherImpl _$$DataSourceFetcherImplFromJson(
  Map<String, dynamic> json,
) => _$DataSourceFetcherImpl($type: json['runtimeType'] as String?);

Map<String, dynamic> _$$DataSourceFetcherImplToJson(
  _$DataSourceFetcherImpl instance,
) => <String, dynamic>{'runtimeType': instance.$type};

_$DataSourceUrlImpl _$$DataSourceUrlImplFromJson(Map<String, dynamic> json) =>
    _$DataSourceUrlImpl(
      url: json['url'] as String,
      headers:
          (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$DataSourceUrlImplToJson(_$DataSourceUrlImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'headers': instance.headers,
      'runtimeType': instance.$type,
    };

_$DataSourceModelImpl _$$DataSourceModelImplFromJson(
  Map<String, dynamic> json,
) => _$DataSourceModelImpl(
  name: json['name'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$DataSourceModelImplToJson(
  _$DataSourceModelImpl instance,
) => <String, dynamic>{'name': instance.name, 'runtimeType': instance.$type};
