/// Portable Expression AST - Dart port of @bitcode/ui-schema expressions/ast.ts
/// (ADR-018 S5).
///
/// A small, typed, versioned, JSON-serializable expression descriptor used by
/// Ready Block Catalog reactivity. Portable across web, Flutter, RN, server.
///
/// Five node kinds only (ADR-018 S5). The JSON wire shape uses a `kind`
/// discriminator matching the TypeScript AST field-for-field so golden
/// fixtures produce byte-identical results on both platforms.
///
/// Design rules:
///   - Pure: no side effects, no I/O, no globals.
///   - Serializable: every node is plain JSON.
///   - Bounded: depth + step caps guard against DoS (see evaluator).
///   - Permission-filtered: scopes filtered BEFORE evaluation.
///
/// Manual sealed class (no freezed) so the JSON discriminator is exactly the
/// `kind` string the TS package emits ('literal' | 'path' | 'op' | 'call' |
/// 'if'). This guarantees fixture parity without fighting generated code.
library bitcode.ui_schema.expressions.ast;

/// Schema version for the expression AST shape. Mirrors
/// PORTABLE_EXPRESSION_SCHEMA_VERSION in the TypeScript package. Bumped only
/// on backwards-incompatible shape changes.
const int portableExpressionSchemaVersion = 1;

/// All valid node kind strings (mirrors EXPRESSION_NODE_KINDS in ast.ts).
const Set<String> expressionNodeKinds = {
  'literal',
  'path',
  'op',
  'call',
  'if',
};

/// A portable expression node. Sealed union over the five node kinds.
///
/// `if` is a node kind (not an operator) per ADR-018 S5. Use [toJson] and
/// [PortableExpression.fromJson] for serialization; the wire shape is the
/// canonical versioned envelope { schemaVersion, expr } OR a bare node.
sealed class PortableExpression {
  const PortableExpression();

  /// The node kind discriminator ('literal' | 'path' | 'op' | 'call' | 'if').
  String get kind;

  /// Serialize to a JSON map with the canonical `kind` discriminator.
  Map<String, dynamic> toJson();

  /// Deserialize a bare node JSON map into the matching subtype. Throws
  /// [ExpressionParseException] for unknown/malformed nodes.
  static PortableExpression fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'];
    if (rawKind is! String) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Node is missing a string `kind` field.',
      );
    }
    switch (rawKind) {
      case 'literal':
        return LiteralNode.fromJson(json);
      case 'path':
        return PathNode.fromJson(json);
      case 'op':
        return OpNode.fromJson(json);
      case 'call':
        return CallNode.fromJson(json);
      case 'if':
        return IfNode.fromJson(json);
      default:
        throw ExpressionParseException(
          'EXPR_NODE_INVALID',
          "Unknown node kind '$rawKind'.",
        );
    }
  }
}

/// A literal JSON scalar (string, number, boolean) or null. Objects and
/// arrays are NOT valid literals.
final class LiteralNode extends PortableExpression {
  final Object? value;

  const LiteralNode(this.value);

  @override
  String get kind => 'literal';

  @override
  Map<String, dynamic> toJson() => {'kind': 'literal', 'value': value};

  static LiteralNode fromJson(Map<String, dynamic> json) {
    return LiteralNode(json['value']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is LiteralNode && _deepEquals(value, other.value));

  @override
  int get hashCode => Object.hash('literal', value);
}

/// A path reference into the named evaluation scope. Grammar:
///   path := root ('.' segment)*   with optional [index] segments.
/// Reserved roots: values/meta/data/services/permissions/args + sigils.
final class PathNode extends PortableExpression {
  final String path;

  const PathNode(this.path);

  @override
  String get kind => 'path';

  @override
  Map<String, dynamic> toJson() => {'kind': 'path', 'path': path};

  static PathNode fromJson(Map<String, dynamic> json) {
    final raw = json['path'];
    if (raw is! String) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Path node `path` must be a string.',
      );
    }
    return PathNode(raw);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PathNode && path == other.path);

  @override
  int get hashCode => Object.hash('path', path);
}

/// An operator application. Arity enforced by operator specs.
final class OpNode extends PortableExpression {
  final String op;
  final List<PortableExpression> args;

  const OpNode(this.op, this.args);

  @override
  String get kind => 'op';

  @override
  Map<String, dynamic> toJson() => {
        'kind': 'op',
        'op': op,
        'args': args.map((a) => a.toJson()).toList(),
      };

  static OpNode fromJson(Map<String, dynamic> json) {
    final rawOp = json['op'];
    if (rawOp is! String) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Op node `op` must be a string.',
      );
    }
    final rawArgs = json['args'];
    if (rawArgs is! List) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Op node `args` must be a list.',
      );
    }
    final args = rawArgs.map((a) {
      if (a is! Map<String, dynamic>) {
        throw const ExpressionParseException(
          'EXPR_NODE_INVALID',
          'Op node arg is not a JSON object.',
        );
      }
      return PortableExpression.fromJson(a);
    }).toList();
    return OpNode(rawOp, args);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpNode &&
          op == other.op &&
          _listEquals(args, other.args));

  @override
  int get hashCode => Object.hash('op', op, Object.hashAll(args));
}

/// A call to an allowlisted pure built-in function (namespaced name).
final class CallNode extends PortableExpression {
  final String fn;
  final List<PortableExpression> args;

  const CallNode(this.fn, this.args);

  @override
  String get kind => 'call';

  @override
  Map<String, dynamic> toJson() => {
        'kind': 'call',
        'fn': fn,
        'args': args.map((a) => a.toJson()).toList(),
      };

  static CallNode fromJson(Map<String, dynamic> json) {
    final rawFn = json['fn'];
    if (rawFn is! String) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Call node `fn` must be a string.',
      );
    }
    final rawArgs = json['args'];
    if (rawArgs is! List) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Call node `args` must be a list.',
      );
    }
    final args = rawArgs.map((a) {
      if (a is! Map<String, dynamic>) {
        throw const ExpressionParseException(
          'EXPR_NODE_INVALID',
          'Call node arg is not a JSON object.',
        );
      }
      return PortableExpression.fromJson(a);
    }).toList();
    return CallNode(rawFn, args);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallNode &&
          fn == other.fn &&
          _listEquals(args, other.args));

  @override
  int get hashCode => Object.hash('call', fn, Object.hashAll(args));
}

/// A conditional/ternary. `test` MUST evaluate to a boolean (strict).
final class IfNode extends PortableExpression {
  final PortableExpression test;
  final PortableExpression then;
  final PortableExpression elseExpr;

  const IfNode({required this.test, required this.then, required this.elseExpr});

  @override
  String get kind => 'if';

  @override
  Map<String, dynamic> toJson() => {
        'kind': 'if',
        'test': test.toJson(),
        'then': then.toJson(),
        'else': elseExpr.toJson(),
      };

  static IfNode fromJson(Map<String, dynamic> json) {
    final testRaw = json['test'];
    final thenRaw = json['then'];
    final elseRaw = json['else'];
    if (testRaw is! Map<String, dynamic> ||
        thenRaw is! Map<String, dynamic> ||
        elseRaw is! Map<String, dynamic>) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'If node requires test/then/else object fields.',
      );
    }
    return IfNode(
      test: PortableExpression.fromJson(testRaw),
      then: PortableExpression.fromJson(thenRaw),
      elseExpr: PortableExpression.fromJson(elseRaw),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IfNode &&
          test == other.test &&
          then == other.then &&
          elseExpr == other.elseExpr);

  @override
  int get hashCode =>
      Object.hash('if', test, then, elseExpr);
}

/// Versioned serialization envelope. Mirrors
/// PortableExpressionEnvelope in ast.ts.
class PortableExpressionEnvelope {
  final int schemaVersion;
  final PortableExpression expr;

  const PortableExpressionEnvelope({
    required this.schemaVersion,
    required this.expr,
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'expr': expr.toJson(),
      };

  static PortableExpressionEnvelope fromJson(Map<String, dynamic> json) {
    final sv = json['schemaVersion'];
    final exprRaw = json['expr'];
    if (sv is! int || exprRaw is! Map<String, dynamic>) {
      throw const ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Envelope requires integer schemaVersion and object expr.',
      );
    }
    return PortableExpressionEnvelope(
      schemaVersion: sv,
      expr: PortableExpression.fromJson(exprRaw),
    );
  }
}

/// Parse a JSON map into a [PortableExpression], accepting either a bare node
/// or a versioned envelope. Throws [ExpressionParseException] on an
/// unsupported schemaVersion or malformed shape.
PortableExpression parseExpressionJson(Map<String, dynamic> json) {
  if (json.containsKey('schemaVersion') && json.containsKey('expr')) {
    final env = PortableExpressionEnvelope.fromJson(json);
    if (env.schemaVersion != portableExpressionSchemaVersion) {
      throw ExpressionParseException(
        'EXPR_NODE_INVALID',
        'Unsupported portable expression schemaVersion ${env.schemaVersion} '
        '(expected $portableExpressionSchemaVersion).',
      );
    }
    return env.expr;
  }
  return PortableExpression.fromJson(json);
}

/// Typed parse error. Carries a stable code + message so callers can map to
/// [ExpressionError] (see errors.dart) at validation/eval time.
class ExpressionParseException implements Exception {
  final String code;
  final String message;
  const ExpressionParseException(this.code, this.message);
  @override
  String toString() => 'ExpressionParseException($code): $message';
}

// ---------------------------------------------------------------------------
// Equality helpers (deep, for value/list comparison in tests)
// ---------------------------------------------------------------------------

bool _deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List && b is List) return _listEquals(a, b);
  if (a is Map && b is Map) return _mapEquals(a, b);
  return a == b;
}

bool _listEquals(List a, List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_deepEquals(a[i], b[i])) return false;
  }
  return true;
}

bool _mapEquals(Map a, Map b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (!_deepEquals(a[key], b[key])) return false;
  }
  return true;
}
