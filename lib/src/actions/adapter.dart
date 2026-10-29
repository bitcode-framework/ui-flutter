/// Action adapter contracts and registry for ADR-018 action runtime parity.
library bitcode.ui_schema.actions.adapter;

import 'result.dart' show ActionResult;
import 'runtime_context.dart' show ActionRuntimeContext;
import 'source.dart' show ActionSource;

abstract class ActionAbortSignal {
  bool get aborted;
  void addListener(void Function() listener);
  void removeListener(void Function() listener);
}

class ActionAbortController {
  final _signal = MutableActionAbortSignal();

  ActionAbortSignal get signal => _signal;

  void abort() => _signal.abort();
}

class MutableActionAbortSignal implements ActionAbortSignal {
  bool _aborted = false;
  final Set<void Function()> _listeners = {};

  @override
  bool get aborted => _aborted;

  @override
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void abort() {
    if (_aborted) return;
    _aborted = true;
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }
}

abstract class ActionAdapter {
  String get kind;

  Future<ActionResult<Object?>> execute(
    ActionSource source,
    Object? payload,
    ActionRuntimeContext ctx,
    ActionAbortSignal signal,
  );
}

abstract class ActionAdapterRegistry {
  void register(String key, ActionAdapter adapter);
  ActionAdapter? resolve(String key);
  bool has(String key);
  List<String> keys();
}

class InMemoryActionAdapterRegistry implements ActionAdapterRegistry {
  final Map<String, ActionAdapter> _adapters = {};

  @override
  void register(String key, ActionAdapter adapter) {
    if (_adapters.containsKey(key)) {
      throw StateError(
        "ActionAdapterRegistry: adapter '$key' is already registered. Call unregister first or use a different key.",
      );
    }
    _adapters[key] = adapter;
  }

  bool unregister(String key) => _adapters.remove(key) != null;

  @override
  ActionAdapter? resolve(String key) => _adapters[key];

  @override
  bool has(String key) => _adapters.containsKey(key);

  @override
  List<String> keys() => List<String>.from(_adapters.keys);
}
