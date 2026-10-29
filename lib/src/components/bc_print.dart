library bc_print;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Visual style variant for the print button.
enum BcPrintVariant {
  /// Solid primary background with white text.
  defaultVariant,

  /// No background, text/icon only (ghost).
  ghost,

  /// Bordered outline style.
  outline,
}

/// Print button that triggers a print flow.
///
/// Mirrors TS `BcPrintContract`. Tapping the button fires [onBeforePrint]
/// (if set), then either emits [onPrint] immediately (when [confirm] is
/// false) or shows a confirmation dialog first (when [confirm] is true).
/// On confirmation, [onPrint] is invoked with the [target] ref and meta.
///
/// Platform-aware: Material uses [AlertDialog]; Cupertino uses
/// [CupertinoAlertDialog] on iOS/macOS.
class BcPrint extends StatefulWidget {
  /// Label text on the button. Defaults to "Print".
  final String? label;

  /// The report or target ref passed to [onPrint].
  final String? target;

  /// Disables the button entirely.
  final bool disabled;

  /// When true, shows a confirmation dialog before emitting [onPrint].
  final bool confirm;

  /// Visual variant of the button.
  final BcPrintVariant variant;

  /// Fires before the dialog opens or print fires (synchronous hook).
  final void Function()? onBeforePrint;

  /// Callback when print executes. Carries the target ref and meta.
  final void Function(String ref, BcChangeMeta meta)? onPrint;

  const BcPrint({
    super.key,
    this.label,
    this.target,
    this.disabled = false,
    this.confirm = false,
    this.variant = BcPrintVariant.defaultVariant,
    this.onBeforePrint,
    this.onPrint,
  });

  @override
  State<BcPrint> createState() => _BcPrintState();
}

class _BcPrintState extends State<BcPrint> {
  void _handleTap() {
    if (widget.disabled) return;

    widget.onBeforePrint?.call();

    if (widget.confirm) {
      _showConfirmDialog();
    } else {
      _emitPrint();
    }
  }

  void _showConfirmDialog() {
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => CupertinoAlertDialog(
          key: const Key('bc-print-dialog'),
          title: const Text('Print Report'),
          content: const Text('Do you want to print this report?'),
          actions: [
            CupertinoDialogAction(
              key: const Key('bc-print-cancel'),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              key: const Key('bc-print-confirm'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                _emitPrint();
              },
              child: const Text('Print'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        key: const Key('bc-print-dialog'),
        title: const Text('Print Report'),
        content: const Text('Do you want to print this report?'),
        actions: [
          TextButton(
            key: const Key('bc-print-cancel'),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('bc-print-confirm'),
            onPressed: () {
              Navigator.pop(dialogContext);
              _emitPrint();
              },
            child: const Text('Print'),
          ),
        ],
      ),
    );
  }

  void _emitPrint() {
    final ref = widget.target ?? '';
    const meta = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
    widget.onPrint?.call(ref, meta);
  }

  Widget _buildMaterialButton() {
    final isDisabled = widget.disabled;
    final labelText = widget.label ?? 'Print';

    switch (widget.variant) {
      case BcPrintVariant.ghost:
        return GestureDetector(
          key: const Key('bc-print-button'),
          onTap: isDisabled ? null : _handleTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.print_outlined,
                  size: 18,
                  color: isDisabled
                      ? BcTheme.mutedForeground
                      : BcTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? BcTheme.mutedForeground
                        : BcTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );

      case BcPrintVariant.outline:
        return GestureDetector(
          key: const Key('bc-print-button'),
          onTap: isDisabled ? null : _handleTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(BcTheme.radius),
              border: Border.all(
                color: isDisabled ? BcTheme.border : BcTheme.primary,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.print_outlined,
                  size: 18,
                  color: isDisabled
                      ? BcTheme.mutedForeground
                      : BcTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? BcTheme.mutedForeground
                        : BcTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );

      case BcPrintVariant.defaultVariant:
        return GestureDetector(
          key: const Key('bc-print-button'),
          onTap: isDisabled ? null : _handleTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDisabled ? BcTheme.muted : BcTheme.primary,
              borderRadius: BorderRadius.circular(BcTheme.radius),
              border: Border.all(
                color: isDisabled ? BcTheme.border : BcTheme.primary,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.print_outlined,
                  size: 18,
                  color: isDisabled
                      ? BcTheme.mutedForeground
                      : BcTheme.primaryForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? BcTheme.mutedForeground
                        : BcTheme.primaryForeground,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildCupertinoButton() {
    final isDisabled = widget.disabled;
    final labelText = widget.label ?? 'Print';

    if (widget.variant == BcPrintVariant.ghost) {
      return GestureDetector(
        key: const Key('bc-print-button'),
        onTap: isDisabled ? null : _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.printer,
                size: 18,
                color: isDisabled
                    ? BcTheme.mutedForeground
                    : BcTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                labelText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? BcTheme.mutedForeground
                      : BcTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      key: const Key('bc-print-button'),
      onTap: isDisabled ? null : _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDisabled ? BcTheme.muted : BcTheme.primary,
          borderRadius: BorderRadius.circular(BcTheme.radius),
          border: Border.all(
            color: isDisabled ? BcTheme.border : BcTheme.primary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.printer,
              size: 18,
              color: isDisabled
                  ? BcTheme.mutedForeground
                  : BcTheme.primaryForeground,
            ),
            const SizedBox(width: 8),
            Text(
              labelText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDisabled
                    ? BcTheme.mutedForeground
                    : BcTheme.primaryForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return isCupertino ? _buildCupertinoButton() : _buildMaterialButton();
  }
}
