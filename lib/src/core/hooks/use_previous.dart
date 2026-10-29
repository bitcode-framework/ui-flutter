// ============================================================================
// PreviousValue — track the previous value across updates (ADR-013 §3).
//
// Pure Dart port of the TS `PreviousValue` / `usePrevious`
// (packages/ui/src/core/hooks/use-previous.ts). Plain class, no Flutter/DOM
// dependency — testable in isolation. The host keeps an instance and calls
// `update(next)` on every value change; reads go through `previous`.
//
// Parity surface (A044):
//   - `previous`  → value before the most recent `update`.
//   - `value`     → most recent value passed to `update` (or initial).
//   - `hasValue`  → true once at least one value has been seen.
//   - `update()`  → record a new value; prior `current` becomes `previous`.
//   - `reset()`   → pristine state.
// ============================================================================

/// Tracks the previous value of a changing input.
///
/// On construction `previous` is `null` (nothing seen yet) unless an initial
/// value is supplied. After the first `update(next)`, `value` holds `next`
/// and `previous` holds the value passed to the preceding `update` call (or
/// `null`/the initial value if this is the first).
class PreviousValue<T> {
  T? _current;
  T? _previous;
  bool _hasValue;

  /// Construct with an optional initial value. When [initial] is omitted the
  /// tracker starts with no value (`hasValue === false`).
  PreviousValue([T? initial])
      : _current = initial,
        _previous = null,
        _hasValue = identical(initial, null) ? false : true;

  /// The value before the most recent `update`. `null` until 2+ updates (or
  /// until the first `update` when no initial value was supplied).
  T? get previous => _previous;

  /// The most recent value passed to `update` (or the initial value).
  T? get value => _current;

  /// True once at least one value has been seen (via constructor or update).
  bool get hasValue => _hasValue;

  /// Record a new value. The prior `current` becomes `previous`.
  void update(T next) {
    _previous = _current;
    _current = next;
    _hasValue = true;
  }

  /// Reset to a pristine state (no previous, no current).
  void reset() {
    _current = null;
    _previous = null;
    _hasValue = false;
  }
}
