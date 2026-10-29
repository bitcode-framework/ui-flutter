// ============================================================================
// Animation runtime — Dart port of the TS `core/animation` module
// (packages/ui/src/core/animation/{types,runtime}.ts, ADR-002 §9.3 / ADR-013
// §4).
//
// Mirrors the TS contract surface: `BcAnimationKind`, `BcAnimationEasing`,
// `BcAnimationProps`, `ANIMATION_DEFAULT`, `BcResolvedAnimation`, and
// `resolveAnimation`. The reduced-motion preference is resolved from an
// injectable `reducedMotion` flag; when `null` (production), the host widget
// is expected to pass `MediaQuery.disableAnimationsOf(context)` (see A042).
//
// Flutter parity note (A042): the TS runtime returns a ready-to-use CSS
// `transition` string (`cssTransition`). Flutter has no CSS; instead the
// resolved descriptor exposes `kind`, `duration`, `easing`, and a
// `curve` (`Curve` from `flutter/animation.dart`) that host widgets plug into
// `AnimatedSwitcher` / `AnimatedOpacity` / `SlideTransition`. The `kind` is
// also kept so consumers and tests can identify the active animation by name
// (parity with the TS `bc-anim-<kind>` class names).
// ============================================================================

import 'package:flutter/animation.dart';

/// Animation preset. Mirrors TS `AnimationKind`.
enum BcAnimationKind {
  fade,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  none,
}

/// Easing curve selector. Mirrors TS `AnimationEasing`.
enum BcAnimationEasing {
  linear,
  ease,
  easeIn,
  easeOut,
  easeInOut,
}

/// Contract slot for components that animate. Mirrors TS `AnimationProps`.
class BcAnimationProps {
  /// Animation preset. Defaults to per-component baseline (often `fade`).
  final BcAnimationKind? animate;

  /// Duration in ms. Defaults to the design token `--bc-duration-md`.
  final int? duration;

  /// Easing curve. Defaults to the token `--bc-easing-standard`.
  final BcAnimationEasing? easing;

  const BcAnimationProps({this.animate, this.duration, this.easing});

  /// Mirrors TS `ANIMATION_DEFAULT` — sensible defaults applied when a field
  /// is omitted. Components apply this when `animate` is null, but MUST honor
  /// the reduced-motion preference by collapsing to `none`.
  static const BcAnimationProps defaultProps = BcAnimationProps(
    animate: BcAnimationKind.fade,
    duration: 200,
    easing: BcAnimationEasing.easeInOut,
  );
}

/// Alias kept for barrel parity with the TS `ANIMATION_DEFAULT` export.
// ignore: constant_identifier_names — intentional SCREAMING_SNAKE for cross-tier parity.
const BcAnimationProps ANIMATION_DEFAULT = BcAnimationProps.defaultProps;

/// Fully-resolved animation descriptor. Mirrors TS `ResolvedAnimation`.
///
/// Unlike the TS variant (which carries a `cssTransition: string`), the Dart
/// port carries a ready-to-use [Curve] (`curve`) that host widgets plug into
/// Flutter's `Animated*` / `Transition` widgets. `cssTransition` is retained
/// as a diagnostic string for cross-tier traceability (it mirrors what the TS
/// tier would emit for the same inputs).
class BcResolvedAnimation {
  /// Resolved kind (post reduced-motion collapse).
  final BcAnimationKind kind;

  /// Resolved duration in ms.
  final int duration;

  /// Resolved easing curve selector.
  final BcAnimationEasing easing;

  /// Ready-to-use Flutter [Curve]. `Curves.linear` (instant) when the kind is
  /// `none` or reduced motion is active.
  final Curve curve;

  /// Ready-to-use [Duration]. `Duration.zero` when reduced motion / `none`.
  final Duration durationValue;

  /// Diagnostic CSS-transition string mirroring the TS tier's `cssTransition`
  /// for cross-tier traceability. `none` when the kind is `none` or reduced
  /// motion is active.
  final String cssTransition;

  const BcResolvedAnimation({
    required this.kind,
    required this.duration,
    required this.easing,
    required this.curve,
    required this.durationValue,
    required this.cssTransition,
  });
}

/// Injectable options for [resolveAnimation]. Mirrors TS
/// `ResolveAnimationOptions`. Tests pass an explicit `reducedMotion` flag so
/// they don't have to stub `MediaQuery`.
class BcResolveAnimationOptions {
  /// Override the reduced-motion signal. When `true`, the resolved animation
  /// collapses to `none`. When `false`, the OS preference is ignored. When
  /// `null` (default, production), the host widget passes
  /// `MediaQuery.disableAnimationsOf(context)` — i.e. the caller resolves the
  /// real Flutter preference and forwards it here.
  final bool? reducedMotion;

  const BcResolveAnimationOptions({this.reducedMotion});
}

/// Maps a [BcAnimationEasing] to a Flutter [Curve]. Parity with the TS
/// easing-name → CSS easing-curve mapping.
Curve _curveFor(BcAnimationEasing easing) {
  switch (easing) {
    case BcAnimationEasing.linear:
      return Curves.linear;
    case BcAnimationEasing.ease:
      return Curves.ease;
    case BcAnimationEasing.easeIn:
      return Curves.easeIn;
    case BcAnimationEasing.easeOut:
      return Curves.easeOut;
    case BcAnimationEasing.easeInOut:
      return Curves.easeInOut;
  }
}

/// Maps a [BcAnimationKind] to the CSS property it drives. Parity with the TS
/// `CSS_PROPERTY` map — used only to build the diagnostic `cssTransition`
/// string for cross-tier traceability.
String _cssPropertyFor(BcAnimationKind kind) {
  switch (kind) {
    case BcAnimationKind.fade:
      return 'opacity';
    case BcAnimationKind.slideUp:
    case BcAnimationKind.slideDown:
    case BcAnimationKind.slideLeft:
    case BcAnimationKind.slideRight:
    case BcAnimationKind.scale:
      return 'transform';
    case BcAnimationKind.none:
      return '';
  }
}

String _easingName(BcAnimationEasing easing) {
  switch (easing) {
    case BcAnimationEasing.linear:
      return 'linear';
    case BcAnimationEasing.ease:
      return 'ease';
    case BcAnimationEasing.easeIn:
      return 'ease-in';
    case BcAnimationEasing.easeOut:
      return 'ease-out';
    case BcAnimationEasing.easeInOut:
      return 'ease-in-out';
  }
}

/// Resolve [BcAnimationProps] into a concrete animation descriptor.
///
/// - Merges `props` with [ANIMATION_DEFAULT] (caller-supplied values win).
/// - Collapses `kind` to `none` (and `cssTransition` to `none`,
///   `durationValue` to `Duration.zero`) when the user prefers reduced
///   motion, regardless of the configured kind.
///
/// [options] is optional. Production callers pass
/// `BcResolveAnimationOptions(reducedMotion: MediaQuery.disableAnimationsOf(context))`
/// so the real Flutter reduced-motion preference is honored (A042). Tests
/// inject an explicit flag to avoid stubbing `MediaQuery`.
BcResolvedAnimation resolveAnimation(
  BcAnimationProps? props, [
  BcResolveAnimationOptions? options,
]) {
  final kind = props?.animate ?? ANIMATION_DEFAULT.animate!;
  final duration = props?.duration ?? ANIMATION_DEFAULT.duration!;
  final easing = props?.easing ?? ANIMATION_DEFAULT.easing!;

  final reduced = options?.reducedMotion ?? false;

  if (reduced || kind == BcAnimationKind.none) {
    return const BcResolvedAnimation(
      kind: BcAnimationKind.none,
      duration: 0,
      easing: BcAnimationEasing.easeInOut,
      curve: Curves.linear,
      durationValue: Duration.zero,
      cssTransition: 'none',
    );
  }

  final property = _cssPropertyFor(kind);
  final cssTransition = '$property ${duration}ms ${_easingName(easing)}';
  return BcResolvedAnimation(
    kind: kind,
    duration: duration,
    easing: easing,
    curve: _curveFor(easing),
    durationValue: Duration(milliseconds: duration),
    cssTransition: cssTransition,
  );
}

/// Returns the enter/exit [Curve] pair for a given kind. Convenience parity
/// with the TS `getAnimationClasses` helper — on Flutter the host uses these
/// curves directly in `AnimatedSwitcher` / `SlideTransition`.
///
/// Returns `(Curves.linear, Curves.linear)` (instant) when reduced motion is
/// active or the resolved kind is `none`.
({Curve enter, Curve exit}) getAnimationCurves(
  BcAnimationProps? propsOrKind, [
  BcResolveAnimationOptions? options,
]) {
  final resolved = propsOrKind is BcAnimationProps
      ? resolveAnimation(propsOrKind, options)
      : resolveAnimation(
          BcAnimationProps(animate: propsOrKind as BcAnimationKind?),
          options,
        );
  if (resolved.kind == BcAnimationKind.none) {
    return (enter: Curves.linear, exit: Curves.linear);
  }
  return (enter: resolved.curve, exit: resolved.curve);
}
