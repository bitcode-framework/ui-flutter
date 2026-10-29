import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('redaction and lifecycle', () {
    test('redacts top-level fields without mutating original', () {
      final original = {'token': 'secret', 'name': 'Ada'};
      final masked =
          redactSensitiveFields(
                original,
                const RedactConfig(fields: ['token'], mode: 'mask'),
              )
              as Map;
      expect(masked['token'], '***');
      expect(original['token'], 'secret');

      final removed =
          redactSensitiveFields(
                original,
                const RedactConfig(fields: ['token'], mode: 'remove'),
              )
              as Map;
      expect(removed.containsKey('token'), isFalse);
      expect(redactSensitiveFields([1, 2], null), [1, 2]);
    });

    test('buildLifecycleEvent sets required and optional fields', () {
      const source = LocalActionSource(effects: []);
      const meta = BcChangeMeta(reason: BcChangeReason.programmatic);
      final event = buildLifecycleEvent(
        'id',
        source,
        'start',
        meta,
        payload: {'x': 1},
        timestamp: 42,
      );
      expect(actionPhases, [
        'start',
        'success',
        'error',
        'validation-error',
        'settled',
      ]);
      expect(event.actionId, 'id');
      expect(event.timestamp, 42);
      expect(event.payload, {'x': 1});
    });
  });
}
