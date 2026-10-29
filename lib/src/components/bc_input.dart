library bc_input;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';

/// Adaptive text input (ADR-011 Section 5).
/// Material: TextFormField. Cupertino: CupertinoTextField.
class BcInput extends StatefulWidget {
  final String? name;
  final String? value;
  final String? defaultValue;
  final BcChangeHandler<String>? onValueChange;
  final bool disabled;
  final bool readOnly;
  final String? placeholder;
  final String? label;
  final String? helperText;
  final String? errorText;
  final int? maxLength;
  final int? maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final BcComponentSize size;

  const BcInput({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.disabled = false,
    this.readOnly = false,
    this.placeholder,
    this.label,
    this.helperText,
    this.errorText,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.keyboardType,
    this.size = BcComponentSize.md,
  });

  @override
  State<BcInput> createState() => _BcInputState();
}

class _BcInputState extends State<BcInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value ?? widget.defaultValue,
    );
  }

  @override
  void didUpdateWidget(BcInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget.value ?? widget.defaultValue ?? '';
    if (_controller.text != current) {
      _controller.text = current;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(String text) {
    widget.onValueChange?.call(
      text,
      const BcChangeMeta(reason: BcChangeReason.input),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildField(context);
  }

  Widget _buildField(BuildContext context) {
    final field = _platformField(context);
    if (widget.label == null && widget.helperText == null && widget.errorText == null) {
      return field;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(widget.label!,
                style: Theme.of(context).textTheme.labelMedium),
          ),
        field,
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          )
        else if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.helperText!,
                style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }

  Widget _platformField(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => TextField(
        controller: _controller,
        enabled: !widget.disabled,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          border: const OutlineInputBorder(),
          isDense: widget.size == BcComponentSize.sm,
        ),
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        onChanged: _handleChange,
      ),
      cupertino: (context, platform) => CupertinoTextField(
        controller: _controller,
        enabled: !widget.disabled,
        readOnly: widget.readOnly,
        placeholder: widget.placeholder,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        onChanged: _handleChange,
      ),
    );
  }
}
