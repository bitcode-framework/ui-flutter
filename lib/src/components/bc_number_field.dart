library bc_number_field;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Adaptive number input with stepper (ADR-011 Section 5).
class BcNumberField extends StatefulWidget {
  final String? name;
  final num? value;
  final num? defaultValue;
  final BcChangeHandler<num>? onValueChange;
  final bool disabled;
  final String? label;
  final num? min;
  final num? max;
  final num? step;
  final String? placeholder;

  const BcNumberField({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.disabled = false,
    this.label,
    this.min,
    this.max,
    this.step = 1,
    this.placeholder,
  });

  @override
  State<BcNumberField> createState() => _BcNumberFieldState();
}

class _BcNumberFieldState extends State<BcNumberField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final v = widget.value ?? widget.defaultValue;
    _controller = TextEditingController(text: v?.toString() ?? '');
  }

  @override
  void didUpdateWidget(BcNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final v = widget.value ?? widget.defaultValue;
    final text = v?.toString() ?? '';
    if (_controller.text != text) _controller.text = text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emit(String text) {
    final n = num.tryParse(text);
    if (n == null) return;
    var clamped = n;
    if (widget.min != null && clamped < widget.min!) clamped = widget.min!;
    if (widget.max != null && clamped > widget.max!) clamped = widget.max!;
    widget.onValueChange?.call(
      clamped,
      const BcChangeMeta(reason: BcChangeReason.input),
    );
  }

  void _step(int direction) {
    final current = num.tryParse(_controller.text) ?? widget.min ?? 0;
    final next = current + (widget.step ?? 1) * direction;
    _controller.text = next.toString();
    _emit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: widget.disabled ? null : () => _step(-1),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.disabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.placeholder,
                border: const OutlineInputBorder(),
              ),
              onChanged: _emit,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.disabled ? null : () => _step(1),
          ),
        ],
      ),
      cupertino: (context, platform) => Row(
        children: [
          CupertinoButton(
            onPressed: widget.disabled ? null : () => _step(-1),
            child: const Icon(CupertinoIcons.minus),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              enabled: !widget.disabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              placeholder: widget.placeholder,
              onChanged: _emit,
            ),
          ),
          CupertinoButton(
            onPressed: widget.disabled ? null : () => _step(1),
            child: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
    );
  }
}
