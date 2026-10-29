// ============================================================================
// BcLocalStorageStore — Dart port of the TS `useLocalStorage`/
// `createLocalStorage` hook (packages/ui/src/core/hooks/use-local-storage.ts,
// ADR-013 §3).
//
// Flutter parity note (A044): The TS hook talks to the browser `localStorage`
// and cross-tab `storage` events. Flutter has no `localStorage` — apps use
// `shared_preferences`, secure storage, or a file-backed KV store. Rather
// than hard-coupling this port to a single plugin (which would add a runtime
// dependency), the store accepts an injectable [BcStorageBackend] and ships a
// pure-Dart in-memory default backend. Hosts wire the backend of their choice
// (shared_preferences, hive, …) at the provider boundary.
//
// The in-memory default is NOT cross-tab/persistent — it mirrors the TS
// "SSR / non-browser" no-op store shape (returns default, never persists) so
// the parity surface is testable in `dart test` with zero plugins. A
// `shared_preferences`-backed implementation can be provided by the host app
// and injected via [BcLocalStorageStore.withBackend].
// ============================================================================

import 'dart:convert';

/// Backend contract for a key-value JSON store. Implementations may wrap
/// `shared_preferences`, Hive, a file, or an in-memory map for tests.
abstract class BcStorageBackend {
  /// Read the raw JSON string for [key], or `null` when absent.
  String? read(String key);
  /// Write the raw JSON string for [key].
  void write(String key, String value);
  /// Remove [key] (no-op when absent).
  void remove(String key);
}

/// Pure-Dart in-memory backend. Not persistent, not cross-tab — mirrors the
/// TS SSR/no-browser no-op store and makes the parity surface testable.
class BcMemoryStorageBackend implements BcStorageBackend {
  final Map<String, String> _store = {};

  @override
  String? read(String key) => _store[key];

  @override
  void write(String key, String value) {
    _store[key] = value;
  }

  @override
  void remove(String key) {
    _store.remove(key);
  }
}

/// Listener signature. Receives the new value.
typedef BcLocalStorageListener<T> = void Function(T value);

/// Typed local-storage wrapper with subscribe/dispose. Mirrors the TS
/// `LocalStorageStore<T>` contract (`get`/`set`/`subscribe`/`dispose`).
///
/// JSON serialization round-trips values via `jsonEncode`/`jsonDecode`. On a
/// parse error the store treats the entry as absent and returns
/// [defaultValue] (never throws), parity with the TS hook.
class BcLocalStorageStore<T> {
  final String _key;
  final T _defaultValue;
  final BcStorageBackend _backend;
  final Set<BcLocalStorageListener<T>> _listeners = {};
  final T Function(Object? json) _fromJson;
  final Object Function(T value) _toJson;
  bool _disposed = false;

  BcLocalStorageStore._({
    required String key,
    required T defaultValue,
    required BcStorageBackend backend,
    required T Function(Object? json) fromJson,
    required Object Function(T value) toJson,
  })  : _key = key,
        _defaultValue = defaultValue,
        _backend = backend,
        _fromJson = fromJson,
        _toJson = toJson;

  /// Default constructor: in-memory backend (not persistent). Mirrors the TS
  /// SSR/no-browser no-op store so the contract is testable without plugins.
  ///
  /// - [fromJson] decodes a decoded JSON value into `T`. For primitives pass
  ///   `(j) => j as T`. For objects, provide the constructor/map cast.
  /// - [toJson] encodes `T` into a JSON-encodable value.
  factory BcLocalStorageStore({
    required String key,
    required T defaultValue,
    required T Function(Object? json) fromJson,
    required Object Function(T value) toJson,
    BcStorageBackend? backend,
  }) =>
      BcLocalStorageStore._(
        key: key,
        defaultValue: defaultValue,
        backend: backend ?? BcMemoryStorageBackend(),
        fromJson: fromJson,
        toJson: toJson,
      );

  /// Current value. [defaultValue] when the key is absent or malformed.
  T get() {
    final raw = _backend.read(_key);
    if (raw == null) return _defaultValue;
    try {
      final decoded = _decodeJson(raw);
      return _fromJson(decoded);
    } catch (_) {
      // Malformed JSON — treat as absent (parity with TS hook).
      return _defaultValue;
    }
  }

  /// Persist [value] and notify subscribers.
  void set(T value) {
    if (_disposed) return;
    try {
      _backend.write(_key, _encodeJson(_toJson(value)));
    } catch (_) {
      // Backend write failure (quota / disabled) — swallow; local subscribers
      // are still notified so the UI stays consistent within this instance.
    }
    _notify(value);
  }

  /// Subscribe to value changes. Returns a disposer.
  void Function() subscribe(BcLocalStorageListener<T> listener) {
    _listeners.add(listener);
    return () {
      _listeners.remove(listener);
    };
  }

  /// Detach listeners. Idempotent.
  void dispose() {
    _disposed = true;
    _listeners.clear();
  }

  void _notify(T value) {
    if (_listeners.isEmpty) return;
    for (final cb in List<BcLocalStorageListener<T>>.from(_listeners)) {
      cb(value);
    }
  }

  String _encodeJson(Object value) => jsonEncode(value);

  Object? _decodeJson(String raw) => jsonDecode(raw);
}

/// Functional factory mirroring `createLocalStorage<T>(key, defaultValue)`.
BcLocalStorageStore<T> createLocalStorage<T>({
  required String key,
  required T defaultValue,
  required T Function(Object? json) fromJson,
  required Object Function(T value) toJson,
  BcStorageBackend? backend,
}) =>
    BcLocalStorageStore<T>(
      key: key,
      defaultValue: defaultValue,
      fromJson: fromJson,
      toJson: toJson,
      backend: backend,
    );
