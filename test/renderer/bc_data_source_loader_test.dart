import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bc_ui_flutter/src/renderer/bc_data_source_loader.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema_types.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a [MockClient] that returns [body] with status [statusCode].
http.Client _okClient(String body, {int statusCode = 200}) {
  return MockClient((request) async {
    return http.Response(body, statusCode, headers: {
      'content-type': 'application/json',
    });
  });
}

/// Creates a [MockClient] that inspects the request and returns [body].
/// The [captured] map records the request URL and headers for assertions.
http.Client _inspectingClient(
  String body, {
  required Map<String, dynamic> captured,
  int statusCode = 200,
}) {
  return MockClient((request) async {
    captured['url'] = request.url.toString();
    captured['method'] = request.method;
    captured['headers'] = Map<String, String>.from(request.headers);
    return http.Response(body, statusCode, headers: {
      'content-type': 'application/json',
    });
  });
}

/// Creates a [MockClient] that throws on every request.
http.Client _throwingClient(Object error) {
  return MockClient((_) async => throw error);
}

/// A fake [ModelAdapter] that records calls and returns a configurable result.
class _RecordingAdapter implements ModelAdapter {
  _RecordingAdapter(this._result);

  final FetchResult _result;
  String? lastModel;
  FetchParams? lastParams;
  int callCount = 0;

  @override
  Future<FetchResult> list(String model, FetchParams params) async {
    lastModel = model;
    lastParams = params;
    callCount++;
    return _result;
  }

  @override
  Future<List<dynamic>> search(String model, String query) async => [];

  @override
  bool isOffline(String model) => false;
}

/// A fake [ModelAdapter] that throws on list.
class _ThrowingAdapter implements ModelAdapter {
  final Object error;
  _ThrowingAdapter(this.error);

  @override
  Future<FetchResult> list(String model, FetchParams params) async => throw error;

  @override
  Future<List<dynamic>> search(String model, String query) async => [];

  @override
  bool isOffline(String model) => false;
}

/// Canonical empty result shape for structural comparisons.
final FetchResult _emptyShape = const FetchResult(
  data: [],
  total: 0,
  error: null,
);

void main() {
  // =========================================================================
  // Area: Null Source Handling
  // =========================================================================
  group('VAL-DSL-001..003 Null source', () {
    test('VAL-DSL-001: null source returns empty FetchResult', () async {
      final result = await loadDataSource(null);
      expect(result.data, isEmpty);
      expect(result.total, 0);
      expect(result.error, isNull);
    });

    test('VAL-DSL-002: null source returns empty even with params', () async {
      final params = FetchParams(page: 1, pageSize: 10, search: 'abc');
      final result = await loadDataSource(null, params: params);
      expect(result.data, isEmpty);
      expect(result.total, 0);
      expect(result.error, isNull);
    });

    test('VAL-DSL-003: null source returns a Future that completes', () async {
      final future = loadDataSource(null);
      expect(future, isA<Future<FetchResult>>());
      final result = await future;
      expect(result, isNotNull);
    });
  });

  // =========================================================================
  // Area: DataSourceLocal
  // =========================================================================
  group('VAL-DSL-010..016 DataSourceLocal', () {
    test('VAL-DSL-010: returns inline data list', () async {
      final result = await loadDataSource(
        const DataSource.local(data: [1, 2, 3]),
      );
      expect(result.data, equals([1, 2, 3]));
    });

    test('VAL-DSL-011: total equals data length', () async {
      final result = await loadDataSource(
        const DataSource.local(data: ['a', 'b', 'c']),
      );
      expect(result.total, 3);
    });

    test('VAL-DSL-012: empty data returns empty result', () async {
      final result = await loadDataSource(const DataSource.local());
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });

    test('VAL-DSL-013: error is null for local data', () async {
      final result = await loadDataSource(
        const DataSource.local(data: [1, 2]),
      );
      expect(result.error, isNull);
    });

    test('VAL-DSL-014: ignores FetchParams', () async {
      final params = FetchParams(
        page: 2,
        pageSize: 1,
        sort: [const SortRule(field: 'x', direction: SortDirection.desc)],
        filters: {'q': 'z'},
      );
      final result = await loadDataSource(
        const DataSource.local(data: [1, 2]),
        params: params,
      );
      expect(result.data, equals([1, 2]));
      expect(result.total, 2);
    });

    test('VAL-DSL-015: preserves data element types', () async {
      final result = await loadDataSource(
        const DataSource.local(data: [
          {'name': 'Alice'},
          {'name': 'Bob'},
        ]),
      );
      expect(result.data[0]['name'], 'Alice');
      expect(result.data[1]['name'], 'Bob');
    });

    test('VAL-DSL-016: preserves mixed types in order', () async {
      final result = await loadDataSource(
        const DataSource.local(data: [1, 'two', true, null]),
      );
      expect(result.data, equals([1, 'two', true, null]));
    });
  });

  // =========================================================================
  // Area: DataSourceFetcher
  // =========================================================================
  group('VAL-DSL-020..028 DataSourceFetcher', () {
    test('VAL-DSL-020: calls fetcher with provided params', () async {
      FetchParams? received;
      final fetcher = (FetchParams p) {
        received = p;
        return const FetchResult(data: [42], total: 1);
      };
      final params = const FetchParams(page: 3, pageSize: 5);
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: params,
      );
      expect(received, isNotNull);
      expect(received!.page, 3);
      expect(received!.pageSize, 5);
    });

    test('VAL-DSL-021: returns the FetchResult from the fetcher', () async {
      final fetcher = (_) =>
          const FetchResult(data: [{'x': 1}], total: 1);
      final result = await loadDataSource(DataSource.fetcher(fetcher: fetcher));
      expect(result.data, equals([{'x': 1}]));
      expect(result.total, 1);
    });

    test('VAL-DSL-022: null fetcher returns empty result', () async {
      final result = await loadDataSource(const DataSource.fetcher());
      expect(result.data, isEmpty);
      expect(result.total, 0);
      expect(result.error, isNull);
    });

    test('VAL-DSL-023: default params when params not provided', () async {
      FetchParams? received;
      final fetcher = (FetchParams p) {
        received = p;
        return const FetchResult();
      };
      await loadDataSource(DataSource.fetcher(fetcher: fetcher));
      expect(received, isNotNull);
      expect(received!.page, isNull);
      expect(received!.pageSize, isNull);
      expect(received!.sort, isEmpty);
      expect(received!.filters, isEmpty);
      expect(received!.search, isNull);
      expect(received!.dependValues, isEmpty);
      expect(received!.retry, isNull);
    });

    test('VAL-DSL-024: propagates fetcher error in FetchResult.error', () async {
      final errorObj = Exception('boom');
      final fetcher = (_) => FetchResult(error: errorObj);
      final result = await loadDataSource(DataSource.fetcher(fetcher: fetcher));
      expect(result.error, same(errorObj));
    });

    test('VAL-DSL-025: does not mutate fetcher return value', () async {
      final original = const FetchResult(data: [1, 2], total: 2);
      final fetcher = (_) => original;
      final result = await loadDataSource(DataSource.fetcher(fetcher: fetcher));
      expect(result.data, equals(original.data));
      expect(result.total, original.total);
      expect(result.error, original.error);
    });

    test('VAL-DSL-026: fetcher-thrown exceptions captured as error', () async {
      final fetcher = (_) => throw Exception('sync throw');
      final result = await loadDataSource(DataSource.fetcher(fetcher: fetcher));
      expect(result.error, isNotNull);
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });

    test('VAL-DSL-027: fetcher contract is sync', () async {
      // The fetcher returns a FetchResult (not a Future) — sync contract.
      final fetcher = (FetchParams p) {
        expect(p, isA<FetchParams>());
        return const FetchResult(data: [1], total: 1);
      };
      final result = await loadDataSource(DataSource.fetcher(fetcher: fetcher));
      expect(result.data, equals([1]));
    });

    test('VAL-DSL-028: null fetcher uses canonical empty shape', () async {
      final result = await loadDataSource(const DataSource.fetcher());
      expect(result.data, isEmpty);
      expect(result.total, 0);
      expect(result.error, isNull);
      // Structurally identical to null source empty.
      final nullResult = await loadDataSource(null);
      expect(result.data.length, nullResult.data.length);
      expect(result.total, nullResult.total);
      expect(result.error, nullResult.error);
    });
  });

  // =========================================================================
  // Area: DataSourceUrl — Success Cases
  // =========================================================================
  group('VAL-DSL-030..035 DataSourceUrl success', () {
    test('VAL-DSL-030: performs HTTP GET request', () async {
      final captured = <String, dynamic>{};
      final client = _inspectingClient(
        jsonEncode([{'id': 1}]),
        captured: captured,
      );
      await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(captured['method'], 'GET');
    });

    test('VAL-DSL-031: parses JSON array response into data', () async {
      final client = _okClient(jsonEncode([{'id': 1}, {'id': 2}]));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.data.length, 2);
      expect(result.data[0]['id'], 1);
    });

    test('VAL-DSL-032: total equals parsed list length', () async {
      final client = _okClient(jsonEncode([{'a': 1}, {'b': 2}, {'c': 3}]));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.total, 3);
    });

    test('VAL-DSL-033: uses response total field when present', () async {
      final body = jsonEncode({
        'data': [{'id': 1}, {'id': 2}],
        'total': 100,
      });
      final client = _okClient(body);
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.total, 100);
      expect(result.data.length, 2);
    });

    test('VAL-DSL-034: empty JSON array returns empty result', () async {
      final client = _okClient('[]');
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });

    test('VAL-DSL-035: error is null on successful response', () async {
      final client = _okClient(jsonEncode([{'id': 1}]));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.error, isNull);
    });
  });

  // =========================================================================
  // Area: DataSourceUrl — Error Handling
  // =========================================================================
  group('VAL-DSL-040..044 DataSourceUrl errors', () {
    test('VAL-DSL-040: network error captured in FetchResult.error', () async {
      final client = _throwingClient(Exception('connection refused'));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.error, isNotNull);
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });

    test('VAL-DSL-041: non-200 status captured in error', () async {
      final client = MockClient((_) async => http.Response('Not Found', 404));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.error, isNotNull);
      expect(result.error.toString(), contains('404'));
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });

    test('VAL-DSL-042: invalid JSON body captured in error', () async {
      final client = _okClient('not json {{{');
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.error, isNotNull);
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });

    test('VAL-DSL-043: non-list JSON object without list key handled', () async {
      final client = _okClient(jsonEncode({'message': 'ok'}));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });

    test('VAL-DSL-044: never throws for any failure mode', () async {
      // Network error
      final netClient = _throwingClient(Exception('net'));
      final netResult = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: netClient,
      );
      expect(netResult.error, isNotNull);

      // Non-200
      final statusClient = MockClient((_) async => http.Response('', 500));
      final statusResult = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: statusClient,
      );
      expect(statusResult.error, isNotNull);

      // Invalid JSON
      final jsonClient = _okClient('{{{broken');
      final jsonResult = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: jsonClient,
      );
      expect(jsonResult.error, isNotNull);
    });
  });

  // =========================================================================
  // Area: DataSourceUrl — Envelopes (VAL-DSL-045..049)
  // =========================================================================
  group('VAL-DSL-045..049 URL envelopes', () {
    test('VAL-DSL-045: object envelope data key', () async {
      final client = _okClient(jsonEncode({
        'data': [{'id': 1}, {'id': 2}],
      }));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.data.length, 2);
      expect(result.data[0]['id'], 1);
    });

    test('VAL-DSL-046: object envelope items key', () async {
      final client = _okClient(jsonEncode({
        'items': [{'id': 3}, {'id': 4}],
      }));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.data.length, 2);
      expect(result.data[0]['id'], 3);
    });

    test('VAL-DSL-047: object envelope rows key', () async {
      final client = _okClient(jsonEncode({
        'rows': [{'id': 5}, {'id': 6}],
      }));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.data.length, 2);
      expect(result.data[0]['id'], 5);
    });

    test('VAL-DSL-048: total aliases with total precedence', () async {
      // total takes precedence over count and totalCount
      final body = jsonEncode({
        'data': [{'id': 1}],
        'total': 100,
        'count': 200,
        'totalCount': 300,
      });
      final client = _okClient(body);
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.total, 100);

      // count alias
      final countBody = jsonEncode({
        'data': [{'id': 1}],
        'count': 50,
      });
      final countClient = _okClient(countBody);
      final countResult = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: countClient,
      );
      expect(countResult.total, 50);

      // totalCount alias
      final tcBody = jsonEncode({
        'data': [{'id': 1}],
        'totalCount': 75,
      });
      final tcClient = _okClient(tcBody);
      final tcResult = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: tcClient,
      );
      expect(tcResult.total, 75);
    });

    test('VAL-DSL-049: falls back to data length when no total alias', () async {
      final client = _okClient(jsonEncode({
        'data': [{'id': 1}, {'id': 2}, {'id': 3}],
      }));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.total, 3);
    });
  });

  // =========================================================================
  // Area: DataSourceUrl — Headers (VAL-DSL-050..051)
  // =========================================================================
  group('VAL-DSL-050..051 URL headers', () {
    test('VAL-DSL-050: forwards custom headers in GET request', () async {
      final captured = <String, dynamic>{};
      final client = _inspectingClient(
        jsonEncode([]),
        captured: captured,
      );
      await loadDataSource(
        const DataSource.url(
          url: 'http://example.com/api',
          headers: {'Authorization': 'Bearer token', 'X-Custom': 'value'},
        ),
        client: client,
      );
      final headers = captured['headers'] as Map<String, String>;
      expect(headers['Authorization'], 'Bearer token');
      expect(headers['X-Custom'], 'value');
    });

    test('VAL-DSL-051: default empty headers still works', () async {
      final client = _okClient(jsonEncode([{'id': 1}]));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.error, isNull);
      expect(result.data.length, 1);
    });
  });

  // =========================================================================
  // Area: DataSourceUrl — Test seam & params forwarding (VAL-DSL-052..054)
  // =========================================================================
  group('VAL-DSL-052..054 URL test seam and params', () {
    test('VAL-DSL-052: injectable HTTP client seam works', () async {
      final client = _okClient(jsonEncode([{'ok': true}]));
      final result = await loadDataSource(
        const DataSource.url(url: 'http://example.com/api'),
        client: client,
      );
      expect(result.data[0]['ok'], true);
    });

    test('VAL-DSL-053: appends FetchParams as query params', () async {
      final captured = <String, dynamic>{};
      final client = _inspectingClient(
        jsonEncode([]),
        captured: captured,
      );
      final params = const FetchParams(
        page: 2,
        pageSize: 10,
        search: 'alice',
        sort: [SortRule(field: 'name', direction: SortDirection.desc)],
        filters: {'status': 'active'},
      );
      await loadDataSource(
        const DataSource.url(url: 'http://example.com/api?existing=1'),
        params: params,
        client: client,
      );
      final url = captured['url'] as String;
      expect(url, contains('page=2'));
      expect(url, contains('pageSize=10'));
      expect(url, contains('search=alice'));
      expect(url, contains('existing=1'));
      expect(url, contains('sort%5Bname%5D=desc'));
      expect(url, contains('filter%5Bstatus%5D=active'));
    });

    test('VAL-DSL-054: preserves caller headers with deterministic override', () async {
      final captured = <String, dynamic>{};
      final client = _inspectingClient(
        jsonEncode([]),
        captured: captured,
      );
      await loadDataSource(
        const DataSource.url(
          url: 'http://example.com/api',
          headers: {'Authorization': 'Bearer token'},
        ),
        client: client,
      );
      final headers = captured['headers'] as Map<String, String>;
      expect(headers['Authorization'], 'Bearer token');
    });
  });

  // =========================================================================
  // Area: DataSourceModel (VAL-DSL-060..065)
  // =========================================================================
  group('VAL-DSL-060..065 DataSourceModel', () {
    test('VAL-DSL-060: calls adapter.list with model name and params', () async {
      final adapter = _RecordingAdapter(const FetchResult());
      final params = const FetchParams(page: 1, pageSize: 20);
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: params,
      );
      expect(adapter.callCount, 1);
      expect(adapter.lastModel, 'users');
      expect(adapter.lastParams, isNotNull);
      expect(adapter.lastParams!.page, 1);
      expect(adapter.lastParams!.pageSize, 20);
    });

    test('VAL-DSL-061: returns FetchResult from adapter.list', () async {
      final adapter = _RecordingAdapter(
        const FetchResult(data: [{'id': 1}], total: 1),
      );
      final result = await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
      );
      expect(result.data, equals([{'id': 1}]));
      expect(result.total, 1);
    });

    test('VAL-DSL-062: null adapter returns empty result', () async {
      final result = await loadDataSource(
        const DataSource.model(name: 'users'),
      );
      expect(result.data, isEmpty);
      expect(result.total, 0);
      expect(result.error, isNull);
    });

    test('VAL-DSL-063: default params when params not provided', () async {
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
      );
      expect(adapter.lastParams, isNotNull);
      expect(adapter.lastParams!.page, isNull);
      expect(adapter.lastParams!.pageSize, isNull);
      expect(adapter.lastParams!.sort, isEmpty);
      expect(adapter.lastParams!.filters, isEmpty);
    });

    test('VAL-DSL-064: propagates adapter error in FetchResult', () async {
      final errorObj = Exception('adapter error');
      final adapter = _RecordingAdapter(FetchResult(error: errorObj));
      final result = await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
      );
      expect(result.error, same(errorObj));
    });

    test('VAL-DSL-065: adapter thrown exceptions captured as error', () async {
      final adapter = _ThrowingAdapter(Exception('adapter throw'));
      final result = await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
      );
      expect(result.error, isNotNull);
      expect(result.data, isEmpty);
      expect(result.total, 0);
    });
  });

  // =========================================================================
  // Area: FetchParams Propagation (VAL-DSL-070..079)
  // =========================================================================
  group('VAL-DSL-070..079 FetchParams propagation', () {
    test('VAL-DSL-070: page/pageSize forwarded to fetcher', () async {
      FetchParams? received;
      final fetcher = (FetchParams p) {
        received = p;
        return const FetchResult();
      };
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: const FetchParams(page: 2, pageSize: 10),
      );
      expect(received!.page, 2);
      expect(received!.pageSize, 10);
    });

    test('VAL-DSL-071: page/pageSize forwarded to adapter', () async {
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: const FetchParams(page: 1, pageSize: 20),
      );
      expect(adapter.lastParams!.page, 1);
      expect(adapter.lastParams!.pageSize, 20);
    });

    test('VAL-DSL-072: sort rules forwarded to fetcher', () async {
      FetchParams? received;
      final fetcher = (FetchParams p) {
        received = p;
        return const FetchResult();
      };
      final sort = const [
        SortRule(field: 'name', direction: SortDirection.desc),
      ];
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: FetchParams(sort: sort),
      );
      expect(received!.sort.length, 1);
      expect(received!.sort[0].field, 'name');
      expect(received!.sort[0].direction, SortDirection.desc);
    });

    test('VAL-DSL-073: sort rules forwarded to adapter', () async {
      final adapter = _RecordingAdapter(const FetchResult());
      final sort = const [
        SortRule(field: 'age', direction: SortDirection.asc),
      ];
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: FetchParams(sort: sort),
      );
      expect(adapter.lastParams!.sort.length, 1);
      expect(adapter.lastParams!.sort[0].field, 'age');
      expect(adapter.lastParams!.sort[0].direction, SortDirection.asc);
    });

    test('VAL-DSL-074: filters forwarded to fetcher and adapter', () async {
      // Fetcher
      FetchParams? fetcherParams;
      final fetcher = (FetchParams p) {
        fetcherParams = p;
        return const FetchResult();
      };
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: const FetchParams(filters: {'status': 'active'}),
      );
      expect(fetcherParams!.filters['status'], 'active');

      // Adapter
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: const FetchParams(filters: {'status': 'active'}),
      );
      expect(adapter.lastParams!.filters['status'], 'active');
    });

    test('VAL-DSL-075: search forwarded to fetcher and adapter', () async {
      // Fetcher
      FetchParams? fetcherParams;
      final fetcher = (FetchParams p) {
        fetcherParams = p;
        return const FetchResult();
      };
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: const FetchParams(search: 'alice'),
      );
      expect(fetcherParams!.search, 'alice');

      // Adapter
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: const FetchParams(search: 'alice'),
      );
      expect(adapter.lastParams!.search, 'alice');
    });

    test('VAL-DSL-076: dependValues forwarded to fetcher and adapter', () async {
      // Fetcher
      FetchParams? fetcherParams;
      final fetcher = (FetchParams p) {
        fetcherParams = p;
        return const FetchResult();
      };
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: const FetchParams(dependValues: {'parent_id': 42}),
      );
      expect(fetcherParams!.dependValues['parent_id'], 42);

      // Adapter
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: const FetchParams(dependValues: {'parent_id': 42}),
      );
      expect(adapter.lastParams!.dependValues['parent_id'], 42);
    });

    test('VAL-DSL-077: retry forwarded to fetcher and adapter', () async {
      // Fetcher
      FetchParams? fetcherParams;
      final fetcher = (FetchParams p) {
        fetcherParams = p;
        return const FetchResult();
      };
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: const FetchParams(retry: 3),
      );
      expect(fetcherParams!.retry, 3);

      // Adapter
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: const FetchParams(retry: 3),
      );
      expect(adapter.lastParams!.retry, 3);
    });

    test('VAL-DSL-078: default FetchParams has expected defaults', () async {
      FetchParams? received;
      final fetcher = (FetchParams p) {
        received = p;
        return const FetchResult();
      };
      await loadDataSource(DataSource.fetcher(fetcher: fetcher));
      expect(received!.page, isNull);
      expect(received!.pageSize, isNull);
      expect(received!.sort, isEmpty);
      expect(received!.filters, isEmpty);
      expect(received!.search, isNull);
      expect(received!.dependValues, isEmpty);
      expect(received!.retry, isNull);
    });

    test('VAL-DSL-079: FetchParams forwarded without mutation', () async {
      final params = FetchParams(
        page: 1,
        pageSize: 5,
        sort: const [SortRule(field: 'x', direction: SortDirection.asc)],
        filters: {'a': 'b'},
        search: 'q',
        dependValues: {'d': 1},
        retry: 2,
      );
      // Record original values
      final origPage = params.page;
      final origPageSize = params.pageSize;
      final origSortLen = params.sort.length;
      final origFiltersLen = params.filters.length;
      final origSearch = params.search;
      final origDependLen = params.dependValues.length;
      final origRetry = params.retry;

      final fetcher = (FetchParams p) {
        // Check identity — same object forwarded
        expect(identical(p, params), isTrue);
        return const FetchResult();
      };
      await loadDataSource(
        DataSource.fetcher(fetcher: fetcher),
        params: params,
      );

      // Verify original was not mutated
      expect(params.page, origPage);
      expect(params.pageSize, origPageSize);
      expect(params.sort.length, origSortLen);
      expect(params.filters.length, origFiltersLen);
      expect(params.search, origSearch);
      expect(params.dependValues.length, origDependLen);
      expect(params.retry, origRetry);

      // Same for adapter
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'users', adapter: adapter),
        params: params,
      );
      expect(identical(adapter.lastParams, params), isTrue);
      expect(params.page, origPage);
      expect(params.pageSize, origPageSize);
    });
  });

  // =========================================================================
  // Area: Empty Results (VAL-DSL-090..091)
  // =========================================================================
  group('VAL-DSL-090..091 Empty results', () {
    test('VAL-DSL-090: empty FetchResult has correct defaults', () {
      const result = FetchResult();
      expect(result.data, isEmpty);
      expect(result.total, 0);
      expect(result.error, isNull);
    });

    test('VAL-DSL-091: all null/empty paths return same empty shape', () async {
      // (a) null source
      final nullResult = await loadDataSource(null);

      // (b) fetcher with null fetcher
      final nullFetcherResult = await loadDataSource(
        const DataSource.fetcher(),
      );

      // (c) model with null adapter
      final nullAdapterResult = await loadDataSource(
        const DataSource.model(name: 'x'),
      );

      // (d) local with empty data
      final emptyLocalResult = await loadDataSource(
        const DataSource.local(),
      );

      for (final result in [
        nullResult,
        nullFetcherResult,
        nullAdapterResult,
        emptyLocalResult,
      ]) {
        expect(result.data, isEmpty);
        expect(result.total, 0);
        expect(result.error, isNull);
      }

      // Structurally identical to canonical empty shape
      expect(nullResult.data.length, _emptyShape.data.length);
      expect(nullResult.total, _emptyShape.total);
      expect(nullResult.error, _emptyShape.error);
    });
  });

  // =========================================================================
  // Area: Return Type and Async Contract (VAL-DSL-100..103)
  // =========================================================================
  group('VAL-DSL-100..103 Async contract', () {
    test('VAL-DSL-100: always returns a Future for all variants', () {
      expect(loadDataSource(null), isA<Future<FetchResult>>());
      expect(
        loadDataSource(const DataSource.local()),
        isA<Future<FetchResult>>(),
      );
      expect(
        loadDataSource(const DataSource.fetcher()),
        isA<Future<FetchResult>>(),
      );
      expect(
        loadDataSource(const DataSource.url(url: 'http://x')),
        isA<Future<FetchResult>>(),
      );
      expect(
        loadDataSource(const DataSource.model(name: 'x')),
        isA<Future<FetchResult>>(),
      );
    });

    test('VAL-DSL-101: Future completes for all variants', () async {
      // null
      await loadDataSource(null);

      // local
      await loadDataSource(const DataSource.local(data: [1]));

      // fetcher (with and without fetcher)
      await loadDataSource(const DataSource.fetcher());
      await loadDataSource(DataSource.fetcher(
        fetcher: (_) => const FetchResult(),
      ));

      // url (with mock client)
      await loadDataSource(
        const DataSource.url(url: 'http://x'),
        client: _okClient('[]'),
      );

      // model (with and without adapter)
      await loadDataSource(const DataSource.model(name: 'x'));
      final adapter = _RecordingAdapter(const FetchResult());
      await loadDataSource(
        DataSource.model(name: 'x', adapter: adapter),
      );
    });

    test('VAL-DSL-102: does not throw for any non-URL variant', () async {
      // null
      expect(() => loadDataSource(null), returnsNormally);
      await loadDataSource(null);

      // local
      expect(() => loadDataSource(const DataSource.local()), returnsNormally);
      await loadDataSource(const DataSource.local());

      // fetcher with null fetcher
      expect(
        () => loadDataSource(const DataSource.fetcher()),
        returnsNormally,
      );
      await loadDataSource(const DataSource.fetcher());

      // fetcher with throwing fetcher
      expect(
        () => loadDataSource(DataSource.fetcher(
          fetcher: (_) => throw Exception('boom'),
        )),
        returnsNormally,
      );
      await loadDataSource(DataSource.fetcher(
        fetcher: (_) => throw Exception('boom'),
      ));

      // model with null adapter
      expect(
        () => loadDataSource(const DataSource.model(name: 'x')),
        returnsNormally,
      );
      await loadDataSource(const DataSource.model(name: 'x'));

      // model with throwing adapter
      final throwingAdapter = _ThrowingAdapter(Exception('fail'));
      expect(
        () => loadDataSource(
          DataSource.model(name: 'x', adapter: throwingAdapter),
        ),
        returnsNormally,
      );
      await loadDataSource(
        DataSource.model(name: 'x', adapter: _ThrowingAdapter(Exception('f'))),
      );
    });

    test('VAL-DSL-103: DataSourceUrl catches all exceptions', () async {
      // Network error
      final netResult = await loadDataSource(
        const DataSource.url(url: 'http://x'),
        client: _throwingClient(Exception('net')),
      );
      expect(netResult.error, isNotNull);

      // HTTP error
      final httpResult = await loadDataSource(
        const DataSource.url(url: 'http://x'),
        client: MockClient((_) async => http.Response('', 500)),
      );
      expect(httpResult.error, isNotNull);

      // JSON parse error
      final jsonResult = await loadDataSource(
        const DataSource.url(url: 'http://x'),
        client: _okClient('not json'),
      );
      expect(jsonResult.error, isNotNull);

      // All completed without throwing
      expect(netResult, isA<FetchResult>());
      expect(httpResult, isA<FetchResult>());
      expect(jsonResult, isA<FetchResult>());
    });
  });
}
