library bc_native_alert;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Platform-idiomatic confirmation alert (ADR-006 Adapt POC, ADR-011).
///
/// iOS: `CupertinoAlertDialog`. Android: Material `AlertDialog`. Triggered
/// via the static [show] method (overlay pattern, like [BcDialog]).
///
/// Simpler native idiom than BcDialog: title + message + confirm/cancel
/// only. The [destructive] flag renders the confirm button with the
/// destructive token color (for delete/irreversible confirmations).
class BcNativeAlert {
  BcNativeAlert._();

  /// Shows the alert overlay. Returns `true` if confirmed, `false` if
  /// cancelled, `null` if dismissed (scrim/Escape).
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
  }) {
    final effectiveConfirmLabel =
        confirmLabel ?? bcI18n.t('bc.nativeAlert.defaultConfirmLabel');
    final confirmColor =
        destructive ? BcTheme.destructive : BcTheme.primary;

    return showPlatformDialog<bool>(
      context: context,
      barrierDismissible: true,
      material: MaterialDialogData(
        builder: (ctx) => AlertDialog(
          key: const Key('bc-native-alert-dialog'),
          title: title != null ? Text(title) : null,
          content: message != null ? Text(message) : null,
          actions: [
            if (cancelLabel != null)
              TextButton(
                key: const Key('bc-native-alert-cancel'),
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelLabel),
              ),
            TextButton(
              key: const Key('bc-native-alert-confirm'),
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: confirmColor),
              child: Text(effectiveConfirmLabel),
            ),
          ],
        ),
      ),
      cupertino: CupertinoDialogData(
        builder: (ctx) => CupertinoAlertDialog(
          key: const Key('bc-native-alert-cupertino'),
          title: title != null ? Text(title) : null,
          content: message != null ? Text(message) : null,
          actions: [
            if (cancelLabel != null)
              CupertinoDialogAction(
                key: const Key('bc-native-alert-cancel-cupertino'),
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelLabel),
              ),
            CupertinoDialogAction(
              key: const Key('bc-native-alert-confirm-cupertino'),
              isDestructiveAction: destructive,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(effectiveConfirmLabel),
            ),
          ],
        ),
      ),
    );
  }

  /// Convenience: shows a confirmation alert and invokes [onConfirm] when
  /// the user confirms (true), [onCancel] otherwise. Mirrors the controlled
  /// React contract's callback props.
  static Future<void> showWithCallbacks({
    required BuildContext context,
    String? title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
    BcChangeHandler<void>? onConfirm,
    BcChangeHandler<void>? onCancel,
  }) async {
    const metaConfirm = BcChangeMeta(
      reason: BcChangeReason.confirm,
      source: BcEventSource.pointer,
    );
    const metaCancel = BcChangeMeta(
      reason: BcChangeReason.cancel,
      source: BcEventSource.pointer,
    );
    final result = await show(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    );
    if (result == true) {
      onConfirm?.call(null, metaConfirm);
    } else if (result == false) {
      onCancel?.call(null, metaCancel);
    }
  }
}
