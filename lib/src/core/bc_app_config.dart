/// BcAppConfig — InheritedWidget exposing AppConfigSnapshot to descendants.
///
/// Flutter parity for the TS `BcAppContext` (ADR-002 §9.1, ADR-013 Phase 1).
/// Where Mitosis uses `useContext(BcAppContext)` to read the config snapshot,
/// Flutter descendants call `BcAppConfig.of(context)` (or
/// `BcAppConfig.maybeOf(context)`).
///
/// This widget is a thin propagation shell: it holds the current snapshot
/// (read from an [AppConfigStore]) and notifies dependents when the snapshot
/// changes. All mutable state lives in the headless [AppConfigStore]; the
/// host (typically [BcApp]) owns the store, subscribes to it, and rebuilds
/// this widget with the latest snapshot.
///
/// Usage:
/// ```dart
/// BcAppConfig(
///   snapshot: store.getSnapshot(),
///   store: store,
///   child: MyScreen(),
/// );
/// ```
///
/// Descendant read:
/// ```dart
/// final snap = BcAppConfig.of(context).snapshot;
/// final store = BcAppConfig.of(context).store; // imperative updates
/// ```

library bc_app_config;

import 'package:flutter/widgets.dart';

import 'app_config_snapshot.dart';
import 'app_config_store.dart';

/// Data carried by [BcAppConfig] down the tree.
@immutable
class BcAppConfigData {
  /// Current resolved config snapshot (plain data — safe to serialize).
  final AppConfigSnapshot snapshot;

  /// Live store handle for imperative updates
  /// (`setTheme`, `setLocale`, …). May be `null` when the host only wants to
  /// propagate a snapshot without exposing mutation (e.g. a read-only preview).
  final AppConfigStore? store;

  const BcAppConfigData({required this.snapshot, this.store});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BcAppConfigData &&
          other.snapshot == snapshot &&
          identical(other.store, store));

  @override
  int get hashCode => Object.hash(snapshot, store);
}

/// The default data returned by [BcAppConfig.of] when no [BcAppConfig]
/// ancestor is present (SSR-like / unmounted case). Mirrors the TS
/// `BcAppContext` default snapshot.
const BcAppConfigData _kDefaultData = BcAppConfigData(
  snapshot: AppConfigSnapshot.defaultSnapshot,
  store: null,
);

/// InheritedWidget that exposes [BcAppConfigData] (snapshot + store) to
/// descendants, mirroring the TS `BcAppContext`.
///
/// The primary constructor takes the [snapshot] and optional [store] directly
/// — the common host case (e.g. [BcApp]) already holds both. Use
/// [BcAppConfig.data] to build from an existing [BcAppConfigData].
class BcAppConfig extends InheritedWidget {
  /// Current resolved config snapshot propagated to descendants.
  final AppConfigSnapshot snapshot;

  /// Live store handle for imperative updates. May be `null` for read-only
  /// propagation (snapshot without mutation surface).
  final AppConfigStore? store;

  const BcAppConfig({
    super.key,
    required this.snapshot,
    this.store,
    required super.child,
  });

  /// Build from an existing [BcAppConfigData] (e.g. when forwarding data
  /// received from an ancestor without unpacking it).
  ///
  /// Non-`const` because [AppConfigStore] is a mutable, non-const class:
  /// `data.store` cannot be a compile-time constant, so the constructor
  /// cannot be `const`. The primary [BcAppConfig] constructor remains `const`.
  BcAppConfig.data({
    super.key,
    required BcAppConfigData data,
    required super.child,
  })  : snapshot = data.snapshot,
        store = data.store;

  /// Convenience accessor bundling the propagated fields into an immutable
  /// [BcAppConfigData]. Returned by [of] / [maybeOf] so consumers receive a
  /// single value-typed object.
  BcAppConfigData get data => BcAppConfigData(snapshot: snapshot, store: store);

  /// Read the nearest [BcAppConfigData]. Returns the default (defaults
  /// snapshot, `null` store) when no [BcAppConfig] ancestor is mounted —
  /// parity with the TS SSR-safe `useAppContext()` fallback.
  static BcAppConfigData of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<BcAppConfig>();
    return widget?.data ?? _kDefaultData;
  }

  /// Like [of] but returns `null` when no [BcAppConfig] ancestor is present,
  /// for callers that need to distinguish "no provider" from "default".
  static BcAppConfigData? maybeOf(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<BcAppConfig>();
    return widget?.data;
  }

  @override
  bool updateShouldNotify(BcAppConfig oldWidget) {
    // Rebuild dependents only when the propagated data actually changes.
    // `BcAppConfigData.==` compares the snapshot structurally and the store
    // by identity — so a new snapshot with equal fields won't trigger a
    // spurious rebuild, and a store swap (same snapshot) won't either.
    return data != oldWidget.data;
  }
}
