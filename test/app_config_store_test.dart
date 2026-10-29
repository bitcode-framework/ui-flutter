// AppConfigStore tests — parity with TS AppConfigStore (ADR-013 Phase 1).
//
// Verifies: defaults, setTheme resolves, subscribe fires on change only,
// dispose freezes mutations, setDirection auto-resolves from locale,
// dateLocale falls back to locale.
//
// Pure Dart logic (no Flutter binding required) but uses flutter_test for
// consistency with the rest of the suite.

import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/app_config_store.dart';
import 'package:bc_ui_flutter/src/core/app_config_snapshot.dart';

void main() {
  group('AppConfigStore — defaults', () {
    test('getSnapshot returns sane defaults matching TS', () {
      final store = AppConfigStore();
      final snap = store.getSnapshot();
      expect(snap.theme, AppThemeMode.system);
      expect(snap.resolvedTheme, ResolvedAppTheme.light);
      expect(snap.locale, 'en');
      expect(snap.direction, AppDirection.auto);
      expect(snap.resolvedDirection, ResolvedAppDirection.ltr);
      expect(snap.size, AppSize.md);
      expect(snap.dateLocale, 'en');
    });

    test('constructor accepts init overrides', () {
      final store = AppConfigStore(init: const AppConfigInit(
        theme: AppThemeMode.dark,
        locale: 'id',
        direction: AppDirection.rtl,
        size: AppSize.lg,
        dateLocale: 'id-ID',
      ));
      final snap = store.getSnapshot();
      expect(snap.theme, AppThemeMode.dark);
      expect(snap.resolvedTheme, ResolvedAppTheme.dark);
      expect(snap.locale, 'id');
      expect(snap.direction, AppDirection.rtl);
      expect(snap.resolvedDirection, ResolvedAppDirection.rtl);
      expect(snap.size, AppSize.lg);
      expect(snap.dateLocale, 'id-ID');
    });
  });

  group('AppConfigStore — setTheme resolves', () {
    test('setTheme(dark) updates resolvedTheme immediately', () {
      final store = AppConfigStore();
      store.setTheme(AppThemeMode.dark);
      expect(store.getSnapshot().resolvedTheme, ResolvedAppTheme.dark);
      store.setTheme(AppThemeMode.light);
      expect(store.getSnapshot().resolvedTheme, ResolvedAppTheme.light);
    });

    test('setTheme(system) keeps prior resolvedTheme; applyResolvedTheme mutates', () {
      final store = AppConfigStore(init: const AppConfigInit(theme: AppThemeMode.light));
      store.setTheme(AppThemeMode.system);
      // 'system' alone keeps the prior resolved value until the host watcher feeds in.
      expect(store.getSnapshot().resolvedTheme, ResolvedAppTheme.light);
      store.applyResolvedTheme(ResolvedAppTheme.dark);
      expect(store.getSnapshot().resolvedTheme, ResolvedAppTheme.dark);
    });
  });

  group('AppConfigStore — subscribe', () {
    test('subscribe fires on changes only, with disposer', () {
      final store = AppConfigStore();
      var calls = 0;
      final off = store.subscribe((_) => calls++);
      store.setTheme(AppThemeMode.dark); // 1
      store.setTheme(AppThemeMode.dark); // no-op (same value)
      store.setLocale('id'); // 2
      off();
      store.setLocale('fr'); // not delivered (unsubscribed)
      expect(calls, 2);
    });
  });

  group('AppConfigStore — dispose', () {
    test('dispose drops listeners and freezes mutations', () {
      final store = AppConfigStore();
      var calls = 0;
      store.subscribe((_) => calls++);
      store.dispose();
      store.setTheme(AppThemeMode.dark);
      expect(calls, 0);
      expect(store.isDisposed(), true);
    });
  });

  group('AppConfigStore — direction', () {
    test('setLocale updates resolvedDirection through getSnapshot (auto)', () {
      final store = AppConfigStore(init: const AppConfigInit(locale: 'en'));
      expect(store.getSnapshot().resolvedDirection, ResolvedAppDirection.ltr);
      store.setLocale('ar');
      expect(store.getSnapshot().resolvedDirection, ResolvedAppDirection.rtl,
          reason: 'auto picks rtl from locale');
      store.setDirection(AppDirection.ltr);
      expect(store.getSnapshot().resolvedDirection, ResolvedAppDirection.ltr,
          reason: 'explicit overrides locale');
    });
  });

  group('AppConfigStore — dateLocale', () {
    test('dateLocale falls back to locale when null', () {
      final store = AppConfigStore(init: const AppConfigInit(locale: 'id'));
      expect(store.getSnapshot().dateLocale, 'id');
      store.setDateLocale('id-ID');
      expect(store.getSnapshot().dateLocale, 'id-ID');
      store.setDateLocale(null);
      expect(store.getSnapshot().dateLocale, 'id');
    });
  });
}
