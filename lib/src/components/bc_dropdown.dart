library bc_dropdown;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import 'bc_select.dart';

/// Adaptive dropdown menu (ADR-011 Section 5).
///
/// A thin wrapper over [BcSelect] with a trigger button instead of form field.
/// Material: MenuButton / PopupMenuButton. Cupertino: CupertinoButton + popup.
class BcDropdown<T> extends StatefulWidget {
  final String? name;
  final T? value;
  final T? defaultValue;
  final List<BcSelectOption<T>> options;
  final BcChangeHandler<T>? onValueChange;
  final bool disabled;
  final Widget? trigger;
  final String? placeholder;

  const BcDropdown({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    required this.options,
    this.onValueChange,
    this.disabled = false,
    this.trigger,
    this.placeholder,
  });

  @override
  State<BcDropdown<T>> createState() => _BcDropdownState<T>();
}

class _BcDropdownState<T> extends State<BcDropdown<T>> {
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? widget.defaultValue;
  }

  void _select(T value) {
    setState(() => _selected = value);
    widget.onValueChange?.call(
      value,
      const BcChangeMeta(reason: BcChangeReason.select),
    );
  }

  String? get _selectedLabel {
    if (_selected == null) return null;
    final opt = widget.options.where((o) => o.value == _selected).toList();
    return opt.isNotEmpty ? opt.first.label : null;
  }

  @override
  Widget build(BuildContext context) {
    final trigger = widget.trigger ??
        PlatformWidget(
          material: (context, platform) => TextButton.icon(
            onPressed: widget.disabled ? null : () => _showMaterialMenu(context),
            icon: const Icon(Icons.arrow_drop_down),
            label: Text(_selectedLabel ?? widget.placeholder ?? 'Select'),
          ),
          cupertino: (context, platform) => CupertinoButton(
            onPressed: widget.disabled ? null : () => _showCupertinoSheet(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedLabel ?? widget.placeholder ?? 'Select'),
                const Icon(CupertinoIcons.chevron_down, size: 16),
              ],
            ),
          ),
        );

    return trigger;
  }

  void _showMaterialMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<T>(
      context: context,
      position: position,
      items: widget.options
          .map((o) => PopupMenuItem<T>(
                value: o.value,
                enabled: !o.disabled,
                child: Text(o.label),
              ))
          .toList(),
    ).then((v) => v != null ? _select(v) : null);
  }

  void _showCupertinoSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: widget.options
            .map((o) => CupertinoActionSheetAction(
                  onPressed: () {
                    _select(o.value);
                    Navigator.pop(context);
                  },
                  child: Text(o.label),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
