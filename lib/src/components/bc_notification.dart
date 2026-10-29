library bc_notification;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Severity variant for the notification banner.
///
/// Mirrors TS `BcNotificationStatus` ('info' | 'success' | 'warning' | 'error').
/// Each variant resolves to a distinct [BcTheme] color token via [accent],
/// [foreground], and [background].
enum BcNotificationSeverity {
  info,
  success,
  warning,
  danger;

  /// Accent / icon / border color token.
  Color get accent {
    switch (this) {
      case BcNotificationSeverity.info:
        return BcTheme.info;
      case BcNotificationSeverity.success:
        return BcTheme.success;
      case BcNotificationSeverity.warning:
        return BcTheme.warning;
      case BcNotificationSeverity.danger:
        return BcTheme.destructive;
    }
  }

  /// Foreground (text) color token for the banner.
  Color get foreground {
    switch (this) {
      case BcNotificationSeverity.info:
        return BcTheme.infoForeground;
      case BcNotificationSeverity.success:
        return BcTheme.successForeground;
      case BcNotificationSeverity.warning:
        return BcTheme.warningForeground;
      case BcNotificationSeverity.danger:
        return BcTheme.destructiveForeground;
    }
  }

  /// Background tint color (10% opacity of the accent).
  Color get background => accent.withValues(alpha: 0.1);

  /// Whether this variant should expose `role=alert` semantics.
  bool get isAlert => this == BcNotificationSeverity.danger;

  /// The icon data for the variant.
  IconData get icon {
    switch (this) {
      case BcNotificationSeverity.info:
        return Icons.info_outline;
      case BcNotificationSeverity.success:
        return Icons.check_circle_outline;
      case BcNotificationSeverity.warning:
        return Icons.warning_amber_outlined;
      case BcNotificationSeverity.danger:
        return Icons.error_outline;
    }
  }
}

/// Inline notification banner with severity variants.
///
/// Mirrors the TS `BcNotificationContract`: an inline (non-modal) banner
/// that displays [title] and [description] with a severity-colored accent.
/// Supports an optional [actionLabel]/[onAction] and manual [closable]
/// dismiss control.
///
/// Controlled mode: the parent manages [open]; the banner is shown or hidden
/// based on the prop value. [onDismiss] is called with `false` when the user
/// manually dismisses, or when the auto-dismiss timer fires.
///
/// Auto-dismiss: when [autoDismissDuration] is non-null and positive, a timer
/// fires after the duration and invokes [onDismiss] with
/// `BcEventSource.programmatic`. A null or zero duration keeps the banner
/// persistent until manually dismissed.
///
/// Accessibility: non-danger variants expose `role=status` (live region,
/// polite) while the danger variant exposes `role=alert` (assertive). The
/// message text is reachable as the semantic label.
class BcNotification extends StatefulWidget {
  /// Whether the banner is currently shown.
  final bool open;

  /// The title text (bold, prominent).
  final String? title;

  /// The description / body text.
  final String? description;

  /// The severity variant.
  final BcNotificationSeverity severity;

  /// Optional action button label. When provided, an action button renders.
  final String? actionLabel;

  /// Whether to show the close (dismiss) control.
  final bool closable;

  /// Auto-dismiss duration. When non-null and positive, the banner
  /// auto-dismisses after this duration.
  final Duration? autoDismissDuration;

  /// Called when the banner is dismissed (either manually or via timer).
  /// The value is `true` if dismissed via auto-timer, `false` if manual.
  final BcChangeHandler<bool>? onDismiss;

  /// Called when the action button is pressed.
  final VoidCallback? onAction;

  const BcNotification({
    super.key,
    this.open = true,
    this.title,
    this.description,
    this.severity = BcNotificationSeverity.info,
    this.actionLabel,
    this.closable = true,
    this.autoDismissDuration,
    this.onDismiss,
    this.onAction,
  });

  @override
  State<BcNotification> createState() => _BcNotificationState();
}

class _BcNotificationState extends State<BcNotification> {
  Timer? _autoDismissTimer;
  bool _internallyDismissed = false;

  @override
  void initState() {
    super.initState();
    _scheduleAutoDismiss();
  }

  @override
  void didUpdateWidget(covariant BcNotification oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset internal dismiss when parent re-opens.
    if (widget.open && !oldWidget.open) {
      _internallyDismissed = false;
    }
    if (widget.autoDismissDuration != oldWidget.autoDismissDuration ||
        widget.open != oldWidget.open) {
      _cancelAutoDismiss();
      _scheduleAutoDismiss();
    }
  }

  void _scheduleAutoDismiss() {
    _cancelAutoDismiss();
    if (!widget.open) return;
    final duration = widget.autoDismissDuration;
    if (duration == null || duration.inMilliseconds <= 0) return;

    _autoDismissTimer = Timer(duration, _handleAutoDismiss);
  }

  void _cancelAutoDismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
  }

  void _handleAutoDismiss() {
    _autoDismissTimer = null;
    setState(() => _internallyDismissed = true);
    widget.onDismiss?.call(
      true,
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.programmatic,
      ),
    );
  }

  void _handleManualDismiss() {
    _cancelAutoDismiss();
    setState(() => _internallyDismissed = true);
    widget.onDismiss?.call(
      false,
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  void dispose() {
    _cancelAutoDismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open || _internallyDismissed) return const SizedBox.shrink();

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
      // alert/status roles already imply live region behavior.
      role: severity.isAlert ? SemanticsRole.alert : SemanticsRole.status,
      child: ExcludeSemantics(
        child: Container(
          key: const Key('bc-notification-banner'),
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

  Widget _buildContent(BuildContext context, BcNotificationSeverity severity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              if (widget.actionLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const Key('bc-notification-action'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: severity.accent,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: widget.onAction,
                      child: Text(widget.actionLabel!),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.closable)
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              key: const Key('bc-notification-close'),
              icon: const Icon(Icons.close, size: 18),
              color: BcTheme.mutedForeground,
              tooltip: 'Close notification',
              onPressed: _handleManualDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ),
      ],
    );
  }
}
