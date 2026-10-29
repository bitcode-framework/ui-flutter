// ============================================================================
// BC UI Flutter — SPA Runtime (ADR-014 Phase 2)
//
// Client-side runtime that fetches a JSON SPA envelope from the engine
// (`{ view, data, meta }`, emitted when `view.json { "render": "spa" }`)
// and renders it via the existing BcRenderer + ReactiveStore.
//
// Mirrors the web SPA bootstrap in `packages/ui/src/spa-runtime.ts`.
// Same contract: one JSON envelope → one platform-aware render. SSR stays
// the default on the engine (backwards compatible per ADR-014 D3); this
// runtime only runs for views that opt into SPA mode.
//
// Responsibilities:
//   - Fetch the envelope via HTTP (configurable base URL + headers, injectable
//     fetcher for testing).
//   - Map the engine `ViewDefinition` (view JSON) to a Flutter [UiSchema].
//   - Build a [BcRendererProps] with the data values + a [ReactiveStore].
//   - Expose the descriptor so a host widget can mount [BcRenderer].
//
// Pure data mapping (no widget tree construction here). The host widget
// decides HOW to render — this runtime only prepares the descriptor.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, HttpClientRequest, HttpHeaders;

import 'schema/ui_schema.dart';
import 'schema/ui_schema_types.dart' show ComponentVariant, DataSource;
import 'core/reactive_store.dart' hide DataSource;

// ---------------------------------------------------------------------------
// Envelope types — mirror the Go SPAEnvelope + TS SPAEnvelope
// ---------------------------------------------------------------------------

/// The JSON envelope emitted by the engine when `view.json { "render": "spa" }`.
class SPAEnvelope {
  /// The full engine view definition (name, type, model, fields, layout, ...).
  final Map<String, dynamic> view;

  /// View-type-specific data payload (records for list/kanban, record for
  /// form, data-source results for chart/custom).
  final Map<String, dynamic> data;

  /// Rendering metadata (module, view path, record id, API source URL, ...).
  final SPAMeta meta;

  const SPAEnvelope({
    required this.view,
    required this.data,
    required this.meta,
  });

  /// Parse the envelope from a raw JSON map (the engine response body).
  factory SPAEnvelope.fromJson(Map<String, dynamic> json) {
    final viewRaw = json['view'];
    final dataRaw = json['data'];
    final metaRaw = json['meta'];

    if (viewRaw is! Map<String, dynamic>) {
      throw const SPARuntimeException(
        'SPAEnvelope: "view" must be a JSON object',
      );
    }
    if (metaRaw is! Map<String, dynamic>) {
      throw const SPARuntimeException(
        'SPAEnvelope: "meta" must be a JSON object',
      );
    }

    return SPAEnvelope(
      view: viewRaw,
      data: dataRaw is Map<String, dynamic>
          ? dataRaw
          : const <String, dynamic>{},
      meta: SPAMeta.fromJson(metaRaw),
    );
  }
}

/// Rendering metadata carried alongside the view + data in the envelope.
class SPAMeta {
  final String module;
  final String viewPath;
  final String viewType;
  final String? recordId;
  final int? page;
  final String? locale;
  final String? username;
  final String? activeView;
  final String? apiSource;

  const SPAMeta({
    required this.module,
    required this.viewPath,
    required this.viewType,
    this.recordId,
    this.page,
    this.locale,
    this.username,
    this.activeView,
    this.apiSource,
  });

  factory SPAMeta.fromJson(Map<String, dynamic> json) {
    return SPAMeta(
      module: json['module'] as String? ?? '',
      viewPath: json['viewPath'] as String? ?? '',
      viewType: json['viewType'] as String? ?? '',
      recordId: json['recordId'] as String?,
      page: json['page'] as int?,
      locale: json['locale'] as String?,
      username: json['username'] as String?,
      activeView: json['activeView'] as String?,
      apiSource: json['apiSource'] as String?,
    );
  }

  /// Serialize back to a JSON map (used when forwarding `meta` as part of
  /// the `custom` schema payload for kanban/calendar/chart views).
  Map<String, dynamic> toJson() => {
        'module': module,
        'viewPath': viewPath,
        'viewType': viewType,
        if (recordId != null) 'recordId': recordId,
        if (page != null) 'page': page,
        if (locale != null) 'locale': locale,
        if (username != null) 'username': username,
        if (activeView != null) 'activeView': activeView,
        if (apiSource != null) 'apiSource': apiSource,
      };
}

// ---------------------------------------------------------------------------
// Error type
// ---------------------------------------------------------------------------

/// A typed error raised by [SPARuntime] when fetching or parsing an envelope
/// fails. Carries the HTTP status code (when applicable) so callers can
/// distinguish 404 (view not found) from 5xx (server error) from network
/// failures.
class SPARuntimeException implements Exception {
  final String message;
  final int? statusCode;
  final String? url;

  const SPARuntimeException(this.message, {this.statusCode, this.url});

  @override
  String toString() {
    final parts = <String>['SPARuntimeException: $message'];
    if (statusCode != null) parts.add('status=$statusCode');
    if (url != null) parts.add('url=$url');
    return parts.join(' ');
  }
}

// ---------------------------------------------------------------------------
// Render descriptor — what the host mounts
// ---------------------------------------------------------------------------

/// The result of [SPARuntime.load]: everything a host widget needs to mount
/// a [BcRenderer] for the SPA view.
class SPADescriptor {
  /// The parsed envelope (view + data + meta).
  final SPAEnvelope envelope;

  /// The Flutter [UiSchema] mapped from the engine view definition.
  final UiSchema schema;

  /// Initial form values (the record, for form views; empty for list views).
  final Map<String, dynamic> values;

  /// A [ReactiveStore] pre-loaded with [values]. Hosts may attach reactions
  /// before mounting [BcRenderer].
  final ReactiveStore store;

  /// The [BcRendererProps] ready to pass to [BcRenderer].
  final BcRendererProps props;

  const SPADescriptor({
    required this.envelope,
    required this.schema,
    required this.values,
    required this.store,
    required this.props,
  });
}

// ---------------------------------------------------------------------------
// Fetcher typedef
// ---------------------------------------------------------------------------

/// HTTP fetcher signature. Returns the response body as a string. Throws
/// [SPARuntimeException] on non-2xx or network failures.
typedef SPAFetcher = Future<String> Function(
  String url,
  Map<String, String> headers,
);

// ---------------------------------------------------------------------------
// SPARuntime
// ---------------------------------------------------------------------------

/// Configuration for [SPARuntime].
class SPARuntimeConfig {
  /// Base URL prefix for envelope fetches (e.g. `https://erp.example.com`).
  /// When empty, URLs are treated as relative (the host must resolve them).
  final String baseUrl;

  /// Default headers sent with every fetch (e.g. auth tokens).
  final Map<String, String> headers;

  const SPARuntimeConfig({
    this.baseUrl = '',
    this.headers = const {},
  });
}

/// The SPA client runtime. Fetches an envelope from the engine and produces a
/// [SPADescriptor] ready for [BcRenderer].
///
/// Usage:
/// ```dart
/// final rt = SPARuntime(config: SPARuntimeConfig(baseUrl: 'https://erp.example.com'));
/// final desc = await rt.load('/app/crm/contact_list');
/// // mount BcRenderer(props: desc.props)
/// ```
class SPARuntime {
  final SPARuntimeConfig config;
  final SPAFetcher fetcher;

  SPARuntime({
    this.config = const SPARuntimeConfig(),
    SPAFetcher? fetcher,
  }) : fetcher = fetcher ?? defaultSPAFetcher;

  /// Fetch the envelope at [viewUrl] and return a [SPADescriptor].
  ///
  /// [viewUrl] is a path like `/app/crm/contact_list` (relative when
  /// [SPARuntimeConfig.baseUrl] is set, absolute otherwise).
  Future<SPADescriptor> load(String viewUrl) async {
    final fullUrl = _resolveUrl(viewUrl);
    final headers = <String, String>{
      'Accept': 'application/json',
      ...config.headers,
    };

    final String body;
    try {
      body = await fetcher(fullUrl, headers);
    } on SPARuntimeException {
      rethrow;
    } catch (e) {
      throw SPARuntimeException(
        'Network error fetching SPA envelope: $e',
        url: fullUrl,
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (e) {
      throw SPARuntimeException(
        'Failed to parse SPA envelope JSON: $e',
        url: fullUrl,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw SPARuntimeException(
        'SPA envelope response is not a JSON object',
        url: fullUrl,
      );
    }

    final envelope = SPAEnvelope.fromJson(decoded);
    return buildDescriptor(envelope);
  }

  /// Build a [SPADescriptor] from an already-parsed [envelope]. Public so
  /// hosts can construct descriptors without a network fetch (e.g. from a
  /// cached envelope or a push payload).
  SPADescriptor buildDescriptor(SPAEnvelope envelope) {
    final view = envelope.view;
    if (view.isEmpty) {
      throw const SPARuntimeException(
        'Invalid SPA envelope: "view" is empty or missing',
      );
    }
    if (envelope.meta.viewType.isEmpty) {
      throw const SPARuntimeException(
        'Invalid SPA envelope: "meta.viewType" is missing',
      );
    }

    final schema = viewDefinitionToUiSchema(view, envelope.data, envelope.meta);

    // Form values: the record (for form/detail views).
    final values = <String, dynamic>{};
    if (schema.type == UiSchemaKind.form ||
        schema.type == UiSchemaKind.detail) {
      final record = envelope.data['record'];
      if (record is Map<String, dynamic>) {
        values.addAll(record);
      }
    }

    final store = ReactiveStore(ReactiveStoreOptions(initialValues: values));

    final props = BcRendererProps(
      schema: schema,
      values: values,
      disabled: schema.type == UiSchemaKind.detail,
    );

    return SPADescriptor(
      envelope: envelope,
      schema: schema,
      values: values,
      store: store,
      props: props,
    );
  }

  String _resolveUrl(String viewUrl) {
    if (config.baseUrl.isEmpty) return viewUrl;
    if (viewUrl.startsWith('http://') || viewUrl.startsWith('https://')) {
      return viewUrl;
    }
    final base = config.baseUrl.endsWith('/')
        ? config.baseUrl.substring(0, config.baseUrl.length - 1)
        : config.baseUrl;
    final path = viewUrl.startsWith('/') ? viewUrl : '/$viewUrl';
    return '$base$path';
  }
}

// ---------------------------------------------------------------------------
// ViewDefinition -> UiSchema mapping
// ---------------------------------------------------------------------------

/// Maps an engine view definition (JSON map) to a Flutter [UiSchema].
///
/// Public so hosts can test/inspect the mapping without a network fetch.
///
/// - list     -> [UiSchemaKind.list] (columns from fields, source = API URL)
/// - form     -> [UiSchemaKind.form] (fields from layout, values = record)
/// - detail   -> [UiSchemaKind.detail] (form, disabled)
/// - other    -> [UiSchemaKind.custom] (engine view + data forwarded as payload)
UiSchema viewDefinitionToUiSchema(
  Map<String, dynamic> view,
  Map<String, dynamic> data,
  SPAMeta meta,
) {
  final type = (view['type'] as String?) ?? '';
  final title = view['title'] as String?;
  final name = (view['name'] as String?) ?? '';

  switch (type) {
    case 'list':
      return _mapListView(view, data, meta, name, title);
    case 'form':
    case 'detail':
      return _mapFormView(view, data, name, title, readOnly: type == 'detail');
    default:
      // kanban, calendar, chart, custom, activity, report, gantt, map, tree
      // -> custom payload. The host's BcRenderer.customBuilder renders these
      // (the engine view JSON + data are forwarded as the payload).
      return UiSchema(
        type: UiSchemaKind.custom,
        name: name,
        title: title,
        payload: <String, dynamic>{
          'view': view,
          'data': data,
          'meta': meta.toJson(),
        },
      );
  }
}

UiSchema _mapListView(
  Map<String, dynamic> view,
  Map<String, dynamic> data,
  SPAMeta meta,
  String name,
  String? title,
) {
  final fields = view['fields'];
  final columns = <ColumnDef>[];
  if (fields is List) {
    for (final f in fields) {
      if (f is String) {
        columns.add(ColumnDef(
          key: f,
          label: _humanize(f),
          sortable: true,
        ));
      }
    }
  }

  // API source: prefer meta.apiSource, fall back to data.apiSource.
  final apiSource = meta.apiSource ?? (data['apiSource'] as String?);
  DataSource? source;
  if (apiSource != null && apiSource.isNotEmpty) {
    source = DataSource.url(url: apiSource);
  }

  return UiSchema(
    type: UiSchemaKind.list,
    name: name,
    title: title,
    columnsDef: columns,
    source: source,
    data: const [],
    pageSize: 10,
  );
}

UiSchema _mapFormView(
  Map<String, dynamic> view,
  Map<String, dynamic> data,
  String name,
  String? title, {
  required bool readOnly,
}) {
  final fields = <FieldNode>[];

  // Fields from layout rows.
  final layout = view['layout'];
  if (layout is List) {
    for (final item in layout) {
      if (item is Map<String, dynamic>) {
        final row = item['row'];
        if (row is List) {
          for (final cell in row) {
            if (cell is Map<String, dynamic>) {
              final fieldName = cell['field'] as String?;
              if (fieldName != null && fieldName.isNotEmpty) {
                fields.add(FieldNode(
                  name: fieldName,
                  label: _humanize(fieldName),
                  disabled: readOnly || (cell['readonly'] as bool? ?? false),
                ));
              }
            }
          }
        }
      }
    }
  }

  // Fallback: flat fields array when no layout.
  if (fields.isEmpty) {
    final flatFields = view['fields'];
    if (flatFields is List) {
      for (final f in flatFields) {
        if (f is String) {
          fields.add(FieldNode(
            name: f,
            label: _humanize(f),
            disabled: readOnly,
          ));
        }
      }
    }
  }

  // Actions -> UiAction list.
  final actions = <UiAction>[];
  final rawActions = view['actions'];
  if (rawActions is List) {
    for (final a in rawActions) {
      if (a is Map<String, dynamic>) {
        final label = a['label'] as String?;
        final process = (a['process'] as String?) ?? '';
        actions.add(UiAction(
          name: process.isNotEmpty ? process : (label ?? 'action'),
          label: label,
          variant: _parseVariant(a['variant']),
          disabled: readOnly,
        ));
      }
    }
  }

  return UiSchema(
    type: readOnly ? UiSchemaKind.detail : UiSchemaKind.form,
    name: name,
    title: title,
    fields: fields,
    actions: actions,
  );
}

ComponentVariant _parseVariant(Object? raw) {
  switch (raw) {
    case 'primary':
      return ComponentVariant.primary;
    case 'secondary':
      return ComponentVariant.secondary;
    case 'destructive':
      return ComponentVariant.destructive;
    case 'ghost':
      return ComponentVariant.ghost;
    default:
      return ComponentVariant.primary;
  }
}

/// Convert snake_case to Title Case (e.g. `customer_id` → `Customer Id`).
String _humanize(String field) {
  final parts = field.split('_');
  final out = <String>[];
  for (final p in parts) {
    if (p.isEmpty) continue;
    out.add(p[0].toUpperCase() + p.substring(1));
  }
  return out.join(' ');
}

// ---------------------------------------------------------------------------
// Default HTTP fetcher (dart:io HttpClient)
// ---------------------------------------------------------------------------

/// Default HTTP fetcher using [HttpClient]. Returns the response body as a
/// string. Throws [SPARuntimeException] on non-2xx, non-JSON, or network
/// failures.
///
/// Hosts may inject their own fetcher (e.g. to use `package:http` or to
/// mock in tests).
Future<String> defaultSPAFetcher(
  String url,
  Map<String, String> headers,
) async {
  final client = HttpClient();
  try {
    final HttpClientRequest req = await client.getUrl(Uri.parse(url));
    for (final entry in headers.entries) {
      req.headers.set(entry.key, entry.value);
    }
    final response = await req.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final ct = response.headers.value(HttpHeaders.contentTypeHeader) ?? '';
      throw SPARuntimeException(
        'Engine returned ${response.statusCode} for SPA envelope '
        '(content-type: $ct). The view may not have render:"spa" set.',
        statusCode: response.statusCode,
        url: url,
      );
    }

    final ct = response.headers.value(HttpHeaders.contentTypeHeader) ?? '';
    if (!ct.toLowerCase().contains('application/json')) {
      throw SPARuntimeException(
        'Expected JSON envelope (application/json), got "$ct". '
        'The view may not have render:"spa" set.',
        statusCode: response.statusCode,
        url: url,
      );
    }

    return body;
  } on SPARuntimeException {
    rethrow;
  } on Object catch (e) {
    throw SPARuntimeException(
      'Network error fetching SPA envelope: $e',
      url: url,
    );
  } finally {
    client.close(force: true);
  }
}
