/// ReactiveStoreNotifier — thin Flutter adapter for [ReactiveStore]
/// (ADR-011 Section 4 Layer 2).
///
/// Bridges pure-Dart reactive store subscriptions to Flutter's
/// ChangeNotifier. This is the ONLY Flutter-importing piece of the reactive
/// engine; all business logic stays in pure Dart [ReactiveStore].

library reactive_store_notifier;

import 'package:flutter/foundation.dart';
import 'reactive_store.dart';

class ReactiveStoreNotifier extends ChangeNotifier {
  final ReactiveStore store;
  final bool Function()? _shouldNotify;

  ReactiveStoreNotifier(
    this.store, {
    this._shouldNotify,
  }) {
    store.subscribe(_onStoreChange);
  }

  void _onStoreChange(Map<String, dynamic> snapshot) {
    if (_shouldNotify != null && !_shouldNotify()) return;
    notifyListeners();
  }

  /// Convenience: set a value in the wrapped store.
  void set(String path, dynamic value) {
    store.set(path, value);
  }

  /// Convenience: get a value from the wrapped store.
  dynamic get(String path) => store.get(path);

  @override
  void dispose() {
    store.unsubscribe(_onStoreChange);
    super.dispose();
  }
}
