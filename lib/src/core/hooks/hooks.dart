// ============================================================================
// core/hooks — Flutter parity barrel for the P1 portable hook subset
// (ADR-013 §3, Phase 5b).
//
// Mirrors `packages/ui/src/core/hooks/index.ts`. All exports are headless
// utility classes / pure factories — no widget deps — so they can run in
// `flutter test` (and `dart test` for the pure-logic ones) without a Flutter
// binding. Browser-only APIs (IntersectionObserver, document listeners,
// localStorage, body overflow) are replaced with Flutter-idiomatic
// equivalents (Timers, ValueNotifiers, injectable adapters) and documented
// per-symbol in each file.
// ============================================================================

export 'use_previous.dart';
export 'use_interval.dart';
export 'use_timeout.dart';
export 'use_scroll_lock.dart';
export 'use_local_storage.dart';
