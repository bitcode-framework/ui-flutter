/// Built-in Function Registry - Dart port of expressions/function-registry.ts
/// (ADR-018 S6).
///
/// Manifest of pure built-in functions callable from `call` nodes. Names,
/// platforms, purity, determinism, and timezone/locale behavior mirror the TS
/// manifest field-for-field for parity.
library bitcode.ui_schema.expressions.function_registry;

/// Platform identifier (mirrors BlockPlatform).
typedef FunctionPlatform = String;

/// Manifest entry for a built-in or host function. `pure: true` is a contract.
class FunctionManifestEntry {
  final String name;
  final String version;
  final List<FunctionPlatform> platforms;
  final bool pure;
  final bool deterministic;
  final Object? inputSchema;
  final Object? outputSchema;
  final String fallback;
  final String? timezone;
  final String? locale;

  const FunctionManifestEntry({
    required this.name,
    required this.version,
    required this.platforms,
    required this.pure,
    required this.deterministic,
    this.inputSchema,
    this.outputSchema,
    this.fallback = 'error',
    this.timezone,
    this.locale,
  });
}

/// A pure function implementation. Type is permissive; arity/type checking
/// happens at the manifest/evaluator boundary.
typedef FunctionImpl = Object? Function(List<Object?> args);

/// Registry of manifest entries plus optional resolvers.
abstract class FunctionRegistry {
  bool has(String name);
  FunctionManifestEntry? get(String name);
  FunctionImpl? resolve(String name);
  void register(FunctionManifestEntry entry, [FunctionImpl? impl]);
  List<FunctionManifestEntry> entries();
}

/// Diagnostic from manifest validation (ADR-018 S6 acceptance criteria).
class FunctionRegistryDiagnostic {
  final String code;
  final String name;
  final String message;

  const FunctionRegistryDiagnostic({
    required this.code,
    required this.name,
    required this.message,
  });
}

/// Minimal in-memory registry backed by a map. Hosts register implementations
/// at runtime; the static built-in manifest seeds known function names.
class InMemoryFunctionRegistry implements FunctionRegistry {
  final Map<String, FunctionManifestEntry> _manifests = {};
  final Map<String, FunctionImpl> _impls = {};

  InMemoryFunctionRegistry();

  @override
  bool has(String name) => _manifests.containsKey(name);

  @override
  FunctionManifestEntry? get(String name) => _manifests[name];

  @override
  FunctionImpl? resolve(String name) => _impls[name];

  @override
  void register(FunctionManifestEntry entry, [FunctionImpl? impl]) {
    _manifests[entry.name] = entry;
    if (impl != null) _impls[entry.name] = impl;
  }

  @override
  List<FunctionManifestEntry> entries() =>
      _manifests.values.toList(growable: false);
}
