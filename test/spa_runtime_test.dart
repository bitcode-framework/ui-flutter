// ============================================================================
// BC UI Flutter — SPA Runtime tests (ADR-014 Phase 2)
//
// Verifies:
//   - SPAEnvelope.fromJson parses the JSON contract correctly.
//   - SPAMeta.fromJson reads all optional fields.
//   - viewDefinitionToUiSchema maps list/form/detail to the matching schema
//     kind, with columns/fields sourced from view JSON layout.
//   - viewDefinitionToUiSchema maps everything else (kanban/calendar/chart/
//     custom) to a `custom` schema with payload = {view, data, meta}.
//   - SPARuntime.buildDescriptor produces a SPADescriptor with seeded
//     ReactiveStore and a BcRendererProps bound to the schema.
//   - SPARuntime.load parses the JSON response body, throws on non-JSON,
//     and propagates fetcher errors with the original URL.
//   - URL resolution handles baseUrl + relative/absolute paths.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/spa_runtime.dart';
import 'package:bc_ui_flutter/src/schema/ui_schema.dart';

void main() {
  group('SPAEnvelope.fromJson', () {
    test('parses envelope with all meta fields', () {
      final raw = <String, dynamic>{
        'view': {'name': 'contact_list', 'type': 'list', 'title': 'Contacts'},
        'data': {
          'records': [
            {'id': '1', 'name': 'Alice'},
            {'id': '2', 'name': 'Bob'},
          ],
        },
        'meta': {
          'module': 'crm',
          'viewPath': '/app/crm/contact_list',
          'viewType': 'list',
          'apiSource': '/api/v1/crm/contacts',
          'page': 1,
          'locale': 'en',
          'username': 'admin',
        },
      };
      final env = SPAEnvelope.fromJson(raw);
      expect(env.view['name'], 'contact_list');
      expect(env.data['records'], isA<List>());
      expect(env.meta.module, 'crm');
      expect(env.meta.viewType, 'list');
      expect(env.meta.apiSource, '/api/v1/crm/contacts');
      expect(env.meta.page, 1);
      expect(env.meta.locale, 'en');
      expect(env.meta.username, 'admin');
    });

    test('throws when view is not an object', () {
      expect(
        () => SPAEnvelope.fromJson(<String, dynamic>{
          'view': 'not-an-object',
          'data': <String, dynamic>{},
          'meta': <String, dynamic>{},
        }),
        throwsA(isA<SPARuntimeException>()),
      );
    });

    test('throws when meta is not an object', () {
      expect(
        () => SPAEnvelope.fromJson(<String, dynamic>{
          'view': <String, dynamic>{},
          'data': <String, dynamic>{},
          'meta': 'not-an-object',
        }),
        throwsA(isA<SPARuntimeException>()),
      );
    });

    test('tolerates non-object data (treats as empty)', () {
      final env = SPAEnvelope.fromJson(<String, dynamic>{
        'view': <String, dynamic>{'name': 'v', 'type': 'list'},
        'data': <dynamic>[],
        'meta': <String, dynamic>{
          'module': 'm',
          'viewPath': '/p',
          'viewType': 'list',
        },
      });
      expect(env.data, isEmpty);
    });
  });

  group('SPAMeta.toJson', () {
    test('round-trips optional fields', () {
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'list',
        recordId: 'r1',
        page: 2,
        locale: 'id',
        apiSource: '/api/v1/crm/contacts',
      );
      final j = meta.toJson();
      expect(j['module'], 'crm');
      expect(j['recordId'], 'r1');
      expect(j['apiSource'], '/api/v1/crm/contacts');
      expect(j['page'], 2);
    });
  });

  group('viewDefinitionToUiSchema — list', () {
    test('maps list view to list schema with columns from fields', () {
      final view = <String, dynamic>{
        'name': 'contact_list',
        'type': 'list',
        'title': 'Contacts',
        'fields': <String>['id', 'name', 'email'],
      };
      final data = <String, dynamic>{
        'records': <Map<String, dynamic>>[
          {'id': '1', 'name': 'Alice', 'email': 'a@x'},
        ],
        'apiSource': '/api/v1/crm/contacts',
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'list',
      );
      final schema = viewDefinitionToUiSchema(view, data, meta);
      expect(schema.type, UiSchemaKind.list);
      expect(schema.name, 'contact_list');
      expect(schema.title, 'Contacts');
      expect(schema.columnsDef.length, 3);
      expect(schema.columnsDef[0].key, 'id');
      expect(schema.columnsDef[0].label, 'Id');
      expect(schema.columnsDef[1].label, 'Name');
      expect(schema.columnsDef[2].label, 'Email');
    });

    test('prefers meta.apiSource over data.apiSource', () {
      final view = <String, dynamic>{
        'name': 'v',
        'type': 'list',
        'fields': <String>['id'],
      };
      final data = <String, dynamic>{
        'records': <Map<String, dynamic>>[],
        'apiSource': '/api/from-data',
      };
      const meta = SPAMeta(
        module: 'm',
        viewPath: '/p',
        viewType: 'list',
        apiSource: '/api/from-meta',
      );
      final schema = viewDefinitionToUiSchema(view, data, meta);
      // DataSource is a freezed sealed union; the active variant is
      // DataSourceUrl. Use a dynamic cast to access the `url` getter.
      final source = schema.source! as dynamic;
      expect(source.url as String, '/api/from-meta');
    });
  });

  group('viewDefinitionToUiSchema — form/detail', () {
    test('maps form view with layout rows to fields', () {
      final view = <String, dynamic>{
        'name': 'contact_form',
        'type': 'form',
        'title': 'Contact',
        'layout': <Map<String, dynamic>>[
          {
            'row': <Map<String, dynamic>>[
              {'field': 'name', 'readonly': false},
              {'field': 'email'},
            ],
          },
          {
            'row': <Map<String, dynamic>>[
              {'field': 'phone', 'readonly': true},
            ],
          },
        ],
      };
      final data = <String, dynamic>{
        'record': <String, dynamic>{
          'name': 'Alice',
          'email': 'a@x',
          'phone': '0811',
        },
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'form',
        recordId: 'r1',
      );
      final schema = viewDefinitionToUiSchema(view, data, meta);
      expect(schema.type, UiSchemaKind.form);
      expect(schema.fields.length, 3);
      expect(schema.fields[0].name, 'name');
      expect(schema.fields[0].label, 'Name');
      expect(schema.fields[0].disabled, false);
      expect(schema.fields[1].name, 'email');
      expect(schema.fields[2].name, 'phone');
      expect(schema.fields[2].disabled, true);
    });

    test('detail view disables all fields', () {
      final view = <String, dynamic>{
        'name': 'contact_detail',
        'type': 'detail',
        'layout': <Map<String, dynamic>>[
          {
            'row': <Map<String, dynamic>>[
              {'field': 'name'},
              {'field': 'email'},
            ],
          },
        ],
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'detail',
        recordId: 'r1',
      );
      final schema = viewDefinitionToUiSchema(view, <String, dynamic>{}, meta);
      expect(schema.type, UiSchemaKind.detail);
      for (final f in schema.fields) {
        expect(f.disabled, true, reason: 'field ${f.name} should be disabled');
      }
    });

    test('falls back to flat fields when no layout', () {
      final view = <String, dynamic>{
        'name': 'contact_form',
        'type': 'form',
        'fields': <String>['name', 'email'],
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'form',
      );
      final schema = viewDefinitionToUiSchema(view, <String, dynamic>{}, meta);
      expect(schema.fields.length, 2);
      expect(schema.fields[0].name, 'name');
      expect(schema.fields[1].name, 'email');
    });

    test('maps actions with variant', () {
      final view = <String, dynamic>{
        'name': 'contact_form',
        'type': 'form',
        'layout': <Map<String, dynamic>>[
          {
            'row': <Map<String, dynamic>>[
              {'field': 'name'},
            ],
          },
        ],
        'actions': <Map<String, dynamic>>[
          {'label': 'Save', 'process': 'contact.save', 'variant': 'primary'},
          {'label': 'Cancel', 'variant': 'secondary'},
        ],
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'form',
      );
      final schema = viewDefinitionToUiSchema(view, <String, dynamic>{}, meta);
      expect(schema.actions.length, 2);
      expect(schema.actions[0].name, 'contact.save');
      expect(schema.actions[0].label, 'Save');
      expect(schema.actions[1].label, 'Cancel');
    });
  });

  group('viewDefinitionToUiSchema — custom (kanban/calendar/chart)', () {
    test('kanban view -> custom schema with payload', () {
      final view = <String, dynamic>{
        'name': 'contact_kanban',
        'type': 'kanban',
        'title': 'Pipeline',
        'group_by': 'stage',
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'kanban',
      );
      final data = <String, dynamic>{'stages': <dynamic>[]};
      final schema = viewDefinitionToUiSchema(view, data, meta);
      expect(schema.type, UiSchemaKind.custom);
      expect(schema.name, 'contact_kanban');
      final payload = schema.payload as Map<String, dynamic>;
      expect(payload['view'], isA<Map<String, dynamic>>());
      expect(payload['data'], isA<Map<String, dynamic>>());
      expect(payload['meta'], isA<Map<String, dynamic>>());
    });

    test('chart view -> custom schema', () {
      final view = <String, dynamic>{'name': 'c', 'type': 'chart'};
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'chart',
      );
      final schema = viewDefinitionToUiSchema(view, <String, dynamic>{}, meta);
      expect(schema.type, UiSchemaKind.custom);
    });
  });

  group('SPARuntime.buildDescriptor', () {
    test('produces descriptor with seeded reactive store for form', () {
      final view = <String, dynamic>{
        'name': 'contact_form',
        'type': 'form',
        'layout': <Map<String, dynamic>>[
          {
            'row': <Map<String, dynamic>>[
              {'field': 'name'},
              {'field': 'email'},
            ],
          },
        ],
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'form',
      );
      final envelope = SPAEnvelope(
        view: view,
        data: <String, dynamic>{
          'record': <String, dynamic>{'name': 'Alice', 'email': 'a@x'},
        },
        meta: meta,
      );
      final rt = SPARuntime();
      final desc = rt.buildDescriptor(envelope);
      expect(desc.schema.type, UiSchemaKind.form);
      expect(desc.values, <String, dynamic>{'name': 'Alice', 'email': 'a@x'});
      expect(desc.store.get('name'), 'Alice');
      expect(desc.store.get('email'), 'a@x');
      expect(desc.props.disabled, false);
      expect(desc.props.schema, same(desc.schema));
    });

    test('list view produces descriptor with empty values', () {
      final view = <String, dynamic>{
        'name': 'contact_list',
        'type': 'list',
        'fields': <String>['id', 'name'],
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'list',
      );
      final envelope = SPAEnvelope(
        view: view,
        data: <String, dynamic>{'records': <Map<String, dynamic>>[]},
        meta: meta,
      );
      final rt = SPARuntime();
      final desc = rt.buildDescriptor(envelope);
      expect(desc.schema.type, UiSchemaKind.list);
      expect(desc.values, isEmpty);
      expect(desc.props.disabled, false);
    });

    test('detail view produces disabled props', () {
      final view = <String, dynamic>{
        'name': 'contact_detail',
        'type': 'detail',
        'layout': <Map<String, dynamic>>[
          {
            'row': <Map<String, dynamic>>[
              {'field': 'name'},
            ],
          },
        ],
      };
      const meta = SPAMeta(
        module: 'crm',
        viewPath: '/p',
        viewType: 'detail',
        recordId: 'r1',
      );
      final envelope = SPAEnvelope(
        view: view,
        data: <String, dynamic>{'record': <String, dynamic>{'name': 'Alice'}},
        meta: meta,
      );
      final rt = SPARuntime();
      final desc = rt.buildDescriptor(envelope);
      expect(desc.schema.type, UiSchemaKind.detail);
      expect(desc.props.disabled, true);
    });

    test('throws when view is empty', () {
      const meta = SPAMeta(
        module: 'm',
        viewPath: '/p',
        viewType: 'list',
      );
      const envelope = SPAEnvelope(
        view: <String, dynamic>{},
        data: <String, dynamic>{},
        meta: meta,
      );
      final rt = SPARuntime();
      expect(
        () => rt.buildDescriptor(envelope),
        throwsA(isA<SPARuntimeException>()),
      );
    });

    test('throws when meta.viewType is empty', () {
      final view = <String, dynamic>{
        'name': 'v',
        'type': 'list',
        'fields': <String>[],
      };
      const meta = SPAMeta(
        module: 'm',
        viewPath: '/p',
        viewType: '',
      );
      final envelope = SPAEnvelope(
        view: view,
        data: const <String, dynamic>{},
        meta: meta,
      );
      final rt = SPARuntime();
      expect(
        () => rt.buildDescriptor(envelope),
        throwsA(isA<SPARuntimeException>()),
      );
    });
  });

  group('SPARuntime.load', () {
    test('fetches envelope and returns descriptor', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test'),
        fetcher: (url, headers) async {
          expect(url, 'https://erp.test/app/crm/contact_list');
          expect(headers['Accept'], 'application/json');
          return '{"view":{"name":"v","type":"list","fields":["id"]},"data":{"records":[]},"meta":{"module":"crm","viewPath":"/app/crm/contact_list","viewType":"list"}}';
        },
      );
      final desc = await rt.load('/app/crm/contact_list');
      expect(desc.schema.type, UiSchemaKind.list);
    });

    test('merges config.headers with default Accept', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(
          baseUrl: 'https://erp.test',
          headers: <String, String>{'Authorization': 'Bearer xyz'},
        ),
        fetcher: (url, headers) async {
          expect(headers['Accept'], 'application/json');
          expect(headers['Authorization'], 'Bearer xyz');
          return '{"view":{"name":"v","type":"list","fields":[]},"data":{},"meta":{"module":"m","viewPath":"/p","viewType":"list"}}';
        },
      );
      await rt.load('/p');
    });

    test('throws SPARuntimeException when body is not JSON', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test'),
        fetcher: (url, headers) async => '<html>not json</html>',
      );
      expect(
        () => rt.load('/p'),
        throwsA(
          isA<SPARuntimeException>().having(
            (e) => e.url,
            'url',
            'https://erp.test/p',
          ),
        ),
      );
    });

    test('throws SPARuntimeException when body is JSON but not an object',
        () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test'),
        fetcher: (url, headers) async => '[1, 2, 3]',
      );
      expect(
        () => rt.load('/p'),
        throwsA(isA<SPARuntimeException>()),
      );
    });

    test('propagates fetcher SPARuntimeException unchanged', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test'),
        fetcher: (url, headers) async {
          throw const SPARuntimeException('boom', statusCode: 500, url: 'x');
        },
      );
      expect(
        () => rt.load('/p'),
        throwsA(
          isA<SPARuntimeException>().having(
            (e) => e.message,
            'message',
            'boom',
          ),
        ),
      );
    });

    test('wraps non-SPARuntimeException fetcher errors', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test'),
        fetcher: (url, headers) async {
          throw StateError('socket closed');
        },
      );
      try {
        await rt.load('/p');
        fail('expected throw');
      } on SPARuntimeException catch (e) {
        expect(e.message, contains('Network error'));
        expect(e.url, 'https://erp.test/p');
      }
    });
  });

  group('SPARuntime URL resolution', () {
    test('absolute URL is preserved when baseUrl is set', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test'),
        fetcher: (url, headers) async {
          expect(url, 'https://other.example.com/p');
          return '{"view":{"name":"v","type":"list","fields":[]},"data":{},"meta":{"module":"m","viewPath":"/p","viewType":"list"}}';
        },
      );
      await rt.load('https://other.example.com/p');
    });

    test('relative URL is prefixed with baseUrl (no double slash)', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test/api'),
        fetcher: (url, headers) async {
          expect(url, 'https://erp.test/api/p');
          return '{"view":{"name":"v","type":"list","fields":[]},"data":{},"meta":{"module":"m","viewPath":"/p","viewType":"list"}}';
        },
      );
      await rt.load('/p');
    });

    test('relative URL without leading slash is normalized', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(baseUrl: 'https://erp.test/api'),
        fetcher: (url, headers) async {
          expect(url, 'https://erp.test/api/p');
          return '{"view":{"name":"v","type":"list","fields":[]},"data":{},"meta":{"module":"m","viewPath":"/p","viewType":"list"}}';
        },
      );
      await rt.load('p');
    });

    test('empty baseUrl uses relative URL as-is', () async {
      final rt = SPARuntime(
        config: const SPARuntimeConfig(),
        fetcher: (url, headers) async {
          expect(url, '/p');
          return '{"view":{"name":"v","type":"list","fields":[]},"data":{},"meta":{"module":"m","viewPath":"/p","viewType":"list"}}';
        },
      );
      await rt.load('/p');
    });
  });
}
