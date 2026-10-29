import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('ActionSource', () {
    test('validates all four variants and type guards', () {
      final local = LocalActionSource(effects: const []);
      final handler = HandlerActionSource(handlerKey: 'save');
      final url = UrlActionSource(method: 'POST', url: 'https://api.test/save');
      final model = ModelActionSource(
        model: 'crm.contact',
        operation: 'create',
      );

      expect(validateActionSource(local).valid, isTrue);
      expect(validateActionSource(handler).valid, isTrue);
      expect(validateActionSource(url).valid, isTrue);
      expect(validateActionSource(model).valid, isTrue);
      expect(isLocalActionSource(local), isTrue);
      expect(isHandlerActionSource(handler), isTrue);
      expect(isUrlActionSource(url), isTrue);
      expect(isModelActionSource(model), isTrue);
    });

    test('rejects invalid shape and missing fields', () {
      expect(validateActionSource({'type': 'teleport'}).valid, isFalse);
      expect(
        validateActionSource({
          'type': 'handler',
          'handlerKey': '',
        }).diagnostics.first.code,
        'ACTION_SOURCE_INVALID',
      );
      expect(
        validateActionSource({
          'type': 'url',
          'method': 'GET',
          'url': 'x',
        }).valid,
        isFalse,
      );
      expect(
        validateActionSource({
          'type': 'model',
          'model': 'x',
          'operation': 'custom',
        }).valid,
        isFalse,
      );
    });

    test('roundtrips JSON with AST payloads', () {
      final src = ModelActionSource(
        model: 'x',
        operation: 'update',
        id: const PathNode('values.id'),
        payload: {'name': 'Ada'},
      );
      final back = ActionSource.fromJson(src.toJson()) as ModelActionSource;
      expect(back.id, isA<PathNode>());
      expect(back.payload, {'name': 'Ada'});
      expect(actionSourceTypes, {'local', 'handler', 'url', 'model'});
    });
  });
}
