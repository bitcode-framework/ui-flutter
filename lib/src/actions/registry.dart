/// Custom handler allowlist registry for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.registry;

import 'adapter.dart' show ActionAdapter;

abstract class CustomActionRegistry {
  void register(String handlerKey, ActionAdapter adapter);
  ActionAdapter? resolve(String handlerKey);
  bool has(String handlerKey);
  List<String> keys();
}

class InMemoryCustomActionRegistry implements CustomActionRegistry {
  final Map<String, ActionAdapter> _handlers = {};

  @override
  void register(String handlerKey, ActionAdapter adapter) {
    if (_handlers.containsKey(handlerKey)) {
      throw StateError(
        "CustomActionRegistry: handler '$handlerKey' is already registered.",
      );
    }
    if (adapter.kind != 'handler') {
      throw StateError(
        "CustomActionRegistry: adapter for '$handlerKey' must have kind 'handler', got '${adapter.kind}'.",
      );
    }
    _handlers[handlerKey] = adapter;
  }

  bool unregister(String handlerKey) => _handlers.remove(handlerKey) != null;

  @override
  ActionAdapter? resolve(String handlerKey) => _handlers[handlerKey];

  @override
  bool has(String handlerKey) => _handlers.containsKey(handlerKey);

  @override
  List<String> keys() => List<String>.from(_handlers.keys);
}
