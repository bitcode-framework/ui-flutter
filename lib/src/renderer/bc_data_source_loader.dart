library bc_data_source_loader;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../schema/ui_schema_types.dart';

/// Canonical empty result returned by every null/empty-source path.
///
/// VAL-DSL-090, VAL-DSL-091: all null/empty-source paths produce the same
/// structurally identical `FetchResult` shape.
FetchResult _emptyResult() => const FetchResult();

/// Loads data from a [DataSource] (or `null`) and returns a [FetchResult].
///
/// Handles all four [DataSource] variants:
///   - [DataSourceLocal]   — returns inline `data` list synchronously
///   - [DataSourceFetcher] — calls the sync fetcher function
///   - [DataSourceUrl]     — HTTP GET via an injectable [http.Client]
///   - [DataSourceModel]   — calls the [ModelAdapter.list] method
///
/// The Future always completes — failures are captured into
/// `FetchResult.error` rather than propagated as exceptions
/// (VAL-DSL-026, VAL-DSL-044, VAL-DSL-065, VAL-DSL-102, VAL-DSL-103).
///
/// Pass [client] to inject an `http.Client` for deterministic URL testing
/// without public internet access (VAL-DSL-052). When omitted the default
/// `http.Client()` is used in production.
Future<FetchResult> loadDataSource(
  DataSource? source, {
  FetchParams? params,
  http.Client? client,
}) async {
  if (source == null) {
    return _emptyResult();
  }

  return switch (source) {
    DataSourceLocal(:final data) => _loadLocal(data),
    DataSourceFetcher(:final fetcher) => _loadFetcher(fetcher, params),
    DataSourceUrl(:final url, :final headers) =>
      _loadUrl(url, headers, params, client ?? http.Client()),
    DataSourceModel(:final name, :final adapter) =>
      _loadModel(name, adapter, params),
  };
}

// ---------------------------------------------------------------------------
// DataSourceLocal
// ---------------------------------------------------------------------------

FetchResult _loadLocal(List<dynamic> data) {
  return FetchResult(
    data: data,
    total: data.length,
  );
}

// ---------------------------------------------------------------------------
// DataSourceFetcher
// ---------------------------------------------------------------------------

FetchResult _loadFetcher(
  FetchResult Function(FetchParams params)? fetcher,
  FetchParams? params,
) {
  // VAL-DSL-022, VAL-DSL-028: null fetcher returns canonical empty result.
  if (fetcher == null) {
    return _emptyResult();
  }

  // VAL-DSL-023: default params when not provided.
  final effectiveParams = params ?? const FetchParams();

  // VAL-DSL-026: capture sync exceptions thrown by the fetcher.
  try {
    // VAL-DSL-025: return the fetcher's result without mutation.
    return fetcher(effectiveParams);
  } catch (e) {
    return FetchResult(error: e);
  }
}

// ---------------------------------------------------------------------------
// DataSourceUrl
// ---------------------------------------------------------------------------

Future<FetchResult> _loadUrl(
  String url,
  Map<String, String> headers,
  FetchParams? params,
  http.Client client,
) async {
  try {
    final uri = _buildUri(url, params);

    // VAL-DSL-050, VAL-DSL-054: forward caller headers as-is.
    final response = await client.get(uri, headers: headers);

    // VAL-DSL-041: non-200 status captured as error.
    if (response.statusCode != 200) {
      return FetchResult(
        error: 'HTTP ${response.statusCode}',
      );
    }

    // VAL-DSL-042: invalid JSON captured as error.
    final decoded = jsonDecode(response.body);

    // VAL-DSL-031..035, VAL-DSL-045..049: parse body.
    return _parseUrlBody(decoded);
  } catch (e) {
    // VAL-DSL-040, VAL-DSL-044, VAL-DSL-103: network/parse errors captured.
    return FetchResult(error: e);
  } finally {
    client.close();
  }
}

/// Builds the request [Uri], merging FetchParams into query parameters
/// (VAL-DSL-053) without dropping caller-supplied existing query params.
Uri _buildUri(String url, FetchParams? params) {
  final uri = Uri.parse(url);

  if (params == null) {
    return uri;
  }

  final queryParams = Map<String, String>.from(uri.queryParameters);

  if (params.page != null) {
    queryParams['page'] = params.page.toString();
  }
  if (params.pageSize != null) {
    queryParams['pageSize'] = params.pageSize.toString();
  }
  if (params.search != null && params.search!.isNotEmpty) {
    queryParams['search'] = params.search!;
  }

  // Sort rules → sort[field]=direction pairs.
  for (final rule in params.sort) {
    final direction =
        rule.direction == SortDirection.desc ? 'desc' : 'asc';
    queryParams['sort[${rule.field}]'] = direction;
  }

  // Filters → filter[key]=value pairs.
  for (final entry in params.filters.entries) {
    queryParams['filter[${entry.key}]'] = entry.value.toString();
  }

  return uri.replace(queryParameters: queryParams);
}

/// Parses the decoded JSON body into a [FetchResult].
///
/// Supports (VAL-DSL-031..035, VAL-DSL-045..049):
///   - JSON array → data is the array, total is array length
///   - JSON object with `data`/`items`/`rows` list key → that list as data
///   - Total aliases: `total` (precedence), then `count`, then `totalCount`
///   - Fallback: total = data length when no alias present
FetchResult _parseUrlBody(Object? decoded) {
  if (decoded is List) {
    return FetchResult(
      data: decoded,
      total: decoded.length,
    );
  }

  if (decoded is Map) {
    final data = _extractListKey(decoded, const ['data', 'items', 'rows']);

    final total = _extractTotal(decoded) ?? data.length;

    return FetchResult(
      data: data,
      total: total,
    );
  }

  // VAL-DSL-043: non-list, non-object-with-list → empty.
  return _emptyResult();
}

/// Extracts the first matching list-valued key from a JSON object map.
List<dynamic> _extractListKey(Map map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) {
      return value;
    }
  }
  return const [];
}

/// Extracts total from the first matching alias key.
/// Precedence: `total` > `count` > `totalCount` (VAL-DSL-048).
int? _extractTotal(Map map) {
  for (final key in const ['total', 'count', 'totalCount']) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// DataSourceModel
// ---------------------------------------------------------------------------

Future<FetchResult> _loadModel(
  String name,
  ModelAdapter? adapter,
  FetchParams? params,
) async {
  // VAL-DSL-062: null adapter returns canonical empty result.
  if (adapter == null) {
    return _emptyResult();
  }

  // VAL-DSL-063: default params when not provided.
  final effectiveParams = params ?? const FetchParams();

  // VAL-DSL-065: capture adapter thrown exceptions.
  try {
    // VAL-DSL-061: return the adapter's result.
    return await adapter.list(name, effectiveParams);
  } catch (e) {
    return FetchResult(error: e);
  }
}
