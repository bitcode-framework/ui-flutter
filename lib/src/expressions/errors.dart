/// Portable Expression Errors - Dart port of expressions/errors.ts (ADR-018 S5).
///
/// Typed evaluation/validation errors with node-path tracking. Mirrors the TS
/// ExpressionError shape field-for-field so diagnostics are consistent across
/// platforms.
library bitcode.ui_schema.expressions.errors;

/// Stable error codes for portable expression evaluation and validation.
/// Prefixed `EXPR_*` to keep a separate code space from `BLOCK_*` (ADR-017).
enum ExpressionErrorCode {
  exprPathMissing('EXPR_PATH_MISSING'),
  exprPathUnauthorized('EXPR_PATH_UNAUTHORIZED'),
  exprPathMalformed('EXPR_PATH_MALFORMED'),
  exprOpArity('EXPR_OP_ARITY'),
  exprOpType('EXPR_OP_TYPE'),
  exprOpDivZero('EXPR_OP_DIV_ZERO'),
  exprCallUnknownFn('EXPR_CALL_UNKNOWN_FN'),
  exprCallFnPlatform('EXPR_CALL_FN_PLATFORM'),
  exprCallArgType('EXPR_CALL_ARG_TYPE'),
  exprLiteralInvalid('EXPR_LITERAL_INVALID'),
  exprNodeInvalid('EXPR_NODE_INVALID'),
  exprDepthExceeded('EXPR_DEPTH_EXCEEDED'),
  exprStepBudgetExceeded('EXPR_STEP_BUDGET_EXCEEDED'),
  exprCycle('EXPR_CYCLE');

  final String code;
  const ExpressionErrorCode(this.code);

  static ExpressionErrorCode? fromCode(String code) {
    for (final v in ExpressionErrorCode.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}

/// Maximum AST nesting depth (DoS guard). Mirrors EXPR_MAX_DEPTH.
const int exprMaxDepth = 64;

/// Maximum evaluation steps (DoS guard). One step ~= one node visit.
const int exprMaxSteps = 10000;

/// A typed expression error.
class ExpressionError {
  final ExpressionErrorCode code;
  final String message;

  /// Dotted path to the offending AST node, e.g. 'op.args[1].call'.
  final String? nodePath;

  /// The resolved data path that failed (for path errors).
  final String? path;

  /// Suggested similar function/operator names for typo fixes.
  final List<String> suggestions;

  const ExpressionError({
    required this.code,
    required this.message,
    this.nodePath,
    this.path,
    this.suggestions = const [],
  });

  @override
  String toString() => 'ExpressionError(${code.code}): $message';
}
