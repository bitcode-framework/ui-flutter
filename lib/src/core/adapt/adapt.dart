// ============================================================================
// Adapt runtime — Dart port of the TS `resolveAdapt`
// (packages/ui/src/core/adapt/runtime.ts, ADR-002 §9.4 / ADR-013 §4).
//
// `resolveAdapt` evaluates the `when` condition (a breakpoint OR a
// `platform:` tag) and returns whether the morph applies plus the target
// form factor.
//
// Flutter parity (A043):
//   - Breakpoint conditions are resolved against a [BcAdaptContext] whose
//     `widthMatches` callback the host derives from `MediaQuery.size`
//     (e.g. `widthMatches('(min-width: 768px)')` ↔ `size.width >= 768`).
//     The context is injectable so tests pass an explicit matcher without a
//     real widget tree.
//   - Platform conditions (`platform:mobile` / `platform:rn`) resolve against
//     [BcAdaptContext.platform], which the host derives from
//     `Platform.isIOS`/`Platform.isAndroid` (mobile) or `kIsWeb` (web).
//     React-Native-only (`platform:rn`) never applies on Flutter.
//
// The resolver is a pure function — no side effects, no MediaQuery/Platform
// access unless the caller injects them. This keeps it SSR/test-safe and
// decoupled from the widget tree.
// ============================================================================

import '../bc_breakpoints.dart';

/// Standard breakpoint form factors. Mirrors TS `AdaptBreakpoint`.
enum BcAdaptBreakpoint { sm, md, lg, xl, xxl }

/// Platform tag. Mirrors TS `AdaptPlatform`. `rn` (React Native) is kept for
/// contract parity but never resolves `true` on Flutter.
enum BcAdaptPlatform { mobile, rn }

/// Replacement form factor when the morph applies. Mirrors TS `AdaptTarget`.
enum BcAdaptTarget { sheet, actionsheet, fullscreen, inline }

/// When the morph applies. Either a breakpoint OR a platform tag.
///
/// Mirrors TS `AdaptCondition`. A platform condition is encoded as the string
/// `platform:<tag>` (e.g. `platform:mobile`) so the runtime can switch on the
/// prefix — same encoding as the TS side.
class BcAdaptCondition {
  /// The breakpoint, or `null` when this is a platform condition.
  final BcAdaptBreakpoint? breakpoint;

  /// The platform tag, or `null` when this is a breakpoint condition.
  final BcAdaptPlatform? platform;

  /// Construct from a breakpoint.
  const BcAdaptCondition.breakpoint(this.breakpoint) : platform = null;

  /// Construct from a platform tag.
  const BcAdaptCondition.platform(this.platform) : breakpoint = null;

  /// Parse a condition string. Accepts a breakpoint name (`sm`/`md`/.../`xxl`,
  /// also `2xl` for TS parity) or a `platform:<tag>` string.
  ///
  /// Returns `null` when the string is not recognized.
  static BcAdaptCondition? tryParse(String raw) {
    if (raw.startsWith('platform:')) {
      final tag = raw.substring('platform:'.length);
      switch (tag) {
        case 'mobile':
          return const BcAdaptCondition.platform(BcAdaptPlatform.mobile);
        case 'rn':
          return const BcAdaptCondition.platform(BcAdaptPlatform.rn);
      }
      return null;
    }
    switch (raw) {
      case 'sm':
        return const BcAdaptCondition.breakpoint(BcAdaptBreakpoint.sm);
      case 'md':
        return const BcAdaptCondition.breakpoint(BcAdaptBreakpoint.md);
      case 'lg':
        return const BcAdaptCondition.breakpoint(BcAdaptBreakpoint.lg);
      case 'xl':
        return const BcAdaptCondition.breakpoint(BcAdaptBreakpoint.xl);
      case '2xl':
      case 'xxl':
        return const BcAdaptCondition.breakpoint(BcAdaptBreakpoint.xxl);
    }
    return null;
  }

  /// `true` when this is a platform condition.
  bool get isPlatform => platform != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcAdaptCondition &&
          breakpoint == other.breakpoint &&
          platform == other.platform;

  @override
  int get hashCode => Object.hash(breakpoint, platform);

  @override
  String toString() => breakpoint != null
      ? 'BcAdaptCondition(${breakpoint!.name})'
      : 'BcAdaptCondition(platform:${platform!.name})';
}

/// Opt-in responsive/platform morphing contract slot. Mirrors TS `AdaptProps`.
class BcAdaptProps {
  /// Trigger condition. Defaults to `md` (web mobile-first breakpoint).
  final BcAdaptCondition? when;

  /// Replacement form factor. Defaults vary by component (see
  /// [bcAdaptDefaultTarget]).
  final BcAdaptTarget? to;

  const BcAdaptProps({this.when, this.to});

  /// Build from raw strings (convenience for schema-driven construction).
  /// `whenRaw` is parsed via [BcAdaptCondition.tryParse]; `toRaw` via
  /// [BcAdaptTarget] name. Unknown values fall back to `null` (default).
  factory BcAdaptProps.fromRaw({String? whenRaw, String? toRaw}) {
    return BcAdaptProps(
      when: whenRaw == null ? null : BcAdaptCondition.tryParse(whenRaw),
      to: toRaw == null
          ? null
          : _parseTarget(toRaw),
    );
  }
}

BcAdaptTarget? _parseTarget(String raw) {
  switch (raw) {
    case 'sheet':
      return BcAdaptTarget.sheet;
    case 'actionsheet':
      return BcAdaptTarget.actionsheet;
    case 'fullscreen':
      return BcAdaptTarget.fullscreen;
    case 'inline':
      return BcAdaptTarget.inline;
  }
  return null;
}

/// Injectable environment context. Mirrors TS `AdaptContext`. Both fields
/// optional so callers can construct a context for testing without touching
/// MediaQuery/Platform.
///
/// - [platform]: static platform tag. When the Adapt condition is
///   `platform:mobile`, this is consulted directly. The host derives it from
///   `Platform.isIOS`/`Platform.isAndroid` (mobile) or `kIsWeb` (web → not
///   mobile).
/// - [breakpointMatcher]: returns whether a media-query string currently
///   matches. The host derives it from `MediaQuery.size` (e.g.
///   `(min-width: 768px)` ↔ `size.width >= 768`). Defaults to `false`
///   (headless/test without a widget tree → no morph).
class BcAdaptContext {
  final BcAdaptPlatform? platform;
  final bool Function(String query)? breakpointMatcher;

  const BcAdaptContext({this.platform, this.breakpointMatcher});
}

/// Resolved morph result. Mirrors TS `ResolvedAdapt`.
class BcResolvedAdapt {
  /// Whether the morph condition is currently satisfied.
  final bool applies;

  /// Target form factor, or `null` when the morph does not apply.
  final BcAdaptTarget? target;

  /// The evaluated condition (after defaults). Useful for diagnostics.
  final BcAdaptCondition when;

  const BcResolvedAdapt({
    required this.applies,
    required this.target,
    required this.when,
  });

  @override
  String toString() =>
      'BcResolvedAdapt(applies: $applies, target: $target, when: $when)';
}

/// Default `when` per ADR-002 §9.4 (web mobile-first breakpoint).
const BcAdaptCondition bcAdaptDefaultWhen =
    BcAdaptCondition.breakpoint(BcAdaptBreakpoint.md);

/// Default `to` per ADR-002 §9.4.
const BcAdaptTarget bcAdaptDefaultTarget = BcAdaptTarget.sheet;

/// `BcAdaptResolver` — resolves [BcAdaptProps] against a [BcAdaptContext].
///
/// Pure (no side effects, no MediaQuery/Platform access unless injected).
/// Mirrors the TS `resolveAdapt` function. Exposed both as a class (for
/// hosts that prefer an instance) and as the [resolveAdapt] free function.
class BcAdaptResolver {
  const BcAdaptResolver();

  /// Resolve [props] against [ctx].
  ///
  /// - `props.when` defaults to [bcAdaptDefaultWhen] (`md`).
  /// - `props.to` defaults to [bcAdaptDefaultTarget] (`sheet`).
  /// - [ctx] is optional; omit it for headless/test use (every breakpoint
  ///   condition resolves to `false`, platform conditions resolve against
  ///   `ctx.platform` only).
  BcResolvedAdapt call(BcAdaptProps? props, [BcAdaptContext? ctx]) {
    return resolveAdapt(props, ctx);
  }
}

/// Match an [BcAdaptCondition] against the supplied context. Pure.
bool _conditionApplies(BcAdaptCondition when, BcAdaptContext? ctx) {
  if (when.isPlatform) {
    return ctx?.platform == when.platform;
  }
  // Breakpoint condition — look up the standard query.
  final query = bcBreakpointQueries[when.breakpoint!];
  if (query == null) return false;
  final matcher = ctx?.breakpointMatcher ?? _defaultMatcher;
  return matcher(query);
}

/// Default matcher: no widget tree → never matches (headless/test safe).
bool _defaultMatcher(String query) => false;

/// Resolve [BcAdaptProps] against [BcAdaptContext]. Free-function parity with
/// the TS `resolveAdapt(props?, ctx?)`.
BcResolvedAdapt resolveAdapt([BcAdaptProps? props, BcAdaptContext? ctx]) {
  final when = props?.when ?? bcAdaptDefaultWhen;
  final target = props?.to ?? bcAdaptDefaultTarget;
  final applies = _conditionApplies(when, ctx);
  return BcResolvedAdapt(
    applies: applies,
    target: applies ? target : null,
    when: when,
  );
}
