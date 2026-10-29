/// Built-in Function Manifest - Dart port of expressions/builtin-manifest.ts
/// (ADR-018 S6).
///
/// Static manifest of built-in portable expression functions. Every entry
/// MUST exist on web + flutter minimum. Implementations live in the evaluator
/// package; this manifest is the shared contract for "which built-ins exist".
///
/// Pure data. Mirrors the TS manifest name-for-name for parity.
library bitcode.ui_schema.expressions.builtin_manifest;

import 'function_registry.dart';

const List<String> _all = ['web', 'flutter', 'react-native', 'server'];

FunctionManifestEntry _m(
  String name,
  bool deterministic, {
  Object? inputSchema,
  Object? outputSchema,
  String? timezone,
  String? locale,
}) =>
    FunctionManifestEntry(
      name: name,
      version: '1.0.0',
      platforms: _all,
      pure: true,
      deterministic: deterministic,
      inputSchema: inputSchema,
      outputSchema: outputSchema,
      fallback: 'error',
      timezone: timezone,
      locale: locale,
    );

/// Canonical built-in manifest. Stable, namespace-grouped order. Mirrors
/// BUILTIN_FUNCTION_MANIFEST in builtin-manifest.ts.
final List<FunctionManifestEntry> builtinFunctionManifest = [
  // math.* (pure, deterministic)
  _m('math.abs', true, inputSchema: 'number', outputSchema: 'number'),
  _m('math.ceil', true, inputSchema: 'number', outputSchema: 'number'),
  _m('math.floor', true, inputSchema: 'number', outputSchema: 'number'),
  _m('math.round', true, inputSchema: 'number', outputSchema: 'number'),
  _m('math.min', true, inputSchema: 'number[]', outputSchema: 'number'),
  _m('math.max', true, inputSchema: 'number[]', outputSchema: 'number'),
  _m('math.pow', true, inputSchema: 'number,number', outputSchema: 'number'),
  _m('math.sqrt', true, inputSchema: 'number', outputSchema: 'number'),
  _m('math.mod', true, inputSchema: 'number,number', outputSchema: 'number'),
  _m('math.clamp', true, inputSchema: 'number,number,number', outputSchema: 'number'),
  _m('math.sign', true, inputSchema: 'number', outputSchema: 'number'),

  // string.* (pure, deterministic)
  _m('string.concat', true, inputSchema: 'string[]', outputSchema: 'string'),
  _m('string.upper', true, inputSchema: 'string', outputSchema: 'string'),
  _m('string.lower', true, inputSchema: 'string', outputSchema: 'string'),
  _m('string.trim', true, inputSchema: 'string', outputSchema: 'string'),
  _m('string.split', true, inputSchema: 'string,string', outputSchema: 'string[]'),
  _m('string.contains', true, inputSchema: 'string,string', outputSchema: 'boolean'),
  _m('string.startsWith', true, inputSchema: 'string,string', outputSchema: 'boolean'),
  _m('string.endsWith', true, inputSchema: 'string,string', outputSchema: 'boolean'),
  _m('string.substring', true, inputSchema: 'string,number,number', outputSchema: 'string'),
  _m('string.replace', true, inputSchema: 'string,string,string', outputSchema: 'string'),
  _m('string.padLeft', true, inputSchema: 'string,number,string', outputSchema: 'string'),
  _m('string.padRight', true, inputSchema: 'string,number,string', outputSchema: 'string'),
  _m('string.slugify', true, inputSchema: 'string', outputSchema: 'string'),
  _m('string.length', true, inputSchema: 'string', outputSchema: 'number'),

  // array.* (pure, deterministic; higher-order fns accept AST lambdas via args.fn)
  _m('array.sum', true, inputSchema: 'number[]', outputSchema: 'number'),
  _m('array.count', true, inputSchema: 'array', outputSchema: 'number'),
  _m('array.min', true, inputSchema: 'number[]', outputSchema: 'number'),
  _m('array.max', true, inputSchema: 'number[]', outputSchema: 'number'),
  _m('array.avg', true, inputSchema: 'number[]', outputSchema: 'number'),
  _m('array.includes', true, inputSchema: 'array,any', outputSchema: 'boolean'),
  _m('array.find', true, inputSchema: 'array,fn', outputSchema: 'any'),
  _m('array.filter', true, inputSchema: 'array,fn', outputSchema: 'array'),
  _m('array.map', true, inputSchema: 'array,fn', outputSchema: 'array'),
  _m('array.reduce', true, inputSchema: 'array,fn,any', outputSchema: 'any'),
  _m('array.sort', true, inputSchema: 'array,fn?', outputSchema: 'array'),
  _m('array.slice', true, inputSchema: 'array,number,number', outputSchema: 'array'),
  _m('array.compact', true, inputSchema: 'array', outputSchema: 'array'),
  _m('array.length', true, inputSchema: 'array', outputSchema: 'number'),
  _m('array.from', true, inputSchema: 'any...', outputSchema: 'array'),

  // date.* (timezone: explicit-arg; now is the only non-deterministic entry)
  _m('date.now', false, inputSchema: 'none', outputSchema: 'string', timezone: 'utc'),
  _m('date.parse', true, inputSchema: 'string,string', outputSchema: 'string', timezone: 'explicit-arg'),
  _m('date.format', true, inputSchema: 'string,string,string', outputSchema: 'string', timezone: 'explicit-arg', locale: 'explicit-arg'),
  _m('date.addDuration', true, inputSchema: 'string,string,number,string', outputSchema: 'string', timezone: 'explicit-arg'),
  _m('date.diff', true, inputSchema: 'string,string,string,string', outputSchema: 'number', timezone: 'explicit-arg'),
  _m('date.startOfDay', true, inputSchema: 'string,string', outputSchema: 'string', timezone: 'explicit-arg'),
  _m('date.endOfDay', true, inputSchema: 'string,string', outputSchema: 'string', timezone: 'explicit-arg'),
  _m('date.startOfMonth', true, inputSchema: 'string,string', outputSchema: 'string', timezone: 'explicit-arg'),
  _m('date.endOfMonth', true, inputSchema: 'string,string', outputSchema: 'string', timezone: 'explicit-arg'),
  _m('date.isWeekend', true, inputSchema: 'string,string', outputSchema: 'boolean', timezone: 'explicit-arg'),
  _m('date.isBefore', true, inputSchema: 'string,string,string', outputSchema: 'boolean', timezone: 'explicit-arg'),
  _m('date.isAfter', true, inputSchema: 'string,string,string', outputSchema: 'boolean', timezone: 'explicit-arg'),
  _m('date.daysInMonth', true, inputSchema: 'number,string', outputSchema: 'number', timezone: 'explicit-arg'),
  _m('date.isLeapYear', true, inputSchema: 'number', outputSchema: 'boolean'),
  _m('date.toISO', true, inputSchema: 'string,string', outputSchema: 'string', timezone: 'explicit-arg'),
  _m('date.fromISO', true, inputSchema: 'string', outputSchema: 'string'),
  _m('date.toUnix', true, inputSchema: 'string,string', outputSchema: 'number', timezone: 'explicit-arg'),
  _m('date.fromUnix', true, inputSchema: 'number,string', outputSchema: 'string', timezone: 'explicit-arg'),

  // format.* (locale: explicit-arg with invariant fallback)
  _m('format.number', true, inputSchema: 'number,string', outputSchema: 'string', locale: 'explicit-arg'),
  _m('format.bytes', true, inputSchema: 'number', outputSchema: 'string', locale: 'invariant'),
  _m('format.percent', true, inputSchema: 'number,string', outputSchema: 'string', locale: 'explicit-arg'),
  _m('format.date', true, inputSchema: 'string,string,string', outputSchema: 'string', locale: 'explicit-arg', timezone: 'explicit-arg'),

  // validate.* (pure, deterministic)
  _m('validate.isEmail', true, inputSchema: 'string', outputSchema: 'boolean'),
  _m('validate.isURL', true, inputSchema: 'string', outputSchema: 'boolean'),
  _m('validate.isUUID', true, inputSchema: 'string', outputSchema: 'boolean'),
  _m('validate.isIP', true, inputSchema: 'string', outputSchema: 'boolean'),
  _m('validate.isNumeric', true, inputSchema: 'string', outputSchema: 'boolean'),
  _m('validate.isAlpha', true, inputSchema: 'string', outputSchema: 'boolean'),
  _m('validate.isAlphaNum', true, inputSchema: 'string', outputSchema: 'boolean'),
  _m('validate.isHexColor', true, inputSchema: 'string', outputSchema: 'boolean'),
];

/// Set of all built-in function names (fast lookup).
final Set<String> builtinFunctionNames =
    builtinFunctionManifest.map((e) => e.name).toSet();

/// True if [name] is a declared built-in function.
bool isBuiltinFunction(String name) => builtinFunctionNames.contains(name);
