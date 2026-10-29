library bc_native_button;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Visual variant for [BcNativeButton] (ADR-006 Adapt POC).
///
/// Mirrors TS `BcNativeButtonVariant` ('primary' | 'secondary' | 'destructive'
/// | 'outline' | 'plain').
enum BcNativeButtonVariant {
  primary,
  secondary,
  destructive,
  outline,
  plain;

  /// Background color token (or null for transparent backgrounds).
  Color? background(BuildContext context) {
    switch (this) {
      case BcNativeButtonVariant.primary:
        return BcTheme.primary;
      case BcNativeButtonVariant.secondary:
        return BcTheme.secondary;
      case BcNativeButtonVariant.destructive:
        return BcTheme.destructive;
      case BcNativeButtonVariant.outline:
      case BcNativeButtonVariant.plain:
        return null;
    }
  }

  /// Foreground (text) color token.
  Color foreground(BuildContext context) {
    switch (this) {
      case BcNativeButtonVariant.primary:
        return BcTheme.primaryForeground;
      case BcNativeButtonVariant.secondary:
        return BcTheme.secondaryForeground;
      case BcNativeButtonVariant.destructive:
        return BcTheme.destructiveForeground;
      case BcNativeButtonVariant.outline:
      case BcNativeButtonVariant.plain:
        return BcTheme.primary;
    }
  }
}

/// Platform-idiomatic button (ADR-006 Adapt POC, ADR-011).
///
/// Wraps flutter_platform_widgets `PlatformElevatedButton` so iOS gets
/// CupertinoButton idiom and Android gets Material Button. The variant prop
/// maps to BcTheme color tokens (primary, secondary, destructive, outline,
/// plain). Loading shows a spinner and disables interaction. The min touch
/// target is 44px (contract a11y requirement).
///
/// This is a real widget (not a typedef) because no `bc_button.dart` exists
/// in the Flutter layer (BcButton lives in the Mitosis/Stencil layer only).
class BcNativeButton extends StatelessWidget {
  /// Visual variant. Defaults to [BcNativeButtonVariant.primary].
  final BcNativeButtonVariant variant;

  /// Disable interaction and reduce opacity. Default false.
  final bool disabled;

  /// Show a loading spinner and block presses. Default false.
  final bool loading;

  /// Full-width stretch. Default false.
  final bool block;

  /// Called when the user presses the button (carries a [BcChangeMeta] with
  /// reason `press`).
  final BcChangeHandler<void>? onPress;

  /// Button label / child content.
  final Widget? child;

  /// Text label (convenience when [child] is not provided).
  final String? label;

  const BcNativeButton({
    super.key,
    this.variant = BcNativeButtonVariant.primary,
    this.disabled = false,
    this.loading = false,
    this.block = false,
    this.onPress,
    this.child,
    this.label,
  });

  void _handlePress() {
    onPress?.call(
      null,
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = variant;
    final isInteractive = !disabled && !loading;
    final fg = v.foreground(context);
    final bg = v.background(context);

    final content = <Widget>[
      if (loading)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
        ),
      if (child != null)
        child!
      else if (label != null)
        Text(
          label!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: fg,
          ),
        ),
    ];

    final button = PlatformElevatedButton(
      key: const Key('bc-native-button'),
      onPressed: isInteractive ? _handlePress : null,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      material: (context, platform) => MaterialElevatedButtonData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 44),
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: v == BcNativeButtonVariant.outline
              ? RoundedRectangleBorder(
                  side: const BorderSide(color: BcTheme.input),
                  borderRadius: BorderRadius.circular(BcTheme.radius),
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BcTheme.radius),
                ),
          padding: EdgeInsets.zero,
        ),
      ),
      cupertino: (context, platform) => CupertinoElevatedButtonData(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        color: bg,
        disabledColor: (bg ?? BcTheme.secondary).withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: content,
      ),
    );

    if (!block) return button;

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}
