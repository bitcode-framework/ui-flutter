/// BcApp — root PlatformApp wrapper (ADR-011 Section 3).
///
/// FPW (flutter_platform_widgets) provides [PlatformApp] which auto-selects
/// Material (Android) or Cupertino (iOS/macOS) at runtime based on
/// [PlatformProvider]. BcApp adds BcTheme defaults on top.
///
/// ADR-013 Phase 1: BcApp also hosts an [AppConfigStore] and exposes the
/// current [AppConfigSnapshot] to descendants via a [BcAppConfig]
/// [InheritedWidget] (parity with the TS `BcAppProvider`). Descendant
/// widgets read config via `BcAppConfig.of(context)`. When the snapshot
/// changes, BcApp rebuilds the InheritedWidget so dependents update.
///
/// Usage:
/// ```dart
/// void main() => runApp(
///   PlatformProvider(
///     settings: PlatformSettingsData(iosUsesMaterialWidgets: true),
///     child: BcApp(home: MyScreen()),
///   ),
/// );
/// ```
///
/// With an explicit store (imperative updates from anywhere):
/// ```dart
/// final store = AppConfigStore(AppConfigInit(theme: AppThemeMode.dark));
/// runApp(BcApp(home: MyScreen(), appConfigStore: store));
/// // later: store.setTheme(AppThemeMode.light);
/// ```

library bc_app;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'theme/bc_theme.dart';
import 'core/app_config_store.dart';
import 'core/app_config_snapshot.dart';
import 'core/bc_app_config.dart';

/// Variant override. Defaults to adaptive (platform decides).
enum BcPlatformVariant { adaptive, material, cupertino }

class BcApp extends StatefulWidget {
  final Widget home;
  final BcPlatformVariant variant;
  final String title;
  final bool debugShowCheckedModeBanner;

  /// Optional pre-built config store. When `null`, BcApp creates and owns a
  /// default store (disposed on unmount). When supplied, the caller owns the
  /// store's lifecycle — BcApp will NOT dispose it.
  final AppConfigStore? appConfigStore;

  /// Optional initial config. Ignored when [appConfigStore] is supplied.
  final AppConfigInit? appConfigInit;

  const BcApp({
    super.key,
    required this.home,
    this.variant = BcPlatformVariant.adaptive,
    this.title = 'BitCode',
    this.debugShowCheckedModeBanner = false,
    this.appConfigStore,
    this.appConfigInit,
  });

  @override
  State<BcApp> createState() => _BcAppState();
}

class _BcAppState extends State<BcApp> {
  late final AppConfigStore _store;
  late final bool _ownsStore;
  AppConfigSnapshot? _snapshot;
  VoidCallback? _unsubscribe;

  @override
  void initState() {
    super.initState();
    if (widget.appConfigStore != null) {
      _store = widget.appConfigStore!;
      _ownsStore = false;
    } else {
      _store = AppConfigStore(init: widget.appConfigInit ?? const AppConfigInit());
      _ownsStore = true;
    }
    _snapshot = _store.getSnapshot();
    _unsubscribe = _store.subscribe(_onSnapshot);
  }

  void _onSnapshot(AppConfigSnapshot snap) {
    if (!mounted) return;
    setState(() => _snapshot = snap);
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snap = _snapshot ?? _store.getSnapshot();
    return PlatformApp(
      title: widget.title,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      material: (context, platform) => MaterialAppData(
        theme: BcTheme.materialLight(),
        darkTheme: BcTheme.materialDark(),
      ),
      cupertino: (context, platform) => CupertinoAppData(
        theme: BcTheme.cupertinoLight(),
      ),
      builder: (context, child) {
        Widget body = child ?? const SizedBox.shrink();
        // Force Material variant on non-Apple platforms even when FPW is adaptive.
        if (widget.variant == BcPlatformVariant.material) {
          body = Theme(
            data: BcTheme.materialLight(),
            child: Material(child: body),
          );
        }
        // Expose AppConfigSnapshot to descendants (ADR-013 Phase 1 parity).
        return BcAppConfig(
          snapshot: snap,
          store: _store,
          child: body,
        );
      },
      home: widget.home,
    );
  }
}
