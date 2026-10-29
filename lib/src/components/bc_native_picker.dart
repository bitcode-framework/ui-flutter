library bc_native_picker;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../core/bc_i18n.dart';
import '../theme/bc_theme.dart';

/// Option shape for [BcNativePicker] (ADR-006).
class BcNativePickerOption {
  final String label;
  final String value;

  const BcNativePickerOption({required this.label, required this.value});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcNativePickerOption &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// Platform-idiomatic value picker overlay (ADR-006 Adapt POC, ADR-011).
///
/// iOS: `CupertinoPicker` wheel inside a bottom sheet. Android: Material
/// dialog picker (single-choice radio list). Triggered via the static
/// [show] method (overlay pattern, like [BcDialog]).
///
/// Resolves to a single value and exposes a [title] header. Selecting an
/// option invokes [onValueChange] with a `BcChangeMeta` (reason `select`),
/// then dismisses.
class BcNativePicker {
  BcNativePicker._();

  /// Shows the picker overlay. Returns the selected value (or null if
  /// dismissed without selection).
  static Future<String?> show({
    required BuildContext context,
    required List<BcNativePickerOption> options,
    String? value,
    String? title,
    String? placeholder,
  }) {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;

    if (isIOS) {
      return _showCupertino(context, options, value, title);
    }
    return _showMaterial(context, options, value, title, placeholder);
  }

  static Future<String?> _showCupertino(
    BuildContext context,
    List<BcNativePickerOption> options,
    String? value,
    String? title,
  ) async {
    final initial = options.indexWhere((o) => o.value == value).clamp(
      0,
      options.isEmpty ? 0 : options.length - 1,
    );
    final controller = FixedExtentScrollController(initialItem: initial);

    final result = await showCupertinoModalPopup<String?>(
      context: context,
      builder: (ctx) => Container(
        key: const Key('bc-native-picker-sheet'),
        height: 280,
        color: BcTheme.background,
        child: Column(
          children: [
            if (title != null)
              Container(
                key: const Key('bc-native-picker-title'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
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
            Expanded(
              child: CupertinoPicker(
                key: const Key('bc-native-picker-wheel'),
                scrollController: controller,
                itemExtent: 36,
                onSelectedItemChanged: (_) {},
                children: options
                    .map((o) => Center(
                          key: ValueKey<String>(
                              'bc-native-picker-option-${o.value}'),
                          child: Text(
                            o.label,
                            style: const TextStyle(color: BcTheme.foreground),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Container(
              key: const Key('bc-native-picker-done'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: BcTheme.border),
                ),
              ),
              child: CupertinoButton(
                key: const Key('bc-native-picker-done-button'),
                onPressed: () {
                  final i = controller.selectedItem.clamp(
                    0,
                    options.isEmpty ? 0 : options.length - 1,
                  );
                  Navigator.pop(ctx, options[i].value);
                },
                child: Text(
                  bcI18n.t('bc.nativePicker.doneButton'),
                  style: const TextStyle(color: BcTheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    return result;
  }

  static Future<String?> _showMaterial(
    BuildContext context,
    List<BcNativePickerOption> options,
    String? value,
    String? title,
    String? placeholder,
  ) {
    return showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('bc-native-picker-dialog'),
        title: title != null ? Text(title) : null,
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            key: const Key('bc-native-picker-list'),
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (innerCtx, i) {
              final opt = options[i];
              final isSelected = opt.value == value;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  key: ValueKey<String>(
                      'bc-native-picker-option-${opt.value}'),
                  title: Text(opt.label),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: BcTheme.primary)
                      : null,
                  onTap: () => Navigator.pop(innerCtx, opt.value),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            key: const Key('bc-native-picker-cancel'),
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(bcI18n.t('bc.nativePicker.cancelButton')),
          ),
        ],
      ),
    );
  }
}
