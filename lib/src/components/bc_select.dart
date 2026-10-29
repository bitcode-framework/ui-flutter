library bc_select;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Option for BcSelect dropdown items.
class BcSelectOption<T> {
  final T value;
  final String label;
  final bool disabled;

  const BcSelectOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
}

/// Adaptive select dropdown (ADR-011 Section 5).
/// Material: DropdownButtonFormField. Cupertino: CupertinoButton + showCupertinoModalPopup.
class BcSelect<T> extends StatefulWidget {
  final String? name;
  final T? value;
  final T? defaultValue;
  final List<BcSelectOption<T>> options;
  final BcChangeHandler<T>? onValueChange;
  final bool disabled;
  final String? placeholder;
  final String? label;

  const BcSelect({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    required this.options,
    this.onValueChange,
    this.disabled = false,
    this.placeholder,
    this.label,
  });

  @override
  State<BcSelect<T>> createState() => _BcSelectState<T>();
}

class _BcSelectState<T> extends State<BcSelect<T>> {
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? widget.defaultValue;
  }

  @override
  void didUpdateWidget(BcSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
    }
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
    final field = PlatformWidget(
      material: (context, platform) => DropdownButtonFormField<T>(
        initialValue: _selected,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.placeholder,
          border: const OutlineInputBorder(),
        ),
        disabledHint: _selectedLabel != null ? Text(_selectedLabel!) : null,
        items: widget.options
            .map((o) => DropdownMenuItem<T>(
                  value: o.value,
                  enabled: !o.disabled,
                  child: Text(o.label),
                ))
            .toList(),
        onChanged: widget.disabled ? null : (v) => v != null ? _select(v) : null,
      ),
      cupertino: (context, platform) => GestureDetector(
        onTap: widget.disabled ? null : () => _showCupertinoPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.separator),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_selectedLabel ?? widget.placeholder ?? '',
                  style: TextStyle(
                    color: _selected != null
                        ? CupertinoColors.label
                        : CupertinoColors.placeholderText,
                  )),
              const Icon(CupertinoIcons.chevron_down, size: 16),
            ],
          ),
        ),
      ),
    );

    return field;
  }

  void _showCupertinoPicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController: FixedExtentScrollController(
            initialItem: widget.options.indexWhere((o) => o.value == _selected).clamp(0, widget.options.length - 1),
          ),
          onSelectedItemChanged: (i) {
            final opt = widget.options[i];
            if (!opt.disabled) _select(opt.value);
          },
          children: widget.options.map((o) => Text(o.label)).toList(),
        ),
      ),
    );
  }
}
