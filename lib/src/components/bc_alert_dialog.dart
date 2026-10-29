library bc_alert_dialog;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Adaptive alert dialog — simplified dialog with only a confirm button (ADR-011 Section 5).
class BcAlertDialog {
  BcAlertDialog._();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required Widget content,
    String? dismissText,
  }) {
    return showPlatformDialog<void>(
      context: context,
      material: MaterialDialogData(
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(dismissText ?? 'OK'),
            ),
          ],
        ),
      ),
      cupertino: CupertinoDialogData(
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: Text(dismissText ?? 'OK'),
            ),
          ],
        ),
      ),
    );
  }
}
