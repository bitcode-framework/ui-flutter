// ============================================================================
// BcIntervalController — Dart port of the TS `useInterval`/`createInterval`
// hook (packages/ui/src/core/hooks/use-interval.ts, ADR-013 §3).
//
// Headless recurring-timer controller. The host widget owns an instance and
// calls `start()` to begin ticking and `stop()`/`dispose()` to tear down.
// The callback fires on each tick.
//
// Flutter parity: uses `Timer.periodic` (dart:async) instead of
// `setInterval`. `dart:async` Timer is available in every Dart runtime (VM,
// web, AOT) — there is no SSR/no-window path to guard, so unlike the TS hook
// this port always schedules a real timer once `start()` is called. The
// `Timer` factory is injectable (`createTimer`) so tests can drive
// deterministic ticks with a fake clock (e.g. `FakeAsync`).
// ============================================================================

import 'dart:async';

/// Injectable timer factory signature. Defaults to `Timer.periodic`.
/// Tests pass a fake to drive deterministic ticks.
typedef BcIntervalTimerFactory = Timer Function(
  Duration duration,
  void Function(Timer timer) callback,
);

/// Recurring-timer controller. Mirrors the TS `IntervalController`.
class BcIntervalController {
  final void Function() _callback;
  final Duration _delay;
  final BcIntervalTimerFactory _createTimer;

  Timer? _timer;
  bool _active = false;
  bool _disposed = false;

  /// Create a recurring-timer controller.
  ///
  /// - [callback] invoked on each tick.
  /// - [delay] time between ticks. Must be >= 0.
  /// - [createTimer] optional timer factory (defaults to `Timer.periodic`).
  BcIntervalController({
    required void Function() callback,
    required Duration delay,
    BcIntervalTimerFactory? createTimer,
  })  : _callback = callback,
        _delay = delay,
        _createTimer = createTimer ?? _defaultTimerFactory;

  static Timer _defaultTimerFactory(
          Duration duration, void Function(Timer timer) callback) =>
      Timer.periodic(duration, callback);

  /// `true` while a tick is scheduled.
  bool get active => _active;

  /// Begin recurring execution of `callback` every `delay`. No-op if active.
  void start() {
    if (_disposed || _active) return;
    _active = true;
    _timer = _createTimer(_delay, (_) => _callback());
  }

  /// Cancel the pending tick. Idempotent. Keeps `delay`/`callback` for restart.
  void stop() {
    if (!_active) return;
    _active = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Cancel and mark disposed; further `start()` calls are ignored.
  void dispose() {
    stop();
    _disposed = true;
  }
}

/// Functional factory mirroring `createInterval(callback, delayMs, options)`.
///
/// [delay] is a [Duration] (the TS API takes milliseconds; Dart prefers
/// [Duration] for idiomatic parity with `Timer.periodic`).
BcIntervalController createInterval({
  required void Function() callback,
  required Duration delay,
  BcIntervalTimerFactory? createTimer,
}) =>
    BcIntervalController(
      callback: callback,
      delay: delay,
      createTimer: createTimer,
    );
