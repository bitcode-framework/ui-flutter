// ============================================================================
// BcScrollLock — Dart port of the TS `useScrollLock`/`createScrollLock` hook
// (packages/ui/src/core/hooks/use-scroll-lock.ts, ADR-013 §3).
//
// Headless ref-counted scroll-lock controller. Mirrors the TS contract
// surface (`locked`, `lock`, `unlock`, `dispose`) so the two tiers stay in
// API parity.
//
// Flutter parity note: Flutter has no `document.body`/DOM `overflow` style.
// Scroll-locking on Flutter is achieved by swapping the host scrollable's
// `ScrollPhysics` to `NeverScrollableScrollPhysics` while `locked` is true.
// This controller therefore exposes a [locked] notifier (and a [notifier]
// for reactive rebuilds) that host widgets consult; it does NOT mutate any
// global DOM state. The ref-counting semantics (nested locks compose, only
// the final `unlock` clears the lock) are preserved exactly.
// ============================================================================

import 'package:flutter/foundation.dart';

/// Ref-counted scroll-lock controller. Mirrors the TS `ScrollLock`.
///
/// Host usage (typical overlay):
/// ```dart
/// final lock = BcScrollLock();
/// lock.lock();   // on open
/// // ...
/// lock.unlock(); // on close
/// ```
///
/// Reactive host widgets can listen to [notifier] to rebuild when the lock
/// flips, then choose `NeverScrollableScrollPhysics` vs the default physics.
class BcScrollLock {
  int _count = 0;
  bool _disposed = false;

  /// Notifier that flips when the lock transitions between locked/unlocked.
  /// Host widgets can `listen` to this (or `ValueListenableBuilder` over
  /// [notifier]) to rebuild their `ScrollPhysics`.
  final ValueNotifier<bool> _notifier = ValueNotifier<bool>(false);

  /// `true` while the lock is active (ref count > 0).
  bool get locked => _count > 0;

  /// Reactive handle for the locked state. Host widgets can build off this.
  ValueListenable<bool> get notifier => _notifier;

  /// Acquire a scroll lock. Idempotent: nested calls increment a ref count.
  void lock() {
    if (_disposed) return;
    final wasLocked = locked;
    _count += 1;
    if (!wasLocked && locked) _notifier.value = true;
  }

  /// Release one lock reference. Only clears when the ref count drops to
  /// zero. Idempotent: extra `unlock()` calls are safe no-ops.
  void unlock() {
    if (_count <= 0) return;
    final wasLocked = locked;
    _count -= 1;
    if (wasLocked && !locked) _notifier.value = false;
  }

  /// Force-release all references.
  void dispose() {
    _disposed = true;
    _count = 0;
    _notifier.value = false;
    _notifier.dispose();
  }
}

/// Functional factory mirroring `createScrollLock(options)`.
BcScrollLock createScrollLock() => BcScrollLock();
