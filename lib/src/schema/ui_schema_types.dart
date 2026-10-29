/// Shared types ported from @bitcode/ui-schema/src/types.ts (ADR-011 Section 6).
///
/// Framework-agnostic types shared across all UI renderers. Pure Dart data
/// classes + freezed for immutability + json_serializable for round-tripping
/// the same JSON documents the TS renderer consumes.

library ui_schema_types;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_schema_types.freezed.dart';
part 'ui_schema_types.g.dart';

// --- Theme -----------------------------------------------------------------

/// User-facing theme mode preference. `'system'` defers to the platform
/// brightness at resolve time.
enum ThemeMode { light, dark, system }

/// Concrete resolved theme after applying [ThemeMode] against the platform.
enum ResolvedTheme { light, dark }

// --- Component sizing ------------------------------------------------------

/// Component size variants (sm / md / lg).
///
/// Mirrors TS `ComponentSize`. Kept separate from [BcComponentSize] in
/// `core/types.dart` to stay faithful to the schema package surface; the two
/// are structurally identical and convertible via [BcComponentSize.values].
enum ComponentSize { sm, md, lg }

/// Visual variants for buttons / actions.
///
/// Mirrors TS `ComponentVariant`. Same order as `core/types.dart`
/// [BcComponentVariant] (defaultVariant, primary, secondary, destructive,
/// outline, ghost, link).
enum ComponentVariant {
  defaultVariant,
  primary,
  secondary,
  destructive,
  outline,
  ghost,
  link,
}

// --- Input types -----------------------------------------------------------

/// Native HTML input type strings. Mirrors TS `InputType`.
///
/// Used by `FieldNode` / `BcInput` to select the right keyboard / picker.
/// `datetimeLocal` maps the TS `datetime-local` value (kebab→camel).
enum InputType {
  text,
  email,
  password,
  tel,
  url,
  search,
  number,
  date,
  time,
  datetimeLocal,
  color,
  file,
  hidden,
}

/// Input size variants. Mirrors TS `InputSize`.
enum InputSize { sm, md, lg }

/// Validation lifecycle status. Mirrors TS `ValidationStatus`.
enum ValidationStatus { none, validating, valid, invalid }

// --- Collection ------------------------------------------------------------

/// Key type for selection and collection identifiers (string or int).
typedef BcKey = Object;

/// Selection state for collection widgets. Sealed union mirroring TS
/// `BcSelection = 'all' | Set<BcKey> | BcKey[]`.
///
/// Three variants:
///   - [BcSelectionAll]  → 'all' (every row selected)
///   - [BcSelectionSet]  → explicit [Set] of keys
///   - [BcSelectionList] → explicit [List] of keys (order preserved)
///
/// Runtime-only (not JSON-serialized): the `Set`/`Object` key shapes do not
/// round-trip cleanly through json_serializable, and selection is live UI
/// state rather than a schema document. Consumers construct it in Dart.
@freezed
sealed class BcSelection with _$BcSelection {
  const factory BcSelection.all() = BcSelectionAll;
  const factory BcSelection.set(Set<BcKey> keys) = BcSelectionSet;
  const factory BcSelection.list(List<BcKey> keys) = BcSelectionList;
}

// --- Data Source (4-Layer) -------------------------------------------------

/// Fetch parameters for server-backed data sources. Mirrors TS `FetchParams`.
///
/// `signal` (AbortSignal) and `retry` carry no direct Dart equivalent in this
/// headless port; callers wire cancellation through the [ModelAdapter]
/// implementation. They are retained on the model for schema fidelity.
@freezed
class FetchParams with _$FetchParams {
  const factory FetchParams({
    int? page,
    int? pageSize,
    @Default([]) List<SortRule> sort,
    @Default({}) Map<String, dynamic> filters,
    String? search,
    @Default({}) Map<String, dynamic> dependValues,
    int? retry,
  }) = _FetchParams;

  factory FetchParams.fromJson(Map<String, dynamic> json) =>
      _$FetchParamsFromJson(json);
}

/// Single sort rule. `direction` is `'asc' | 'desc'`.
@freezed
class SortRule with _$SortRule {
  const factory SortRule({
    required String field,
    @Default(SortDirection.asc) SortDirection direction,
  }) = _SortRule;

  factory SortRule.fromJson(Map<String, dynamic> json) =>
      _$SortRuleFromJson(json);
}

enum SortDirection { asc, desc }

/// Fetch result envelope. Mirrors TS `FetchResult`.
///
/// `error` is typed as [Object] (instead of JS `Error`) so the headless port
/// keeps no platform dependencies. Consumers can store an exception or a
/// plain message string.
@freezed
class FetchResult with _$FetchResult {
  const factory FetchResult({
    @Default([]) List<dynamic> data,
    @Default(0) int total,
    Object? error,
  }) = _FetchResult;

  factory FetchResult.fromJson(Map<String, dynamic> json) =>
      _$FetchResultFromJson(json);
}

/// Model adapter contract for server-backed data sources. Mirrors TS
/// `ModelAdapter`.
///
/// Implementations talk to the BitCode engine REST API, an offline cache, or
/// a test fixture. Methods are async to match the TS surface.
abstract class ModelAdapter {
  Future<FetchResult> list(String model, FetchParams params);
  Future<List<dynamic>> search(String model, String query);
  bool isOffline(String model);
}

/// 4-layer data source. Sealed union mirroring TS `DataSource`.
///
/// Variants:
///   - [DataSourceLocal]   → inline `data: unknown[]`
///   - [DataSourceFetcher] → `fetcher: (params) => Future<FetchResult>`
///   - [DataSourceUrl]     → remote `url` + optional `headers`
///   - [DataSourceModel]   → `name` + optional [ModelAdapter]
///
/// Note: `DataSourceFetcher` and `DataSourceModel` carry functions / adapters
/// that are NOT JSON-serializable. Those fields are excluded from JSON
/// round-tripping; callers must construct those variants in Dart code. Only
/// [DataSourceLocal] and [DataSourceUrl] fully round-trip via JSON.
@freezed
sealed class DataSource with _$DataSource {
  const factory DataSource.local({
    @Default([]) List<dynamic> data,
  }) = DataSourceLocal;

  const factory DataSource.fetcher({
    @JsonKey(includeFromJson: false, includeToJson: false)
    FetchResult Function(FetchParams params)? fetcher,
  }) = DataSourceFetcher;

  const factory DataSource.url({
    required String url,
    @Default({}) Map<String, String> headers,
  }) = DataSourceUrl;

  const factory DataSource.model({
    required String name,
    @JsonKey(includeFromJson: false, includeToJson: false)
    ModelAdapter? adapter,
  }) = DataSourceModel;

  factory DataSource.fromJson(Map<String, dynamic> json) =>
      _$DataSourceFromJson(json);
}
