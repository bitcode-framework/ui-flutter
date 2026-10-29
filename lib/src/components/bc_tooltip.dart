library bc_tooltip;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Adaptive tooltip (ADR-011 Section 5).
/// Material: Tooltip. Cupertino: Tooltip (same widget, styled differently via theme).
class BcTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final Duration? waitDuration;
  final Duration? showDuration;
  final bool preferBelow;

  const BcTooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration,
    this.showDuration,
    this.preferBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => Tooltip(
        message: message,
        waitDuration: waitDuration,
        showDuration: showDuration,
        preferBelow: preferBelow,
        child: child,
      ),
      cupertino: (context, platform) => Tooltip(
        message: message,
        waitDuration: waitDuration,
        showDuration: showDuration,
        preferBelow: preferBelow,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CupertinoColors.separator),
        ),
        textStyle: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 14,
        ),
        child: child,
      ),
    );
  }
}
