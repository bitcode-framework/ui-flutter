library bc_native_actionsheet;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Item shape for [BcNativeActionSheet] (ADR-006).
class BcNativeActionSheetItem {
  final String label;
  final String value;
  final bool destructive;
  final bool disabled;

  const BcNativeActionSheetItem({
    required this.label,
    required this.value,
    this.destructive = false,
    this.disabled = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcNativeActionSheetItem &&
          label == other.label &&
          value == other.value &&
          destructive == other.destructive &&
          disabled == other.disabled;

  @override
  int get hashCode => Object.hash(label, value, destructive, disabled);
}

/// Platform-idiomatic action sheet (ADR-006 Adapt POC, ADR-011).
///
/// iOS: `CupertinoActionSheet` via `showCupertinoModalPopup`. Android:
/// Material `showModalBottomSheet`. Triggered via the static [show] method
/// (overlay pattern, like [BcDialog]).
///
/// Distinct from BcNativeAlert (binary confirm/cancel): this dispatches a
/// chosen item from [items] and supports per-item `destructive`/`disabled`
/// flags. Always bottom-anchored.
class BcNativeActionSheet {
  BcNativeActionSheet._();

  /// Shows the action sheet overlay. Returns the selected item value (or
  /// null if dismissed without selection).
  static Future<String?> show({
    required BuildContext context,
    required List<BcNativeActionSheetItem> items,
    String? title,
    String? cancelLabel,
  }) {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;

    if (isIOS) {
      return _showCupertino(
          context, items, title, cancelLabel ?? bcI18n.t('bc.nativeActionSheet.defaultCancelLabel'));
    }
    return _showMaterial(
        context, items, title, cancelLabel ?? bcI18n.t('bc.nativeActionSheet.defaultCancelLabel'));
  }

  static Future<String?> _showCupertino(
    BuildContext context,
    List<BcNativeActionSheetItem> items,
    String? title,
    String cancelLabel,
  ) {
    return showCupertinoModalPopup<String?>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        key: const Key('bc-native-actionsheet-sheet'),
        title: title != null ? Text(title) : null,
        actions: items
            .where((i) => !i.disabled)
            .map((item) => CupertinoActionSheetAction(
                  isDestructiveAction: item.destructive,
                  onPressed: () => Navigator.pop(ctx, item.value),
                  child: Text(item.label),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, null),
          child: Text(cancelLabel),
        ),
      ),
    );
  }

  static Future<String?> _showMaterial(
    BuildContext context,
    List<BcNativeActionSheetItem> items,
    String? title,
    String cancelLabel,
  ) {
    return showModalBottomSheet<String?>(
      context: context,
      backgroundColor: BcTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BcTheme.radius),
        ),
      ),
      builder: (ctx) => SafeArea(
        key: const Key('bc-native-actionsheet-bottomsheet'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Container(
                key: const Key('bc-native-actionsheet-title'),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: BcTheme.border),
                  ),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BcTheme.foreground,
                  ),
                ),
              ),
            ...items.map((item) {
              final labelColor = item.destructive
                  ? BcTheme.destructive
                  : item.disabled
                      ? BcTheme.mutedForeground
                      : BcTheme.foreground;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  key: ValueKey<String>(
                      'bc-native-actionsheet-item-${item.value}'),
                  title: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: labelColor),
                  ),
                  enabled: !item.disabled,
                  onTap: item.disabled
                      ? null
                      : () => Navigator.pop(ctx, item.value),
                ),
              );
            }),
            const Divider(height: 8, thickness: 8, color: BcTheme.muted),
            Material(
              color: Colors.transparent,
              child: ListTile(
                key: const Key('bc-native-actionsheet-cancel'),
                title: Text(
                  cancelLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BcTheme.foreground,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Convenience: shows the action sheet and invokes [onSelect] with the
  /// chosen item + a `BcChangeMeta` (reason `select`), or [onCancel]
  /// otherwise. Mirrors the controlled React contract's callback props.
  static Future<void> showWithCallbacks({
    required BuildContext context,
    required List<BcNativeActionSheetItem> items,
    String? title,
    String? cancelLabel,
    void Function(BcNativeActionSheetItem, BcChangeMeta)? onSelect,
    BcChangeHandler<void>? onCancel,
  }) async {
    const metaSelect = BcChangeMeta(
      reason: BcChangeReason.select,
      source: BcEventSource.pointer,
    );
    const metaCancel = BcChangeMeta(
      reason: BcChangeReason.cancel,
      source: BcEventSource.pointer,
    );
    final result = await show(
      context: context,
      items: items,
      title: title,
      cancelLabel: cancelLabel,
    );
    if (result != null) {
      final match =
          items.where((i) => i.value == result).toList(growable: false);
      if (match.isNotEmpty) {
        onSelect?.call(match.first, metaSelect);
      }
    } else {
      onCancel?.call(null, metaCancel);
    }
  }
}
