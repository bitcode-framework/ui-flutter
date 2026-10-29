/// AppConfigSnapshot — resolved runtime configuration snapshot.
///
/// Pure Dart port of the TS `AppConfigSnapshot` (ADR-002 §9.1, ADR-013 §1).
/// Plain immutable data — safe to serialize and to pass through
/// [InheritedWidget]. Mirrors the TS field set exactly so the two tiers
/// stay in parity (ADR-013 cross-tier parity table).
///
/// Fields:
///   - theme           : user intent ('system' | 'light' | 'dark')
///   - resolvedTheme   : concrete theme after 'system' resolution
///   - locale          : BCP-47 tag (e.g. 'en', 'ar-SA')
///   - direction       : user intent ('ltr' | 'rtl' | 'auto')
///   - resolvedDirection: concrete direction after 'auto' resolution
///   - size            : default component density ('sm' | 'md' | 'lg')
///   - dateLocale      : ICU tag used for date/number formatting
library app_config_snapshot;

/// User theme intent. 'system' defers to the platform preference.
enum AppThemeMode { system, light, dark }

/// Concrete resolved theme.
enum ResolvedAppTheme { light, dark }

/// User reading-direction intent. 'auto' derives from the active locale.
enum AppDirection { ltr, rtl, auto }

/// Concrete resolved reading direction.
enum ResolvedAppDirection { ltr, rtl }

/// Default component density.
enum AppSize { sm, md, lg }

/// A toast/notification message dispatched through the provider. Mirrors TS
/// `AppMessage`. The provider never renders toasts — it forwards to the
/// registered [AppMessageQueue] adapter.
class AppMessage {
  final String? id;
  final String level; // 'info' | 'success' | 'warning' | 'error'
  final String message;
  final Duration? duration;

  const AppMessage({
    this.id,
    this.level = 'info',
    required this.message,
    this.duration,
  });
}

/// Adapter any host UI can implement to receive messages dispatched via the
/// provider. Mirrors TS `MessageQueueAdapter`.
abstract class AppMessageQueue {
  String push(AppMessage message); // returns the id (generated if absent)
  void dismiss(String id);
  void clear();
}

/// Initial values accepted by [AppConfigStore]. All optional. Mirrors TS
/// `AppConfigInit`.
class AppConfigInit {
  final AppThemeMode? theme;
  final String? locale;
  final AppDirection? direction;
  final AppSize? size;
  final String? dateLocale;
  final AppMessageQueue? messageQueue;

  const AppConfigInit({
    this.theme,
    this.locale,
    this.direction,
    this.size,
    this.dateLocale,
    this.messageQueue,
  });
}

/// RTL locale primary subtags. Mirrors TS `RTL_LOCALES`.
const Set<String> rtlLocales = {
  'ar', 'he', 'fa', 'ur', 'ps', 'sd', 'yi', 'dv',
};

/// Resolve `auto` against a locale's primary subtag. Mirrors TS
/// `resolveDirection`.
ResolvedAppDirection resolveDirection(AppDirection direction, String locale) {
  if (direction == AppDirection.ltr) return ResolvedAppDirection.ltr;
  if (direction == AppDirection.rtl) return ResolvedAppDirection.rtl;
  final primary = locale.split('-').first.toLowerCase();
  return rtlLocales.contains(primary) ? ResolvedAppDirection.rtl : ResolvedAppDirection.ltr;
}

/// Immutable resolved snapshot read by consumers.
///
/// Mirrors TS `AppConfigSnapshot` field-for-field (ADR-013 §1 parity).
class AppConfigSnapshot {
  final AppThemeMode theme;
  final ResolvedAppTheme resolvedTheme;
  final String locale;
  final AppDirection direction;
  final ResolvedAppDirection resolvedDirection;
  final AppSize size;
  final String dateLocale;

  const AppConfigSnapshot({
    required this.theme,
    required this.resolvedTheme,
    required this.locale,
    required this.direction,
    required this.resolvedDirection,
    required this.size,
    required this.dateLocale,
  });

  /// Default snapshot — matches the TS `DEFAULT_SNAPSHOT` exactly
  /// (system/light/en/auto/ltr/md/en). Used as the SSR / no-provider
  /// fallback by [BcAppConfig].
  static const AppConfigSnapshot defaultSnapshot = AppConfigSnapshot(
    theme: AppThemeMode.system,
    resolvedTheme: ResolvedAppTheme.light,
    locale: 'en',
    direction: AppDirection.auto,
    resolvedDirection: ResolvedAppDirection.ltr,
    size: AppSize.md,
    dateLocale: 'en',
  );

  AppConfigSnapshot copyWith({
    AppThemeMode? theme,
    ResolvedAppTheme? resolvedTheme,
    String? locale,
    AppDirection? direction,
    ResolvedAppDirection? resolvedDirection,
    AppSize? size,
    String? dateLocale,
  }) =>
      AppConfigSnapshot(
        theme: theme ?? this.theme,
        resolvedTheme: resolvedTheme ?? this.resolvedTheme,
        locale: locale ?? this.locale,
        direction: direction ?? this.direction,
        resolvedDirection: resolvedDirection ?? this.resolvedDirection,
        size: size ?? this.size,
        dateLocale: dateLocale ?? this.dateLocale,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigSnapshot &&
          theme == other.theme &&
          resolvedTheme == other.resolvedTheme &&
          locale == other.locale &&
          direction == other.direction &&
          resolvedDirection == other.resolvedDirection &&
          size == other.size &&
          dateLocale == other.dateLocale;

  @override
  int get hashCode => Object.hash(
        theme,
        resolvedTheme,
        locale,
        direction,
        resolvedDirection,
        size,
        dateLocale,
      );

  @override
  String toString() =>
      'AppConfigSnapshot(theme: $theme, resolvedTheme: $resolvedTheme, '
      'locale: $locale, direction: $direction, resolvedDirection: $resolvedDirection, '
      'size: $size, dateLocale: $dateLocale)';
}
