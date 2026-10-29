library bc_empty;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Empty state placeholder (ADR-011 Phase 5c — M1 display).
///
/// Renders a centered placeholder for empty lists, tables, or search
/// results. The [message] is the primary text; [icon] and [action] are
/// optional. When [icon] is null, no default icon is rendered (the caller
/// decides whether to provide one). When [action] is null, no action area
/// is rendered.
///
/// The widget is a pure [StatelessWidget] because it has no internal
/// mutable state.
class BcEmpty extends StatelessWidget {
  final Widget? icon;
  final String? message;
  final Widget? action;

  const BcEmpty({
    super.key,
    this.icon,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: const IconThemeData(
                  color: BcTheme.mutedForeground,
                  size: 48,
                ),
                child: icon!,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message ?? 'No data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: BcTheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
