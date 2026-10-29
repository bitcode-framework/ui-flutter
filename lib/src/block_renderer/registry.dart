/// Block Component Registry Contract - Dart mirror of @bitcode/ui-schema
/// block-renderer/registry-contract.ts (ADR-017 §5, Agent H).
///
/// The PORTABLE registry interface. Stores COMPONENT METADATA ONLY — never a
/// Flutter widget object (amendment 3: the portable layer must not be tainted
/// by framework references). The Flutter widget binding (follow-up) maintains
/// a parallel registry that maps `componentKey` to the actual widget builder.
///
/// The renderer engine consults this registry to validate that required
/// components are registered and to emit BLOCK_COMPONENT_MISSING diagnostics.
/// It never instantiates a widget from here.
library bitcode.ui_schema.block_renderer.registry;

import 'block_node.dart' show ComponentMetadata;

/// Portable block component registry contract. Stores metadata keyed by
/// canonical component key.
abstract class BlockComponentRegistry {
  /// Register component metadata under its canonical key. Throws on duplicate.
  void register(ComponentMetadata meta);

  /// Resolve metadata by canonical key. Null when not registered.
  ComponentMetadata? resolve(String componentKey);

  /// Whether a canonical key is registered.
  bool has(String componentKey);

  /// All registered canonical keys (for diagnostics).
  List<String> keys();
}

/// Default in-memory registry. Throws on duplicate registration to surface key
/// collisions loudly (ADR-017 §5.2).
class InMemoryBlockComponentRegistry implements BlockComponentRegistry {
  final Map<String, ComponentMetadata> _components = {};

  @override
  void register(ComponentMetadata meta) {
    if (meta.componentKey.isEmpty) {
      throw ArgumentError(
        'InMemoryBlockComponentRegistry.register: componentKey must be non-empty.',
      );
    }
    if (_components.containsKey(meta.componentKey)) {
      throw StateError(
        "InMemoryBlockComponentRegistry: component '${meta.componentKey}' is already registered.",
      );
    }
    _components[meta.componentKey] = meta;
  }

  /// Remove a registered component (test/demo convenience).
  bool unregister(String componentKey) =>
      _components.remove(componentKey) != null;

  @override
  ComponentMetadata? resolve(String componentKey) => _components[componentKey];

  @override
  bool has(String componentKey) => _components.containsKey(componentKey);

  @override
  List<String> keys() => _components.keys.toList(growable: false);
}
