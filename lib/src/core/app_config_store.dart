/// AppConfigStore — pure Dart port of the TS `AppConfigStore`
/// (packages/ui/src/core/providers/config-store.ts).
///
/// Headless per-instance config store backing `BcAppConfig` (ADR-013 Phase 1).
/// Mirrors the TS design (ADR-002 §9.1): plain class, no globals, no Flutter
/// imports — testable via `dart test` without a Flutter binding. The host
/// (`BcAppConfig` InheritedWidget / `BcApp`) is responsible for translating
/// snapshot changes into platform-specific side effects (MaterialApp theme
/// switch, `Directionality` widget, etc.).
///
/// Parity surface (A005):
///   - `getSnapshot()` → immutable `AppConfigSnapshot`
///   - `setTheme`, `setLocale`, `setDirection`, `setSize`, `setDateLocale`,
///     `setMessageQueue` — imperative mutators
///   - `subscribe(listener)` → disposer; fires only on snapshot changes
///   - `dispose()` → drops listeners and freezes mutations
///   - `isDisposed()`
///
/// SSR-safety (mirrors TS): the store performs no platform I/O. `theme:
/// system` is reported as-is; resolving `system` against the host platform
/// is the host's job (it calls `applyResolvedTheme` / `setTheme` back).
library app_config_store;

import 'bc_i18n.dart';

import 'app_config_snapshot.dart';

/// Listener signature. Receives the new immutable snapshot.
typedef AppConfigListener = void Function(AppConfigSnapshot snapshot);

/// Disposable returned by [AppConfigStore.subscribe].
typedef AppConfigDisposable = void Function();

/// Headless config store. One instance per `BcAppConfig` provider.
class AppConfigStore {
  AppThemeMode _theme;
  ResolvedAppTheme _resolvedTheme;
  String _locale;
  AppDirection _direction;
  AppSize _size;
  String? _dateLocale;
  AppMessageQueue? _messageQueue;

  final Set<AppConfigListener> _listeners = {};
  bool _disposed = false;

  AppConfigStore({AppConfigInit init = const AppConfigInit()})
      : _theme = init.theme ?? AppThemeMode.system,
        _resolvedTheme = _resolveInitialTheme(init.theme ?? AppThemeMode.system),
        _locale = init.locale ?? 'en',
        _direction = init.direction ?? AppDirection.auto,
        _size = init.size ?? AppSize.md,
        _dateLocale = init.dateLocale,
        _messageQueue = init.messageQueue;

  static ResolvedAppTheme _resolveInitialTheme(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.dark:
        return ResolvedAppTheme.dark;
      case AppThemeMode.light:
        return ResolvedAppTheme.light;
      case AppThemeMode.system:
        return ResolvedAppTheme.light;
    }
  }

  // -- Reads -----------------------------------------------------------------

  /// Current immutable snapshot. Plain data — safe to cache / compare.
  AppConfigSnapshot getSnapshot() => AppConfigSnapshot(
        theme: _theme,
        resolvedTheme: _resolvedTheme,
        locale: _locale,
        direction: _direction,
        resolvedDirection: resolveDirection(_direction, _locale),
        size: _size,
        dateLocale: _dateLocale ?? _locale,
      );

  ResolvedAppTheme get resolvedTheme => _resolvedTheme;

  AppMessageQueue? get messageQueue => _messageQueue;

  // -- Writes ----------------------------------------------------------------

  /// Update theme intent. Resolved value is recomputed only for explicit
  /// `light` / `dark`. For `system`, the host must feed the resolved value
  /// back via [applyResolvedTheme] (mirrors the TS watcher contract).
  void setTheme(AppThemeMode theme) {
    if (_disposed) return;
    if (_theme == theme) return;
    _theme = theme;
    switch (theme) {
      case AppThemeMode.dark:
        _resolvedTheme = ResolvedAppTheme.dark;
        break;
      case AppThemeMode.light:
        _resolvedTheme = ResolvedAppTheme.light;
        break;
      case AppThemeMode.system:
        // Keep the previous resolved value; host resolves via watcher.
        break;
    }
    _notify();
  }

  /// Apply a resolved theme coming from the host platform watcher (e.g. the
  /// OS dark-mode setting). No-op for `system`-agnostic hosts.
  void applyResolvedTheme(ResolvedAppTheme resolved) {
    if (_disposed) return;
    if (_resolvedTheme == resolved) return;
    _resolvedTheme = resolved;
    _notify();
  }

  void setLocale(String locale) {
    if (_disposed) return;
    if (_locale == locale) return;
    _locale = locale;
    // Sync the global i18n instance so component strings update reactively.
    bcI18n.setLocale(locale);
    _notify();
  }

  void setDirection(AppDirection direction) {
    if (_disposed) return;
    if (_direction == direction) return;
    _direction = direction;
    _notify();
  }

  void setSize(AppSize size) {
    if (_disposed) return;
    if (_size == size) return;
    _size = size;
    _notify();
  }

  void setDateLocale(String? dateLocale) {
    if (_disposed) return;
    if (_dateLocale == dateLocale) return;
    _dateLocale = dateLocale;
    _notify();
  }

  /// Adapter swap does not change any snapshot field — no notify (parity
  /// with TS `setMessageQueue`).
  void setMessageQueue(AppMessageQueue? adapter) {
    if (_disposed) return;
    _messageQueue = adapter;
  }

  // -- Subscription ----------------------------------------------------------

  /// Subscribe to snapshot changes. Returns a disposer. Re-entrant
  /// unsubscribes during dispatch are safe (listeners are iterated over a
  /// snapshot copy).
  AppConfigDisposable subscribe(AppConfigListener listener) {
    _listeners.add(listener);
    return () {
      _listeners.remove(listener);
    };
  }

  /// Drop all listeners and prevent further mutations.
  void dispose() {
    _disposed = true;
    _listeners.clear();
  }

  bool isDisposed() => _disposed;

  void _notify() {
    if (_listeners.isEmpty) return;
    final snap = getSnapshot();
    final cbs = List<AppConfigListener>.from(_listeners);
    for (final cb in cbs) {
      cb(snap);
    }
  }
}
