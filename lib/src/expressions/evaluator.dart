/// Evaluator Interface - Dart port of expressions/evaluator.ts (ADR-018 S5).
///
/// Contract for pure AST evaluators. Implementations live in host adapters
/// (e.g. the Flutter reactive engine) and MUST be deterministic, side-effect
/// free, and bounded by the step budget. Mirrors ExpressionEvaluator.
library bitcode.ui_schema.expressions.evaluator;

import 'ast.dart';
import 'scope.dart';
import 'errors.dart';

/// Result of an evaluation.
class EvalResult {
  final bool ok;
  final Object? value;
  final List<ExpressionError> errors;

  const EvalResult._({required this.ok, required this.errors, this.value});

  const EvalResult.ok(Object? value)
      : this._(ok: true, errors: const [], value: value);
  const EvalResult.fail(List<ExpressionError> errors)
      : this._(ok: false, errors: errors);
}

/// Pure AST evaluator contract. Implementations MUST:
///   - be deterministic for the same (expr, scope) pair (modulo date.now),
///   - respect the permission-filtered scope (callers filter before passing),
///   - bound evaluation by depth + step budget, and
///   - never perform I/O or side effects.
abstract class ExpressionEvaluator {
  /// Evaluate [expr] against [scope]. Returns an [EvalResult].
  EvalResult evaluate(PortableExpression expr, ExpressionScope scope);
}
