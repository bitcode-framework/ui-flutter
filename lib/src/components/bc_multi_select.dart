library bc_multi_select;

import 'package:flutter/material.dart';
import '../core/types.dart';

/// Material-only multi-select (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart.
class BcMultiSelect<T> extends StatefulWidget {
  final String? name;
  final List<T>? value;
  final List<T>? defaultValue;
  final List<BcMultiSelectOption<T>> options;
  final BcChangeHandler<List<T>>? onValueChange;
  final bool disabled;
  final String? label;
  final String? placeholder;

  const BcMultiSelect({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    required this.options,
    this.onValueChange,
    this.disabled = false,
    this.label,
    this.placeholder,
  });

  @override
  State<BcMultiSelect<T>> createState() => _BcMultiSelectState<T>();
}

class BcMultiSelectOption<T> {
  final T value;
  final String label;

  const BcMultiSelectOption({required this.value, required this.label});
}

class _BcMultiSelectState<T> extends State<BcMultiSelect<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.value ?? widget.defaultValue ?? []);
  }

  @override
  void didUpdateWidget(BcMultiSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      _selected = List<T>.from(widget.value!);
    }
  }

  void _toggle(T value) {
    setState(() {
      if (_selected.contains(value)) {
        _selected.remove(value);
      } else {
        _selected.add(value);
      }
    });
    widget.onValueChange?.call(
      List<T>.from(_selected),
      const BcChangeMeta(reason: BcChangeReason.toggle),
    );
  }

  String get _summary {
    if (_selected.isEmpty) return widget.placeholder ?? 'Select items';
    return '${_selected.length} selected';
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.placeholder,
        border: const OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: widget.disabled ? null : () => _showDialog(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_summary),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(widget.label ?? 'Select'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    final opt = widget.options[index];
                    return Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        value: _selected.contains(opt.value),
                        title: Text(opt.label),
                        onChanged: (v) {
                          setState(() {});
                          _toggle(opt.value);
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
