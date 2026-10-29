import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import 'helpers.dart';

void main() {
  group('registries and validators', () {
    test('adapter registry register resolve duplicate unregister', () {
      final registry = InMemoryActionAdapterRegistry();
      final adapter = TestAdapter({'ok': true}, kindValue: 'url');
      registry.register('url', adapter);
      expect(registry.has('url'), isTrue);
      expect(registry.resolve('url'), same(adapter));
      expect(registry.keys(), ['url']);
      expect(() => registry.register('url', adapter), throwsStateError);
      expect(registry.unregister('url'), isTrue);
    });

    test('custom registry only accepts handler adapters', () {
      final registry = InMemoryCustomActionRegistry();
      final handler = TestAdapter({'ok': true}, kindValue: 'handler');
      registry.register('save', handler);
      expect(registry.resolve('save'), same(handler));
      expect(() => registry.register('save', handler), throwsStateError);
      expect(
        () => registry.register(
          'url',
          TestAdapter({'ok': true}, kindValue: 'url'),
        ),
        throwsStateError,
      );
    });

    test('runtime context validates adapters and url policy', () {
      final adapters = InMemoryActionAdapterRegistry();
      final custom = InMemoryCustomActionRegistry();
      final ctx = makeCtx();
      final url = UrlActionSource(method: 'POST', url: 'https://x');
      expect(
        validateRuntimeContext(url, ctx, adapters, custom).first.code,
        'ACTION_ADAPTER_MISSING',
      );
      adapters.register('url', TestAdapter({'ok': true}));
      expect(validateRuntimeContext(url, ctx, adapters, custom), isEmpty);

      final denied = checkUrlPolicy(url, TestPolicy(false));
      expect(denied.first.code, 'ACTION_URL_NOT_ALLOWED');
      expect(checkUrlPolicy(url, null), isEmpty);
    });
  });
}
