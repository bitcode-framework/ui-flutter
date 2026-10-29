/// Portable Expression AST - Dart barrel (ADR-018 S5-S6).
///
/// Public API for the portable expression system. Mirrors the TypeScript
/// `@bitcode/ui-schema/expressions` subpath export-for-export.
library bitcode.ui_schema.expressions;

export 'ast.dart';
export 'operators.dart';
export 'errors.dart';
export 'scope.dart';
export 'permission_scope.dart';
export 'function_registry.dart';
export 'builtin_manifest.dart';
export 'validate.dart';
export 'evaluator.dart';
