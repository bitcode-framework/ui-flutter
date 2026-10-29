// Animation + Adapt runtime parity tests — Dart port of the TS
// `core/animation` and `core/adapt` runtimes (ADR-013 §4 / A042 / A043).
//
// Verifies: default merge, reduced-motion collapse, kind→css mapping,
// adapt breakpoint + platform conditions, default when/to, SSR-safe
// (no widget tree / MediaQuery required — pure functions with injectable
// context).

import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/animation/animation.dart';
import 'package:bc_ui_flutter/src/core/adapt/adapt.dart';
import 'package:bc_ui_flutter/src/core/bc_breakpoints.dart';

void main() {
  group('BcAnimationKind — enum parity', () {
    test('mirrors the TS AnimationKind literal set', () {
      // The seven TS kinds must all be present.
      expect(BcAnimationKind.values, containsAll([
        BcAnimationKind.fade,
        BcAnimationKind.slideUp,
        BcAnimationKind.slideDown,
        BcAnimationKind.slideLeft,
        BcAnimationKind.slideRight,
        BcAnimationKind.scale,
        BcAnimationKind.none,
      ]));
      expect(BcAnimationKind.values.length, 7);
    });
  });

  group('resolveAnimation — default merge', () {
    test('undefined props resolve to ANIMATION_DEFAULT (fade, 200ms, ease-in-out)', () {
      final r = resolveAnimation(null);
      expect(r.kind, BcAnimationKind.fade);
      expect(r.duration, 200);
      expect(r.easing, BcAnimationEasing.easeInOut);
      // CSS transition diagnostic mirrors the TS web tier output.
      expect(r.cssTransition, 'opacity 200ms ease-in-out');
    });

    test('caller props override defaults', () {
      final r = resolveAnimation(const BcAnimationProps(
        animate: BcAnimationKind.scale,
        duration: 350,
        easing: BcAnimationEasing.easeIn,
      ));
      expect(r.kind, BcAnimationKind.scale);
      expect(r.duration, 350);
      expect(r.easing, BcAnimationEasing.easeIn);
      expect(r.cssTransition, 'transform 350ms ease-in');
    });

    test('partial props keep defaults for omitted fields', () {
      final r = resolveAnimation(const BcAnimationProps(
        animate: BcAnimationKind.slideUp,
      ));
      expect(r.kind, BcAnimationKind.slideUp);
      expect(r.duration, 200, reason: 'default duration preserved');
      expect(r.easing, BcAnimationEasing.easeInOut, reason: 'default easing preserved');
    });
  });

  group('resolveAnimation — kind → css property mapping', () {
    test('fade maps to opacity', () {
      expect(resolveAnimation(const BcAnimationProps(animate: BcAnimationKind.fade)).cssTransition,
          startsWith('opacity'));
    });

    test('slide-up maps to transform', () {
      expect(resolveAnimation(const BcAnimationProps(animate: BcAnimationKind.slideUp)).cssTransition,
          startsWith('transform'));
    });

    test('scale maps to transform', () {
      expect(resolveAnimation(const BcAnimationProps(animate: BcAnimationKind.scale)).cssTransition,
          startsWith('transform'));
    });
  });

  group('resolveAnimation — reduced motion collapse', () {
    test('reducedMotion=true collapses kind to none regardless of configured kind', () {
      final r = resolveAnimation(
        const BcAnimationProps(animate: BcAnimationKind.fade),
        const BcResolveAnimationOptions(reducedMotion: true),
      );
      expect(r.kind, BcAnimationKind.none);
      expect(r.cssTransition, 'none');
      expect(r.durationValue, Duration.zero);
    });

    test('reducedMotion=false honors the configured kind', () {
      final r = resolveAnimation(
        const BcAnimationProps(animate: BcAnimationKind.scale),
        const BcResolveAnimationOptions(reducedMotion: false),
      );
      expect(r.kind, BcAnimationKind.scale);
      expect(r.cssTransition, isNot('none'));
    });

    test('kind=none collapses even without reduced-motion flag', () {
      final r = resolveAnimation(const BcAnimationProps(animate: BcAnimationKind.none));
      expect(r.kind, BcAnimationKind.none);
      expect(r.cssTransition, 'none');
    });

    test('options omitted defaults to reducedMotion=false (headless/test safe)', () {
      // No MediaQuery / widget tree required — pure function.
      final r = resolveAnimation(const BcAnimationProps(animate: BcAnimationKind.fade));
      expect(r.kind, BcAnimationKind.fade, reason: 'no reduced-motion signal → kind preserved');
    });
  });

  group('resolveAnimation — curve exposure', () {
    test('returns a Curve host widgets can plug into Animated*', () {
      final r = resolveAnimation(const BcAnimationProps(animate: BcAnimationKind.fade));
      expect(r.curve, isNotNull);
      expect(r.durationValue, const Duration(milliseconds: 200));
    });
  });

  group('getAnimationCurves — enter/exit parity', () {
    test('returns matching curves for an active kind', () {
      final pair = getAnimationCurves(
        const BcAnimationProps(animate: BcAnimationKind.fade),
      );
      expect(pair.enter, pair.exit);
    });

    test('collapses to linear when reduced motion active', () {
      final pair = getAnimationCurves(
        const BcAnimationProps(animate: BcAnimationKind.fade),
        const BcResolveAnimationOptions(reducedMotion: true),
      );
      // Both linear → instant transition (parity with TS empty classes).
      expect(pair.enter.toString(), contains('Linear'));
    });
  });

  // -------------------------------------------------------------------------
  // Adapt runtime
  // -------------------------------------------------------------------------

  group('BcAdaptBreakpoint — enum parity', () {
    test('mirrors the TS AdaptBreakpoint set', () {
      expect(BcAdaptBreakpoint.values.length, 5);
      expect(BcAdaptBreakpoint.values, containsAll([
        BcAdaptBreakpoint.sm,
        BcAdaptBreakpoint.md,
        BcAdaptBreakpoint.lg,
        BcAdaptBreakpoint.xl,
        BcAdaptBreakpoint.xxl,
      ]));
    });
  });

  group('BcAdaptCondition — parse', () {
    test('tryParse recognizes breakpoint names', () {
      expect(BcAdaptCondition.tryParse('sm')?.breakpoint, BcAdaptBreakpoint.sm);
      expect(BcAdaptCondition.tryParse('md')?.breakpoint, BcAdaptBreakpoint.md);
      expect(BcAdaptCondition.tryParse('2xl')?.breakpoint, BcAdaptBreakpoint.xxl,
          reason: 'TS parity: 2xl → xxl');
    });

    test('tryParse recognizes platform tags', () {
      expect(BcAdaptCondition.tryParse('platform:mobile')?.platform,
          BcAdaptPlatform.mobile);
      expect(BcAdaptCondition.tryParse('platform:rn')?.platform,
          BcAdaptPlatform.rn);
    });

    test('tryParse returns null for unknown strings', () {
      expect(BcAdaptCondition.tryParse('unknown'), isNull);
      expect(BcAdaptCondition.tryParse('platform:web'), isNull);
    });

    test('isPlatform distinguishes platform from breakpoint conditions', () {
      expect(const BcAdaptCondition.platform(BcAdaptPlatform.mobile).isPlatform, true);
      expect(const BcAdaptCondition.breakpoint(BcAdaptBreakpoint.md).isPlatform, false);
    });
  });

  group('resolveAdapt — defaults', () {
    test('undefined props default to when=md, to=sheet', () {
      // No context → breakpoint never matches (headless default matcher).
      final r = resolveAdapt();
      expect(r.when.breakpoint, BcAdaptBreakpoint.md, reason: 'default when is md');
      expect(r.target, isNull, reason: 'default target sheet only applies when condition holds');
      expect(r.applies, false, reason: 'no matcher → breakpoint does not match');
    });
  });

  group('resolveAdapt — breakpoint conditions', () {
    test('applies when the injected matcher says the query matches', () {
      final ctx = BcAdaptContext(
        breakpointMatcher: (query) => query == bcBreakpointQueries[BcAdaptBreakpoint.md],
      );
      final r = resolveAdapt(const BcAdaptProps(), ctx);
      expect(r.applies, true);
      expect(r.target, BcAdaptTarget.sheet, reason: 'default to=sheet');
    });

    test('does not apply when the matcher says no match', () {
      final ctx = BcAdaptContext(breakpointMatcher: (query) => false);
      final r = resolveAdapt(const BcAdaptProps(), ctx);
      expect(r.applies, false);
      expect(r.target, isNull);
    });

    test('explicit to overrides default target', () {
      final ctx = BcAdaptContext(
        breakpointMatcher: (query) => query == bcBreakpointQueries[BcAdaptBreakpoint.lg],
      );
      final r = resolveAdapt(
        const BcAdaptProps(when: BcAdaptCondition.breakpoint(BcAdaptBreakpoint.lg), to: BcAdaptTarget.fullscreen),
        ctx,
      );
      expect(r.applies, true);
      expect(r.target, BcAdaptTarget.fullscreen);
    });
  });

  group('resolveAdapt — platform conditions', () {
    test('platform:mobile applies when ctx.platform == mobile', () {
      const ctx = BcAdaptContext(platform: BcAdaptPlatform.mobile);
      final r = resolveAdapt(
        const BcAdaptProps(
          when: BcAdaptCondition.platform(BcAdaptPlatform.mobile),
          to: BcAdaptTarget.actionsheet,
        ),
        ctx,
      );
      expect(r.applies, true);
      expect(r.target, BcAdaptTarget.actionsheet);
    });

    test('platform:rn never applies on Flutter', () {
      // Flutter is not React Native; even if ctx.platform were rn it would
      // be a misconfiguration. The resolver reports applies based on ctx.
      const ctx = BcAdaptContext(platform: BcAdaptPlatform.mobile);
      final r = resolveAdapt(
        const BcAdaptProps(when: BcAdaptCondition.platform(BcAdaptPlatform.rn)),
        ctx,
      );
      expect(r.applies, false, reason: 'ctx.platform=mobile ≠ rn');
    });

    test('platform condition ignores the breakpoint matcher', () {
      final ctx = BcAdaptContext(
        platform: BcAdaptPlatform.mobile,
        breakpointMatcher: (q) => false, // matcher must not be consulted
      );
      final r = resolveAdapt(
        const BcAdaptProps(when: BcAdaptCondition.platform(BcAdaptPlatform.mobile)),
        ctx,
      );
      expect(r.applies, true);
    });
  });

  group('resolveAdapt — SSR / headless safety', () {
    test('no context + breakpoint condition → applies=false (no crash)', () {
      final r = resolveAdapt(const BcAdaptProps());
      expect(r.applies, false);
    });

    test('BcAdaptResolver callable mirrors the free function', () {
      const resolver = BcAdaptResolver();
      final r = resolver(const BcAdaptProps(), null);
      expect(r.applies, false);
      expect(r.when.breakpoint, BcAdaptBreakpoint.md);
    });
  });

  group('bcBreakpointQueries — parity with TS BC_BREAKPOINTS', () {
    test('exposes all five standard breakpoint media queries', () {
      expect(bcBreakpointQueries.keys, containsAll([
        BcAdaptBreakpoint.sm,
        BcAdaptBreakpoint.md,
        BcAdaptBreakpoint.lg,
        BcAdaptBreakpoint.xl,
        BcAdaptBreakpoint.xxl,
      ]));
      // Mirrors the Tailwind defaults used by the TS tier.
      expect(bcBreakpointQueries[BcAdaptBreakpoint.md], '(min-width: 768px)');
      expect(bcBreakpointQueries[BcAdaptBreakpoint.sm], '(min-width: 640px)');
    });
  });
}
