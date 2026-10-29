library bc_native_toast;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Platform-idiomatic ephemeral toast (ADR-006 Adapt POC, ADR-011).
///
/// iOS: overlay card (no native counterpart). Android: Snackbar idiom. Web:
/// bottom-anchored overlay with role=status. Auto-closes after [duration]
/// (default 3000ms). Non-blocking and announces via the polite live region.
///
/// Controlled mode: parent manages [open]; the toast is shown or hidden
/// based on the prop. Uncontrolled: [defaultOpen] seeds the initial state.
/// Setting [duration] to [Duration.zero] disables auto-close.
class BcNativeToast extends StatefulWidget {
  /// Controlled open state. When non-null, the widget is controlled.
  final bool? open;

  /// Initial open state for uncontrolled mode. Default false.
  final bool defaultOpen;

  /// Toast message text.
  final String message;

  /// Optional action button label. When provided, an action button renders.
  final String? actionLabel;

  /// Auto-close duration. Default 3000ms. [Duration.zero] disables auto-close.
  final Duration duration;

  /// Allow manual dismissal (close affordance). Default true.
  final bool dismissible;

  /// Called when the action button is pressed (carries a `BcChangeMeta`
  /// with reason `submit`).
  final BcChangeHandler<void>? onAction;

  /// Called when the toast is dismissed (auto-close, manual, or action).
  final BcChangeHandler<void>? onClose;

  const BcNativeToast({
    super.key,
    this.open,
    this.defaultOpen = false,
    required this.message,
    this.actionLabel,
    this.duration = const Duration(seconds: 3),
    this.dismissible = true,
    this.onAction,
    this.onClose,
  });

  @override
  State<BcNativeToast> createState() => _BcNativeToastState();
}

class _BcNativeToastState extends State<BcNativeToast> {
  Timer? _autoCloseTimer;
  bool _internalOpen = false;
  bool _internallyDismissed = false;

  bool get _isControlled => widget.open != null;

  bool get _isOpen =>
      _isControlled ? (widget.open! && !_internallyDismissed) : _internalOpen;

  @override
  void initState() {
    super.initState();
    _internalOpen = widget.defaultOpen;
    _scheduleAutoClose();
  }

  @override
  void didUpdateWidget(covariant BcNativeToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset internal dismiss when parent re-opens (controlled mode).
    if (widget.open != null && oldWidget.open != null) {
      if (widget.open! && !oldWidget.open!) {
        _internallyDismissed = false;
      }
    }
    if (widget.duration != oldWidget.duration) {
      _cancelAutoClose();
      _scheduleAutoClose();
    }
  }

  void _scheduleAutoClose() {
    _cancelAutoClose();
    if (!_isOpen) return;
    if (widget.duration == Duration.zero) return;
    _autoCloseTimer = Timer(widget.duration, _handleAutoClose);
  }

  void _cancelAutoClose() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
  }

  void _handleAutoClose() {
    _autoCloseTimer = null;
    _dismiss(
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.programmatic,
      ),
    );
  }

  void _handleManualClose() {
    _cancelAutoClose();
    _dismiss(
      const BcChangeMeta(
        reason: BcChangeReason.clear,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handleAction() {
    widget.onAction?.call(
      null,
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
    _cancelAutoClose();
    _dismiss(
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _dismiss(BcChangeMeta meta) {
    if (!_isControlled) {
      setState(() => _internalOpen = false);
    } else {
      setState(() => _internallyDismissed = true);
    }
    widget.onClose?.call(null, meta);
  }

  @override
  void dispose() {
    _cancelAutoClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOpen) return const SizedBox.shrink();

    final action = widget.actionLabel;

    return Semantics(
      container: true,
      label: widget.message,
      enabled: true,
      focusable: true,
      role: SemanticsRole.status,
      child: ExcludeSemantics(
        child: Container(
          key: const Key('bc-native-toast'),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: BcTheme.foreground,
            borderRadius: BorderRadius.circular(BcTheme.radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.message,
                  key: const Key('bc-native-toast-message'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: BcTheme.background,
                  ),
                ),
              ),
              if (action != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: TextButton(
                    key: const Key('bc-native-toast-action'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: BcTheme.primary,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _handleAction,
                    child: Text(action),
                  ),
                ),
              if (widget.dismissible)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    key: const Key('bc-native-toast-close'),
                    icon: const Icon(Icons.close, size: 18),
                    color: BcTheme.background.withValues(alpha: 0.7),
                    tooltip: bcI18n.t('bc.nativeToast.dismissAriaLabel'),
                    onPressed: _handleManualClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
