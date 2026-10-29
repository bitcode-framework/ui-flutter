// Hooks P1 parity tests — Dart ports of the TS P1 hooks (ADR-013 §3/Phase 5b).
//
// Verifies the Flutter parity surface for: PreviousValue, BcIntervalController,
// BcTimeoutController, BcScrollLock, BcLocalStorageStore. These mirror the TS
// `use-previous`, `use-interval`, `use-timeout`, `use-scroll-lock`, and
// `use-local-storage` hooks respectively.
//
// Uses `flutter_test` (consistent with the rest of the suite) and `FakeAsync`
// to drive deterministic timers for the interval/timeout controllers.

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('PreviousValue — usePrevious parity', () {
    test('starts with no value', () {
      final p = PreviousValue<int>();
      expect(p.hasValue, isFalse);
      expect(p.value, isNull);
      expect(p.previous, isNull);
    });

    test('accepts an initial value', () {
      final p = PreviousValue<int>(1);
      expect(p.hasValue, isTrue);
      expect(p.value, 1);
      expect(p.previous, isNull);
    });

    test('update shifts current→previous', () {
      final p = PreviousValue<int>();
      p.update(1);
      expect(p.value, 1);
      expect(p.previous, isNull);
      p.update(2);
      expect(p.value, 2);
      expect(p.previous, 1);
      p.update(3);
      expect(p.value, 3);
      expect(p.previous, 2);
    });

    test('reset clears state', () {
      final p = PreviousValue<int>(1);
      p.update(2);
      p.reset();
      expect(p.hasValue, isFalse);
      expect(p.value, isNull);
      expect(p.previous, isNull);
    });
  });

  group('BcIntervalController — useInterval parity', () {
    test('start/stop/dispose lifecycle', () {
      var ticks = 0;
      final c = BcIntervalController(
        callback: () => ticks++,
        delay: const Duration(milliseconds: 10),
      );
      expect(c.active, isFalse);
      c.start();
      expect(c.active, isTrue);
      c.stop();
      expect(c.active, isFalse);
      c.dispose();
      // start after dispose is a no-op
      c.start();
      expect(c.active, isFalse);
    });

    test('start is idempotent (no double-timer)', () {
      var ticks = 0;
      final c = BcIntervalController(
        callback: () => ticks++,
        delay: const Duration(milliseconds: 5),
        createTimer: (d, cb) {
          // fake timer that never auto-fires; just counts factory calls
          ticks = ticks + 100; // marker: factory invoked
          return Timer(d, () {}); // one-shot stub, not periodic
        },
      );
      c.start();
      c.start(); // second start should be a no-op
      expect(ticks, 100, reason: 'factory invoked exactly once');
      c.dispose();
    });

    test('fires callback on each tick via FakeAsync', () {
      FakeAsync().run((async) {
        var ticks = 0;
        final c = BcIntervalController(
          callback: () => ticks++,
          delay: const Duration(milliseconds: 50),
        );
        c.start();
        async.elapse(const Duration(milliseconds: 150));
        expect(ticks, 3, reason: '3 ticks at 50ms intervals over 150ms');
        c.dispose();
      });
    });

    test('stop cancels pending ticks', () {
      FakeAsync().run((async) {
        var ticks = 0;
        final c = BcIntervalController(
          callback: () => ticks++,
          delay: const Duration(milliseconds: 50),
        );
        c.start();
        async.elapse(const Duration(milliseconds: 50));
        expect(ticks, 1);
        c.stop();
        async.elapse(const Duration(milliseconds: 200));
        expect(ticks, 1, reason: 'no more ticks after stop');
      });
    });

    test('createInterval factory builds a controller', () {
      final c = createInterval(
        callback: () {},
        delay: const Duration(milliseconds: 10),
      );
      expect(c, isA<BcIntervalController>());
      c.dispose();
    });
  });

  group('BcTimeoutController — useTimeout parity', () {
    test('start/clear/dispose lifecycle', () {
      var fired = 0;
      final t = BcTimeoutController(
        () => fired++,
        const Duration(milliseconds: 10),
      );
      expect(t.scheduled, isFalse);
      t.start();
      expect(t.scheduled, isTrue);
      t.clear();
      expect(t.scheduled, isFalse);
      t.dispose();
    });

    test('fires once after delay via FakeAsync', () {
      FakeAsync().run((async) {
        var fired = 0;
        final t = BcTimeoutController(
          () => fired++,
          const Duration(milliseconds: 50),
        );
        t.start();
        async.elapse(const Duration(milliseconds: 40));
        expect(fired, 0);
        async.elapse(const Duration(milliseconds: 10));
        expect(fired, 1, reason: 'fires exactly once');
        expect(t.scheduled, isFalse, reason: 'auto-clears after firing');
        // further elapse does not re-fire
        async.elapse(const Duration(milliseconds: 100));
        expect(fired, 1);
      });
    });

    test('start cancels prior pending timer', () {
      FakeAsync().run((async) {
        var fired = 0;
        final t = BcTimeoutController(() => fired++,
            const Duration(milliseconds: 50));
        t.start();
        t.start(); // restart before firing
        async.elapse(const Duration(milliseconds: 50));
        expect(fired, 1, reason: 'only one fire despite double start');
      });
    });

    test('clear prevents callback', () {
      FakeAsync().run((async) {
        var fired = 0;
        final t = BcTimeoutController(
          () => fired++,
          const Duration(milliseconds: 50),
        );
        t.start();
        t.clear();
        async.elapse(const Duration(milliseconds: 100));
        expect(fired, 0);
      });
    });

    test('createTimeout factory builds a controller', () {
      final t = createTimeout(() {}, const Duration(milliseconds: 10));
      expect(t, isA<BcTimeoutController>());
      t.dispose();
    });
  });

  group('BcScrollLock — useScrollLock parity', () {
    test('lock/unlock ref-counted', () {
      final lock = BcScrollLock();
      expect(lock.locked, isFalse);
      lock.lock();
      expect(lock.locked, isTrue);
      lock.lock(); // nested
      expect(lock.locked, isTrue);
      lock.unlock(); // still one ref
      expect(lock.locked, isTrue);
      lock.unlock(); // ref count → 0
      expect(lock.locked, isFalse);
      lock.dispose();
    });

    test('extra unlock is a safe no-op', () {
      final lock = BcScrollLock();
      lock.unlock(); // no prior lock
      expect(lock.locked, isFalse);
      lock.lock();
      lock.unlock();
      lock.unlock(); // extra
      expect(lock.locked, isFalse);
      lock.dispose();
    });

    test('notifier flips on transitions', () {
      final lock = BcScrollLock();
      final transitions = <bool>[];
      lock.notifier.addListener(() => transitions.add(lock.notifier.value));
      expect(lock.notifier.value, isFalse);
      lock.lock();
      expect(transitions, [true]);
      lock.unlock();
      expect(transitions, [true, false]);
      lock.dispose();
    });

    test('createScrollLock factory', () {
      final lock = createScrollLock();
      expect(lock, isA<BcScrollLock>());
      lock.dispose();
    });
  });

  group('BcLocalStorageStore — useLocalStorage parity', () {
    test('returns default when key absent (in-memory backend)', () {
      final store = BcLocalStorageStore<int>(
        key: 'count',
        defaultValue: 0,
        fromJson: (j) => j as int,
        toJson: (v) => v,
      );
      expect(store.get(), 0);
      store.dispose();
    });

    test('set persists and get round-trips (in-memory backend)', () {
      final store = BcLocalStorageStore<int>(
        key: 'count',
        defaultValue: 0,
        fromJson: (j) => j as int,
        toJson: (v) => v,
      );
      store.set(42);
      expect(store.get(), 42);
      store.set(7);
      expect(store.get(), 7);
      store.dispose();
    });

    test('subscribe fires on set', () {
      final store = BcLocalStorageStore<String>(
        key: 'name',
        defaultValue: 'anonymous',
        fromJson: (j) => j as String,
        toJson: (v) => v,
      );
      final seen = <String>[];
      final dispose = store.subscribe((v) => seen.add(v));
      store.set('alice');
      store.set('bob');
      expect(seen, ['alice', 'bob']);
      dispose();
      store.set('carol');
      expect(seen, ['alice', 'bob'], reason: 'no fire after unsubscribe');
      store.dispose();
    });

    test('malformed JSON in backend returns default (never throws)', () {
      final backend = BcMemoryStorageBackend();
      backend.write('broken', '{not json');
      final store = BcLocalStorageStore<int>(
        key: 'broken',
        defaultValue: 99,
        fromJson: (j) => j as int,
        toJson: (v) => v,
        backend: backend,
      );
      expect(store.get(), 99, reason: 'malformed JSON treated as absent');
      store.dispose();
    });

    test('custom backend (cross-instance persistence simulation)', () {
      final shared = BcMemoryStorageBackend();
      final a = BcLocalStorageStore<int>(
        key: 'k',
        defaultValue: 0,
        fromJson: (j) => j as int,
        toJson: (v) => v,
        backend: shared,
      );
      a.set(5);
      a.dispose();
      // new store over the same backend sees the persisted value
      final b = BcLocalStorageStore<int>(
        key: 'k',
        defaultValue: 0,
        fromJson: (j) => j as int,
        toJson: (v) => v,
        backend: shared,
      );
      expect(b.get(), 5);
      b.dispose();
    });

    test('dispose freezes further set', () {
      final store = BcLocalStorageStore<int>(
        key: 'k',
        defaultValue: 0,
        fromJson: (j) => j as int,
        toJson: (v) => v,
      );
      store.dispose();
      store.set(1); // no-op, must not throw
      expect(store.get(), 0);
    });

    test('createLocalStorage factory builds a store', () {
      final store = createLocalStorage<int>(
        key: 'k',
        defaultValue: 0,
        fromJson: (j) => j as int,
        toJson: (v) => v,
      );
      expect(store, isA<BcLocalStorageStore<int>>());
      store.dispose();
    });
  });
}
