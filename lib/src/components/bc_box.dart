library bc_box;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// BcTheme color token selector for [BcBox] background.
enum BcBoxColorToken {
  surface,
  background,
  card,
  muted,
  primary,
  secondary,
  border,
  foreground,
}

/// Generic box container with padding, margin, and decoration
/// (ADR-011 Phase 5c — M1 layout).
///
/// Mirrors TS [BcBoxContract] with the additions described in the
/// validation contract (border, background, borderRadius, clip).
/// Padding and margin accept raw logical pixels (the TS spacing scale
/// 0-16 maps to 4px multiples, but callers may pass any double).
/// All visual styling uses [BcTheme] tokens — no hardcoded hex.
class BcBox extends StatelessWidget {
  final double padding;
  final double margin;
  final bool border;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final Clip clipBehavior;
  final BcBoxColorToken? backgroundColor;
  final Color? customBackgroundColor;
  final Widget? child;

  const BcBox({
    super.key,
    this.padding = 0,
    this.margin = 0,
    this.border = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 0,
    this.clipBehavior = Clip.none,
    this.backgroundColor,
    this.customBackgroundColor,
    this.child,
  });

  Color? _resolveColor() {
    if (customBackgroundColor != null) return customBackgroundColor;
    if (backgroundColor == null) return null;
    switch (backgroundColor!) {
      case BcBoxColorToken.surface:
        return BcTheme.background;
      case BcBoxColorToken.background:
        return BcTheme.background;
      case BcBoxColorToken.card:
        return BcTheme.card;
      case BcBoxColorToken.muted:
        return BcTheme.muted;
      case BcBoxColorToken.primary:
        return BcTheme.primary;
      case BcBoxColorToken.secondary:
        return BcTheme.secondary;
      case BcBoxColorToken.border:
        return BcTheme.border;
      case BcBoxColorToken.foreground:
        return BcTheme.foreground;
    }
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: _resolveColor(),
      border: border
          ? Border.all(
              color: borderColor ?? BcTheme.border,
              width: borderWidth,
            )
          : null,
      borderRadius: borderRadius > 0
          ? BorderRadius.circular(borderRadius)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _buildDecoration();
    final padded = padding > 0
        ? Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          )
        : child;

    final useClip = borderRadius > 0 && clipBehavior != Clip.none;

    Widget content;
    if (useClip) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: DecoratedBox(
          decoration: decoration,
          child: padded,
        ),
      );
    } else {
      content = Container(
        decoration: decoration,
        child: padded,
      );
    }

    if (margin > 0) {
      return Padding(
        padding: EdgeInsets.all(margin),
        child: content,
      );
    }
    return content;
  }
}
