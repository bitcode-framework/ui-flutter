library bc_combobox;

import 'package:flutter/material.dart';
import '../core/types.dart';

/// Material-only combobox with autocomplete (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart.
class BcCombobox<T> extends StatefulWidget {
  final String? name;
  final T? value;
  final T? defaultValue;
  final List<BcComboboxOption<T>> options;
  final BcChangeHandler<T>? onValueChange;
  final bool disabled;
  final String? label;
  final String? placeholder;

  const BcCombobox({
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
  State<BcCombobox<T>> createState() => _BcComboboxState<T>();
}

class BcComboboxOption<T> {
  final T value;
  final String label;

  const BcComboboxOption({required this.value, required this.label});
}

class _BcComboboxState<T> extends State<BcCombobox<T>> {
  late TextEditingController _controller;
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? widget.defaultValue;
    _controller = TextEditingController(text: _labelFor(_selected));
  }

  String _labelFor(T? val) {
    if (val == null) return '';
    final match = widget.options.where((o) => o.value == val).toList();
    return match.isNotEmpty ? match.first.label : '';
  }

  @override
  void didUpdateWidget(BcCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
      _controller.text = _labelFor(_selected);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(T value) {
    setState(() => _selected = value);
    _controller.text = _labelFor(value);
    widget.onValueChange?.call(
      value,
      const BcChangeMeta(reason: BcChangeReason.select),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<BcComboboxOption<T>>(
      textEditingController: _controller,
      focusNode: FocusNode(),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        return widget.options
            .where((o) => o.label.toLowerCase().contains(query))
            .toList();
      },
      displayStringForOption: (o) => o.label,
      onSelected: (option) => _select(option.value),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: !widget.disabled,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.placeholder,
            border: const OutlineInputBorder(),
          ),
          onEditingComplete: onFieldSubmitted,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text(option.label),
                      onTap: () => onSelected(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
