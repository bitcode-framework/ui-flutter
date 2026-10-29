/// Expression Validator - Dart port of expressions/validate.ts (ADR-018 S5).
///
/// Static validation of a [PortableExpression] AST: node shape, operator
/// arity, function allow-list membership, path grammar + reserved-roots, and a
/// hardcoded denylist of eval-like function names. Mirrors validateExpression
/// in the TS package for parity.
library bitcode.ui_schema.expressions.validate;

import 'ast.dart';
import 'operators.dart';
import 'scope.dart';
import 'errors.dart';
import 'function_registry.dart';
import 'builtin_manifest.dart';

/// Function names that are ALWAYS rejected, regardless of registry. These are
/// eval/constructor/host/global names that must never be callable from
/// catalog JSON. Mirrors FORBIDDEN_FUNCTION_NAMES in validate.ts.
const Set<String> forbiddenFunctionNames = {
  'eval',
  'Function',
  'setTimeout',
  'process',
  'window',
  'document',
  'fetch',
  'constructor',
  '__proto__',
  'prototype',
  'reflect',
  'require',
  'globalThis',
  'setInterval',
  'setImmediate',
};

/// Path segments that must always be rejected.
const Set<String> forbiddenPathSegments = {
  '__proto__',
  'constructor',
  'prototype',
};


/// Result of expression validation.
class ValidationResult {
  final bool ok;
  final List<ExpressionError> errors;

  const ValidationResult._({required this.ok, required this.errors});

  const ValidationResult.ok() : this._(ok: true, errors: const []);
  ValidationResult.fail(List<ExpressionError> errors)
      : this._(ok: false, errors: errors);

  bool get hasErrors => errors.isNotEmpty;
}

/// Validate a [PortableExpression] statically. Mirrors validateExpression in
/// validate.ts.
///
/// [registry] is optional: when provided, functions are checked against it;
/// when null, functions are checked against the built-in manifest only.
ValidationResult validateExpression(
  PortableExpression expr, {
  FunctionRegistry? registry,
}) {
  final errors = <ExpressionError>[];
  _validateNode(expr, 'root', errors, registry, 0);
  if (errors.isEmpty) return const ValidationResult.ok();
  return ValidationResult.fail(errors);
}

void _validateNode(
  PortableExpression node,
  String path,
  List<ExpressionError> errors,
  FunctionRegistry? registry,
  int depth,
) {
  if (depth > exprMaxDepth) {
    errors.add(ExpressionError(
      code: ExpressionErrorCode.exprDepthExceeded,
      message: 'Expression depth exceeds $exprMaxDepth.',
      nodePath: path,
    ));
    return;
  }

  switch (node) {
    case LiteralNode():
      final v = node.value;
      if (v != null &&
          v is! String &&
          v is! num &&
          v is! bool) {
        errors.add(ExpressionError(
          code: ExpressionErrorCode.exprLiteralInvalid,
          message: 'Literal must be string, number, boolean, or null.',
          nodePath: path,
        ));
      }
    case PathNode():
      final pp = parsePath(node.path);
      if (!pp.ok) {
        errors.add(ExpressionError(
          code: ExpressionErrorCode.exprPathMalformed,
          message: pp.error ?? 'malformed path',
          nodePath: path,
          path: node.path,
        ));
      } else if (pp.parsed != null) {
        final root = pp.parsed!.root;
        if (!pathReservedRoots.contains(root)) {
          errors.add(ExpressionError(
            code: ExpressionErrorCode.exprPathMalformed,
            message: "Path root '$root' is not a reserved scope root.",
            nodePath: path,
            path: node.path,
          ));
        }
        for (final seg in pp.parsed!.accessors) {
          if (seg is String && forbiddenPathSegments.contains(seg)) {
            errors.add(ExpressionError(
              code: ExpressionErrorCode.exprPathMalformed,
              message: "Forbidden path segment '$seg'.",
              nodePath: path,
              path: node.path,
            ));
          }
        }
      }
    case OpNode():
      final spec = getOperatorSpec(node.op);
      if (spec == null) {
        errors.add(ExpressionError(
          code: ExpressionErrorCode.exprOpArity,
          message: "Unknown operator '${node.op}'.",
          nodePath: path,
        ));
      } else {
        if (node.args.length < spec.minArgs) {
          errors.add(ExpressionError(
            code: ExpressionErrorCode.exprOpArity,
            message:
                "Operator '${node.op}' requires at least ${spec.minArgs} args, got ${node.args.length}.",
            nodePath: path,
          ));
        }
        if (spec.maxArgs != null && node.args.length > spec.maxArgs!) {
          errors.add(ExpressionError(
            code: ExpressionErrorCode.exprOpArity,
            message:
                "Operator '${node.op}' accepts at most ${spec.maxArgs} args, got ${node.args.length}.",
            nodePath: path,
          ));
        }
      }
      for (var i = 0; i < node.args.length; i++) {
        _validateNode(
          node.args[i],
          '$path.op.args[$i]',
          errors,
          registry,
          depth + 1,
        );
      }
    case CallNode():
      if (forbiddenFunctionNames.contains(node.fn)) {
        errors.add(ExpressionError(
          code: ExpressionErrorCode.exprCallUnknownFn,
          message: "Forbidden function name '${node.fn}'.",
          nodePath: path,
        ));
      } else {
        final known = registry != null
            ? registry.has(node.fn)
            : isBuiltinFunction(node.fn);
        if (!known) {
          final suggestions = suggestFunctions(node.fn, registry);
          errors.add(ExpressionError(
            code: ExpressionErrorCode.exprCallUnknownFn,
            message: "Unknown function '${node.fn}'.",
            nodePath: path,
            suggestions: suggestions,
          ));
        }
      }
      for (var i = 0; i < node.args.length; i++) {
        _validateNode(
          node.args[i],
          '$path.call.args[$i]',
          errors,
          registry,
          depth + 1,
        );
      }
    case IfNode():
      _validateNode(node.test, '$path.if.test', errors, registry, depth + 1);
      _validateNode(node.then, '$path.if.then', errors, registry, depth + 1);
      _validateNode(node.elseExpr, '$path.if.else', errors, registry, depth + 1);
  }
}

/// Suggest similar function names for typo correction (Levenshtein distance <= 3).
List<String> suggestFunctions(String name, FunctionRegistry? registry) {
  final pool = <String>[];
  if (registry != null) {
    pool.addAll(registry.entries().map((e) => e.name));
  } else {
    pool.addAll(builtinFunctionNames);
  }
  final result = <String>[];
  for (final candidate in pool) {
    if (_levenshtein(name, candidate) <= 3) {
      result.add(candidate);
    }
  }
  result.sort();
  return result.take(5).toList();
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final m = a.length;
  final n = b.length;
  var prev = List<int>.filled(n + 1, 0);
  var curr = List<int>.filled(n + 1, 0);
  for (var j = 0; j <= n; j++) {
    prev[j] = j;
  }
  for (var i = 1; i <= m; i++) {
    curr[0] = i;
    for (var j = 1; j <= n; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      final del = prev[j] + 1;
      final ins = curr[j - 1] + 1;
      final sub = prev[j - 1] + cost;
      curr[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
    }
    final tmp = prev;
    prev = curr;
    curr = tmp;
  }
  return prev[n];
}
