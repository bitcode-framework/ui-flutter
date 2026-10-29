library bc_barcode;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcBarcode extends StatefulWidget {
  final String? name;
  final String? label;
  final String? placeholder;
  final String? value;
  final String? defaultValue;
  final bool disabled;
  final bool required;
  final String format;
  final BcChangeHandler<String>? onChange;

  const BcBarcode({
    super.key,
    this.name,
    this.label,
    this.placeholder = 'Scan or type barcode...',
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.required = false,
    this.format = 'CODE128',
    this.onChange,
  });

  @override
  State<BcBarcode> createState() => _BcBarcodeState();
}

class _BcBarcodeState extends State<BcBarcode> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _internalText = '';

  @override
  void initState() {
    super.initState();
    _internalText = widget.defaultValue ?? '';
    _controller = TextEditingController(text: _internalText);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BcBarcode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internalText = widget.defaultValue ?? '';
      _controller.text = _internalText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _current {
    if (widget.value != null) return widget.value!;
    return _internalText;
  }

  bool get _hasValue => _current.isNotEmpty;

  void _onEditingComplete() {
    final next = _controller.text;

    if (widget.value == null) {
      setState(() => _internalText = next);
    } else {
      _controller.text = widget.value!;
    }

    widget.onChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isControlled = widget.value != null;
    final controllerText = isControlled ? widget.value! : _internalText;
    if (_controller.text != controllerText) {
      _controller.value = TextEditingValue(
        text: controllerText,
        selection: TextSelection.collapsed(offset: controllerText.length),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.label!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  if (widget.required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: BcTheme.destructive),
                    ),
                ],
              ),
            ),
          ),
        TextField(
          key: const Key('bc_barcode_input'),
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.disabled,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          style: TextStyle(
            fontFamily: 'monospace',
            fontFeatures: const [FontFeature.tabularFigures()],
            color: widget.disabled ? BcTheme.mutedForeground : BcTheme.foreground,
          ),
          onEditingComplete: _onEditingComplete,
        ),
        if (_hasValue) ...[
          const SizedBox(height: 8),
          Container(
            key: const Key('bc_barcode_display'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: BcTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: BcTheme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  key: const Key('bc_barcode_bars'),
                  size: const Size.fromHeight(40),
                  painter: _BarcodeBarsPainter(
                    value: _current,
                    color: widget.disabled ? BcTheme.mutedForeground : BcTheme.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _current,
                  key: const Key('bc_barcode_value_text'),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    letterSpacing: 2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: widget.disabled ? BcTheme.mutedForeground : BcTheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    if (widget.disabled) {
      return Opacity(opacity: 0.5, child: content);
    }

    return content;
  }
}

class _BarcodeBarsPainter extends CustomPainter {
  final String value;
  final Color color;

  _BarcodeBarsPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final charCodes = value.codeUnits;
    if (charCodes.isEmpty) return;

    final totalWidth = size.width;
    final barCount = charCodes.length * 4 + 3;
    final barWidth = totalWidth / barCount;
    final barHeight = size.height;

    double x = 0;
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, barWidth, barHeight),
        paint,
      );
      x += barWidth * 2;
    }

    for (final code in charCodes) {
      for (var i = 0; i < 4; i++) {
        final bit = (code >> i) & 1;
        if (bit == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x, 0, barWidth, barHeight),
            paint,
          );
        }
        x += barWidth * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodeBarsPainter oldDelegate) {
    return value != oldDelegate.value || color != oldDelegate.color;
  }
}
