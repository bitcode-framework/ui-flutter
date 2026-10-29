library bc_badge;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Compact pill badge (ADR-011 Phase 5c - block parity).
///
/// Mirrors TS `BcBadge` contract. Renders a rounded pill with a [variant]
/// color mapping. The [label] is the visible text (web `children`).
///
/// Variant token mapping follows the web contract:
///  - [BcComponentVariant.defaultVariant] and [BcComponentVariant.primary]
///    use the primary token pair.
///  - [BcComponentVariant.secondary] uses the secondary token pair.
///  - [BcComponentVariant.destructive] uses the destructive token pair.
///  - [BcComponentVariant.outline], [BcComponentVariant.ghost], and
///    [BcComponentVariant.link] render transparent backgrounds with a
///    foreground-text color (outline adds a border).
class BcBadge extends StatelessWidget {
  final String label;
  final BcComponentVariant variant;

  const BcBadge({
    super.key,
    required this.label,
    this.variant = BcComponentVariant.defaultVariant,
  });

  Color get _background {
    switch (variant) {
      case BcComponentVariant.defaultVariant:
      case BcComponentVariant.primary:
        return BcTheme.primary;
      case BcComponentVariant.secondary:
        return BcTheme.secondary;
      case BcComponentVariant.destructive:
        return BcTheme.destructive;
      case BcComponentVariant.outline:
      case BcComponentVariant.ghost:
      case BcComponentVariant.link:
        return Colors.transparent;
    }
  }

  Color get _foreground {
    switch (variant) {
      case BcComponentVariant.defaultVariant:
      case BcComponentVariant.primary:
        return BcTheme.primaryForeground;
      case BcComponentVariant.secondary:
        return BcTheme.secondaryForeground;
      case BcComponentVariant.destructive:
        return BcTheme.destructiveForeground;
      case BcComponentVariant.outline:
      case BcComponentVariant.ghost:
      case BcComponentVariant.link:
        return BcTheme.foreground;
    }
  }

  bool get _hasBorder => variant == BcComponentVariant.outline;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _background,
      borderRadius: BorderRadius.circular(BcTheme.radius * 3),
      border: _hasBorder ? Border.all(color: BcTheme.border) : null,
    );

    return Semantics(
      label: label,
      child: Container(
        key: const Key('bc-badge'),
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: ExcludeSemantics(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _foreground,
            ),
          ),
        ),
      ),
    );
  }
}