/// useTimeout — one-shot timer controller (ADR-013 §3, P1 hook).
///
/// Dart port of the TS `createTimeout` (packages/ui/src/core/hooks/use-timeout.ts).
/// Uses [Timer] for the one-shot callback. Headless: no widget/Dart-UI deps,
/// so it runs in pure `dart test` without a Flutter binding.
///
/// Parity surface with the TS `TimeoutController`:
///   - `start()` — schedule the one-shot timer (cancels any running first).
///   - `clear()` — cancel the pending timer (no-op when not running).
///   - `scheduled` — whether a timer is currently pending.
///   - `dispose()` — cancel + drop the callback reference. Idempotent.
library use_timeout;

import 'dart:async';

/// Controller returned by [createTimeout].
class BcTimeoutController {
  final void Function() _callback;
  final Duration _delay;
  Timer? _timer;
  bool _disposed = false;

  BcTimeoutController(this._callback, this._delay);

  /// Whether a one-shot timer is currently scheduled.
  bool get scheduled => _timer != null && _timer!.isActive;

  /// Start the one-shot timer. Cancels any running timer first.
  /// No-op after [dispose].
  void start() {
    if (_disposed) return;
    clear();
    _timer = Timer(_delay, () {
      _timer = null;
      _callback();
    });
  }

  /// Cancel the pending timer (if any). No-op when not running.
  void clear() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancel + mark disposed; further `start()` calls are ignored.
  void dispose() {
    clear();
    _disposed = true;
  }
}

/// Create a one-shot timeout controller.
///
/// [callback] is invoked once after [delay] when [BcTimeoutController.start]
/// is called. Mirrors the TS `createTimeout(callback, delay)`.
BcTimeoutController createTimeout(void Function() callback, Duration delay) {
  return BcTimeoutController(callback, delay);
}
