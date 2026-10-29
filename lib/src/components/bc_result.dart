library bc_result;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Status variant for [BcResult].
enum BcResultStatus {
  success,
  error,
  warning,
  info,
  notFound404,
  forbidden403,
  serverError500,
}

/// Result page / status display (ADR-011 Phase 5c — M1 display).
///
/// Renders a status icon, [title], optional [subtitle], and optional
/// [actions] centered on the available space. The [status] drives the icon
/// glyph and its color through [BcTheme] tokens (success, destructive,
/// warning, info). No hardcoded hex values are used.
///
/// When [subtitle] or [actions] are null/empty, they are simply omitted —
/// no empty containers are rendered. The widget is a pure
/// [StatelessWidget] because it has no internal mutable state.
class BcResult extends StatelessWidget {
  final BcResultStatus status;
  final String? title;
  final String? subtitle;
  final List<Widget> actions;

  const BcResult({
    super.key,
    this.status = BcResultStatus.info,
    this.title,
    this.subtitle,
    this.actions = const [],
  });

  Color _statusColor() {
    switch (status) {
      case BcResultStatus.success:
        return BcTheme.success;
      case BcResultStatus.error:
        return BcTheme.destructive;
      case BcResultStatus.warning:
        return BcTheme.warning;
      case BcResultStatus.info:
        return BcTheme.info;
      case BcResultStatus.notFound404:
        return BcTheme.info;
      case BcResultStatus.forbidden403:
        return BcTheme.warning;
      case BcResultStatus.serverError500:
        return BcTheme.destructive;
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case BcResultStatus.success:
        return Icons.check_circle_outline;
      case BcResultStatus.error:
        return Icons.cancel_outlined;
      case BcResultStatus.warning:
        return Icons.warning_amber_outlined;
      case BcResultStatus.info:
        return Icons.info_outline;
      case BcResultStatus.notFound404:
        return Icons.search_off;
      case BcResultStatus.forbidden403:
        return Icons.lock_outline;
      case BcResultStatus.serverError500:
        return Icons.cloud_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _statusIcon(),
              size: 64,
              color: color,
            ),
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: BcTheme.foreground,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: BcTheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
