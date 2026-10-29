library bc_alert;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Severity variant for the inline alert banner.
///
/// Mirrors TS `BcAlertSeverity` ('info' | 'success' | 'warning' | 'error').
/// Each variant resolves to a distinct [BcTheme] color token via [accent],
/// [foreground], and [background].
enum BcAlertSeverity {
  info,
  success,
  warning,
  error;

  Color get accent {
    switch (this) {
      case BcAlertSeverity.info:
        return BcTheme.info;
      case BcAlertSeverity.success:
        return BcTheme.success;
      case BcAlertSeverity.warning:
        return BcTheme.warning;
      case BcAlertSeverity.error:
        return BcTheme.destructive;
    }
  }

  Color get foreground {
    switch (this) {
      case BcAlertSeverity.info:
        return BcTheme.infoForeground;
      case BcAlertSeverity.success:
        return BcTheme.successForeground;
      case BcAlertSeverity.warning:
        return BcTheme.warningForeground;
      case BcAlertSeverity.error:
        return BcTheme.destructiveForeground;
    }
  }

  Color get background => accent.withValues(alpha: 0.1);

  bool get isAlert => this == BcAlertSeverity.error;

  IconData get icon {
    switch (this) {
      case BcAlertSeverity.info:
        return Icons.info_outline;
      case BcAlertSeverity.success:
        return Icons.check_circle_outline;
      case BcAlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case BcAlertSeverity.error:
        return Icons.error_outline;
    }
  }
}

/// Reason the alert was dismissed.
enum BcAlertDismissReason { closeButton, programmatic }

/// Persistent inline alert banner (ADR-007 contract parity).
///
/// Distinct from [BcNotification] by contract scope: persistent (no
/// auto-dismiss, no action button), intended for in-flow form/page
/// validation messages and static notices. The TS contract is narrower:
/// 4 severity variants, dismissible control, hideIcon, no `open` prop
/// (visibility driven by presence of content).
///
/// Once dismissed, the parent must remount the widget to bring it back.
class BcAlert extends StatefulWidget {
  final BcAlertSeverity severity;
  final String? title;
  final String? description;
  final bool dismissible;
  final bool hideIcon;
  final String? ariaLabel;
  final BcChangeHandler<bool>? onDismiss;
  final Widget? child;

  const BcAlert({
    super.key,
    this.severity = BcAlertSeverity.info,
    this.title,
    this.description,
    this.dismissible = false,
    this.hideIcon = false,
    this.ariaLabel,
    this.onDismiss,
    this.child,
  });

  @override
  State<BcAlert> createState() => _BcAlertState();
}

class _BcAlertState extends State<BcAlert> {
  bool _dismissed = false;

  void _handleDismiss() {
    setState(() => _dismissed = true);
    widget.onDismiss?.call(
      true,
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final severity = widget.severity;
    final semanticLabel = <String>[
      if (widget.title != null) widget.title!,
      if (widget.description != null) widget.description!,
    ].join(' ');

    return Semantics(
      container: true,
      label: semanticLabel.isEmpty ? null : semanticLabel,
      enabled: true,
      focusable: true,
      role: severity.isAlert ? SemanticsRole.alert : SemanticsRole.status,
      child: ExcludeSemantics(
        child: Container(
          key: const Key('bc-alert-banner'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: severity.background,
            borderRadius: BorderRadius.circular(BcTheme.radius),
            border: Border.all(
              color: severity.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: _buildContent(context, severity),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BcAlertSeverity severity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.hideIcon)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 2),
            child: Icon(severity.icon, size: 20, color: severity.accent),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: severity.accent,
                    ),
                  ),
                ),
              if (widget.description != null)
                Text(
                  widget.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: severity.foreground.withValues(alpha: 0.9),
                  ),
                ),
              if (widget.child != null) ...[const SizedBox(height: 8), widget.child!],
            ],
          ),
        ),
        if (widget.dismissible)
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              key: const Key('bc-alert-close'),
              icon: const Icon(Icons.close, size: 18),
              color: BcTheme.mutedForeground,
              tooltip: bcI18n.t('bc.alert.dismiss'),
              onPressed: _handleDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
      ],
    );
  }
}
