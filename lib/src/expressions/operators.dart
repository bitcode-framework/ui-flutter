/// Portable Expression Operators - Dart port of expressions/operators.ts
/// (ADR-018 S5).
///
/// The required operator set for Ready Catalog expressions. Closed set; new
/// operators require a schema version bump. Arity bounds live in
/// [operatorArity] for validator/evaluator parity with the TS package.
library bitcode.ui_schema.expressions.operators;

/// Built-in operators (ADR-018 S5).
///
/// Grouped by family; the union is the canonical set. Adding an operator is
/// additive IF every platform implements it, else it is a contract gap.
enum PortableOperator {
  // comparisons
  eq,
  ne,
  gt,
  gte,
  lt,
  lte,
  // boolean
  and,
  or,
  not,
  // arithmetic
  add,
  sub,
  mul,
  div,
  // aggregation
  sum,
  count,
  min,
  max,
  avg,
  // string / list
  concat,
  contains,
  startsWith,
  endsWith,
  // null / empty
  isEmpty,
  isNotEmpty,
  coalesce,
}

/// All valid operator names (mirrors PORTABLE_OPERATORS in operators.ts).
const Set<String> portableOperators = {
  'eq', 'ne', 'gt', 'gte', 'lt', 'lte',
  'and', 'or', 'not',
  'add', 'sub', 'mul', 'div',
  'sum', 'count', 'min', 'max', 'avg',
  'concat', 'contains', 'startsWith', 'endsWith',
  'isEmpty', 'isNotEmpty', 'coalesce',
};

/// Parse a string into a [PortableOperator], or null if unknown.
PortableOperator? parseOperator(String name) {
  for (final op in PortableOperator.values) {
    if (op.name == name) return op;
  }
  return null;
}

/// Whether [name] is a known canonical operator.
bool isPortableOperatorName(String name) => portableOperators.contains(name);

/// Operator family.
enum OperatorFamily { comparison, boolean, arithmetic, aggregation, stringList, nullEmpty }

/// Static spec for one operator.
class OperatorSpec {
  final String op;
  final OperatorFamily family;
  final int? arity; // exact, or null when variadic
  final int minArgs;
  final int? maxArgs; // null = unbounded

  const OperatorSpec({
    required this.op,
    required this.family,
    this.arity,
    required this.minArgs,
    this.maxArgs,
  });
}

/// Canonical operator spec table. Single source of truth for arity bounds.
/// Mirrors OPERATOR_SPECS in operators.ts.
const Map<String, OperatorSpec> operatorSpecs = {
  'eq':           OperatorSpec(op: 'eq',           family: OperatorFamily.comparison,  arity: 2,  minArgs: 2, maxArgs: 2),
  'ne':           OperatorSpec(op: 'ne',           family: OperatorFamily.comparison,  arity: 2,  minArgs: 2, maxArgs: 2),
  'gt':           OperatorSpec(op: 'gt',           family: OperatorFamily.comparison,  arity: 2,  minArgs: 2, maxArgs: 2),
  'gte':          OperatorSpec(op: 'gte',          family: OperatorFamily.comparison,  arity: 2,  minArgs: 2, maxArgs: 2),
  'lt':           OperatorSpec(op: 'lt',           family: OperatorFamily.comparison,  arity: 2,  minArgs: 2, maxArgs: 2),
  'lte':          OperatorSpec(op: 'lte',          family: OperatorFamily.comparison,  arity: 2,  minArgs: 2, maxArgs: 2),
  'and':          OperatorSpec(op: 'and',          family: OperatorFamily.boolean,     arity: null, minArgs: 2, maxArgs: null),
  'or':           OperatorSpec(op: 'or',           family: OperatorFamily.boolean,     arity: null, minArgs: 2, maxArgs: null),
  'not':          OperatorSpec(op: 'not',          family: OperatorFamily.boolean,     arity: 1,  minArgs: 1, maxArgs: 1),
  'add':          OperatorSpec(op: 'add',          family: OperatorFamily.arithmetic,  arity: 2,  minArgs: 2, maxArgs: 2),
  'sub':          OperatorSpec(op: 'sub',          family: OperatorFamily.arithmetic,  arity: 2,  minArgs: 2, maxArgs: 2),
  'mul':          OperatorSpec(op: 'mul',          family: OperatorFamily.arithmetic,  arity: 2,  minArgs: 2, maxArgs: 2),
  'div':          OperatorSpec(op: 'div',          family: OperatorFamily.arithmetic,  arity: 2,  minArgs: 2, maxArgs: 2),
  'sum':          OperatorSpec(op: 'sum',          family: OperatorFamily.aggregation, arity: null, minArgs: 1, maxArgs: null),
  'count':        OperatorSpec(op: 'count',        family: OperatorFamily.aggregation, arity: null, minArgs: 1, maxArgs: null),
  'min':          OperatorSpec(op: 'min',          family: OperatorFamily.aggregation, arity: null, minArgs: 1, maxArgs: null),
  'max':          OperatorSpec(op: 'max',          family: OperatorFamily.aggregation, arity: null, minArgs: 1, maxArgs: null),
  'avg':          OperatorSpec(op: 'avg',          family: OperatorFamily.aggregation, arity: null, minArgs: 1, maxArgs: null),
  'concat':       OperatorSpec(op: 'concat',       family: OperatorFamily.stringList,  arity: null, minArgs: 0, maxArgs: null),
  'contains':     OperatorSpec(op: 'contains',     family: OperatorFamily.stringList,  arity: 2,  minArgs: 2, maxArgs: 2),
  'startsWith':   OperatorSpec(op: 'startsWith',   family: OperatorFamily.stringList,  arity: 2,  minArgs: 2, maxArgs: 2),
  'endsWith':     OperatorSpec(op: 'endsWith',     family: OperatorFamily.stringList,  arity: 2,  minArgs: 2, maxArgs: 2),
  'isEmpty':      OperatorSpec(op: 'isEmpty',      family: OperatorFamily.nullEmpty,   arity: 1,  minArgs: 1, maxArgs: 1),
  'isNotEmpty':   OperatorSpec(op: 'isNotEmpty',   family: OperatorFamily.nullEmpty,   arity: 1,  minArgs: 1, maxArgs: 1),
  'coalesce':     OperatorSpec(op: 'coalesce',     family: OperatorFamily.nullEmpty,   arity: null, minArgs: 2, maxArgs: null),
};

/// Lookup the spec for [op], or null if unknown.
OperatorSpec? getOperatorSpec(String op) => operatorSpecs[op];
