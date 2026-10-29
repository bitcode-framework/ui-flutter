library bc_loading_overlay;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Full-screen loading spinner overlay (ADR-011 Phase 5c — M1 foundation).
///
/// When [loading] is true, the overlay renders a platform-aware loading
/// indicator (Cupertino on iOS/macOS, Material elsewhere) that covers its
/// bounds and absorbs pointer events so content beneath cannot be interacted
/// with. When [loading] is false, the widget renders nothing and does not
/// intercept events.
///
/// The overlay centers the spinner within a dimmed background. An optional
/// [message] renders below the spinner. The [color] prop (which defaults to
/// the primary token) controls the spinner color on Material targets.
class BcLoadingOverlay extends StatelessWidget {
  final bool loading;
  final String? message;
  final Color? color;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final double? size;

  const BcLoadingOverlay({
    super.key,
    required this.loading,
    this.message,
    this.color,
    this.backgroundColor,
    this.backgroundOpacity = 0.6,
    this.size,
  });

  bool _isCupertino(TargetPlatform platform) {
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  Widget _buildSpinner(BuildContext context, TargetPlatform platform) {
    final spinnerColor = color ?? Theme.of(context).colorScheme.primary;

    if (_isCupertino(platform)) {
      return CupertinoActivityIndicator(
        color: spinnerColor,
        radius: (size ?? 16) / 2,
      );
    }
    return SizedBox(
      width: size ?? 32,
      height: size ?? 32,
      child: CircularProgressIndicator(
        color: spinnerColor,
        strokeWidth: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      return const SizedBox.shrink();
    }

    final platform = Theme.of(context).platform;
    final bg = backgroundColor ?? BcTheme.background;

    return Positioned.fill(
      child: ColoredBox(
        color: bg.withValues(alpha: backgroundOpacity.clamp(0.0, 1.0)),
        child: AbsorbPointer(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSpinner(context, platform),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BcTheme.foreground,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
