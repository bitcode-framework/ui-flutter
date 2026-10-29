library bc_toggle;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Adaptive toggle/switch (ADR-011 Section 5).
/// Material: Switch. Cupertino: CupertinoSwitch (FPW maps automatically).
class BcToggle extends StatelessWidget {
  final String? name;
  final bool? value;
  final bool? defaultValue;
  final BcChangeHandler<bool>? onValueChange;
  final bool disabled;
  final String? label;

  const BcToggle({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.disabled = false,
    this.label,
  });

  void _handleChange(bool checked) {
    onValueChange?.call(
      checked,
      const BcChangeMeta(reason: BcChangeReason.toggle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toggle = PlatformSwitch(
      value: value ?? defaultValue ?? false,
      onChanged: disabled ? null : _handleChange,
    );

    if (label == null) return toggle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        toggle,
        const SizedBox(width: 8),
        Text(label!),
      ],
    );
  }
}
