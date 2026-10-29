import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('ActionResult', () {
    test('normalizes success and malformed results', () {
      final ok = normalizeActionResult({'ok': true, 'data': 1});
      expect(ok.ok, isTrue);
      expect(ok.status, 'success');

      final malformed = normalizeActionResult('nope');
      expect(malformed.ok, isFalse);
      expect(malformed.errorList!.first.code, 'ACTION_RESULT_MALFORMED');

      final missingOk = normalizeActionResult({'status': 200});
      expect(missingOk.ok, isFalse);
      expect(missingOk.status, 200);
    });

    test('synthesizes validation error list from field errors', () {
      final result = normalizeActionResult({
        'ok': false,
        'errors': {
          'email': 'invalid',
          'name': ['required'],
        },
      });
      expect(result.status, 'validation-error');
      expect(
        result.errorList!.map((e) => e.field),
        containsAll(['email', 'name']),
      );
      expect(isValidationError(result), isTrue);
    });

    test('helper constructors produce canonical shapes', () {
      final ok = successResult<Object?>({'id': 1}, message: 'saved');
      expect(ok.ok, isTrue);
      expect(ok.message, 'saved');

      final err = errorResult('X', 'failed', recoverable: true);
      expect(err.errorList!.first.recoverable, isTrue);

      final validation = validationErrorResult({'field': 'bad'});
      expect(validation.status, 'validation-error');
    });
  });
}
