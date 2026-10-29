library bc_checkbox;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Adaptive checkbox (ADR-011 Section 5).
/// Material: Checkbox. Cupertino: CupertinoCheckbox (FPW maps automatically).
class BcCheckbox extends StatelessWidget {
  final String? name;
  final bool? value;
  final bool? defaultValue;
  final BcChangeHandler<bool>? onValueChange;
  final bool disabled;
  final String? label;

  const BcCheckbox({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.disabled = false,
    this.label,
  });

  void _handleChange(bool? checked) {
    if (checked == null) return;
    onValueChange?.call(
      checked,
      const BcChangeMeta(reason: BcChangeReason.toggle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkbox = PlatformCheckbox(
      value: value ?? defaultValue ?? false,
      onChanged: disabled ? null : _handleChange,
    );

    if (label == null) return checkbox;

    return InkWell(
      onTap: disabled ? null : () => _handleChange(!(value ?? defaultValue ?? false)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: 8),
          Text(label!),
        ],
      ),
    );
  }
}
