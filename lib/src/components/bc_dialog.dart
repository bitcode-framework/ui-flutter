library bc_dialog;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Adaptive dialog (ADR-011 Section 5).
/// Material: showDialog + AlertDialog. Cupertino: showCupertinoDialog + CupertinoAlertDialog.
class BcDialog {
  BcDialog._();

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required Widget content,
    String? confirmText,
    String? cancelText,
    bool barrierDismissible = true,
  }) {
    return showPlatformDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      material: MaterialDialogData(
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelText),
              ),
            if (confirmText != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmText),
              ),
          ],
        ),
      ),
      cupertino: CupertinoDialogData(
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelText),
              ),
            if (confirmText != null)
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmText),
              ),
          ],
        ),
      ),
    );
  }
}
