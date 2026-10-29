/// Validator tests for Dart Portable Expression AST (ADR-018 S5).
///
/// Mirrors the TS validator tests. Exercises: valid shapes, unknown node,
/// path grammar, operator arity, function allow-list, forbidden function
/// denylist, path reserved roots, depth limit.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('validateExpression - valid expressions', () {
    test('literal null is valid', () {
      final expr = LiteralNode(null);
      expect(validateExpression(expr).ok, isTrue);
    });

    test('literal number is valid', () {
      final expr = LiteralNode(42);
      expect(validateExpression(expr).ok, isTrue);
    });

    test('literal string is valid', () {
      final expr = LiteralNode('hello');
      expect(validateExpression(expr).ok, isTrue);
    });

    test('path values.name is valid', () {
      final expr = PathNode('values.name');
      expect(validateExpression(expr).ok, isTrue);
    });

    test('eq comparison is valid', () {
      final expr = OpNode('eq', [PathNode('values.qty'), LiteralNode(0)]);
      expect(validateExpression(expr).ok, isTrue);
    });

    test('ifExpr is valid', () {
      final expr = IfNode(
        test: PathNode('values.active'),
        then: LiteralNode('on'),
        elseExpr: LiteralNode('off'),
      );
      expect(validateExpression(expr).ok, isTrue);
    });

    test('call to known builtin is valid', () {
      final expr = CallNode('string.upper', [LiteralNode('hi')]);
      expect(validateExpression(expr).ok, isTrue);
    });
  });

  group('validateExpression - invalid expressions', () {
    test('literal object is invalid', () {
      final expr = LiteralNode({'a': 1});
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
      expect(r.errors.first.code, ExpressionErrorCode.exprLiteralInvalid);
    });

    test('unknown operator is invalid', () {
      final expr = OpNode('bogusOp', [LiteralNode(1)]);
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
      expect(r.errors.first.code, ExpressionErrorCode.exprOpArity);
    });

    test('eq with 1 arg is invalid (arity)', () {
      final expr = OpNode('eq', [LiteralNode(1)]);
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
      expect(r.errors.first.code, ExpressionErrorCode.exprOpArity);
    });

    test('unknown function is invalid', () {
      final expr = CallNode('string.bogus', [LiteralNode('hi')]);
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
      expect(r.errors.first.code, ExpressionErrorCode.exprCallUnknownFn);
    });

    test('forbidden function name (eval) is rejected', () {
      final expr = CallNode('eval', [LiteralNode('1+1')]);
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
      expect(r.errors.first.code, ExpressionErrorCode.exprCallUnknownFn);
    });

    test('forbidden function name (constructor) is rejected', () {
      final expr = CallNode('constructor', []);
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
    });

    test('non-reserved path root is invalid', () {
      final expr = PathNode('globals.window');
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
    });

    test('forbidden path segment __proto__ is invalid', () {
      final expr = PathNode('values.__proto__');
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
      expect(r.errors.first.code, ExpressionErrorCode.exprPathMalformed);
    });

    test('forbidden path segment constructor is invalid', () {
      final expr = PathNode('values.constructor');
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
    });

    test('malformed path (missing root) is invalid', () {
      final expr = PathNode('.name');
      final r = validateExpression(expr);
      expect(r.ok, isFalse);
    });
  });

  group('JSON roundtrip', () {
    test('literal roundtrip', () {
      final expr = LiteralNode(42);
      final json = expr.toJson();
      final back = PortableExpression.fromJson(json);
      expect(back, equals(expr));
    });

    test('op roundtrip', () {
      final expr = OpNode('eq', [LiteralNode(1), LiteralNode(2)]);
      final json = expr.toJson();
      final back = PortableExpression.fromJson(json);
      expect(back, equals(expr));
    });

    test('if roundtrip preserves else key name', () {
      final expr = IfNode(
        test: LiteralNode(true),
        then: LiteralNode('a'),
        elseExpr: LiteralNode('b'),
      );
      final json = expr.toJson();
      expect(json.containsKey('else'), isTrue);
      expect(json.containsKey('elseExpr'), isFalse);
      final back = PortableExpression.fromJson(json) as IfNode;
      expect(back.then, equals(LiteralNode('a')));
      expect(back.elseExpr, equals(LiteralNode('b')));
    });

    test('envelope serialization', () {
      final env = PortableExpressionEnvelope(
        schemaVersion: portableExpressionSchemaVersion,
        expr: LiteralNode('test'),
      );
      final json = env.toJson();
      expect(json['schemaVersion'], portableExpressionSchemaVersion);
      final back = PortableExpressionEnvelope.fromJson(
          Map<String, dynamic>.from(json));
      expect(back.expr, equals(LiteralNode('test')));
    });
  });

  group('parsePath', () {
    test('values.name.first parses', () {
      final r = parsePath('values.name.first');
      expect(r.ok, isTrue);
      expect(r.parsed!.root, 'values');
      expect(r.parsed!.accessors.length, 2);
    });

    test('values.items[0] parses with index', () {
      final r = parsePath('values.items[0]');
      expect(r.ok, isTrue);
      expect(r.parsed!.accessors[1], 0);
    });

    test('\$self parses as sigil root', () {
      final r = parsePath('\$self');
      expect(r.ok, isTrue);
      expect(r.parsed!.root, '\$self');
    });

    test('unknown root fails', () {
      expect(parsePath('window.location').ok, isFalse);
    });

    test('\$index as root fails', () {
      expect(parsePath('\$index').ok, isFalse);
    });
  });
}
