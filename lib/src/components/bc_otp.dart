library bc_otp;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Segmented one-time-password / PIN input (ADR-011 Phase 5c — M1).
///
/// Renders [length] digit boxes. Typing a digit auto-advances focus to the
/// next box. The widget is controlled via [value]; when [value] is null,
/// [defaultValue] seeds the initial state (uncontrolled).
///
/// [onValueChange] fires on every keystroke with the concatenated code
/// string and a [BcChangeMeta]. [onComplete] fires once when all cells are
/// filled.
///
/// When [disabled] or [readOnly] is true, cells do not accept input and
/// no callbacks fire. External values longer than [length] are clamped.
class BcOtp extends StatefulWidget {
  final String name;
  final String? label;
  final int length;
  final String? value;
  final String? defaultValue;
  final bool disabled;
  final bool readOnly;
  final bool numeric;
  final BcChangeHandler<String>? onValueChange;
  final void Function(String value)? onComplete;

  const BcOtp({
    super.key,
    required this.name,
    this.label,
    this.length = 6,
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.readOnly = false,
    this.numeric = true,
    this.onValueChange,
    this.onComplete,
  });

  @override
  State<BcOtp> createState() => _BcOtpState();
}

class _BcOtpState extends State<BcOtp> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _digits;

  @override
  void initState() {
    super.initState();
    _initDigits();
    _createControllers();
  }

  void _initDigits() {
    final source = widget.value ?? widget.defaultValue ?? '';
    _digits = List<String>.generate(widget.length, (i) {
      if (i < source.length) {
        return source[i];
      }
      return '';
    });
  }

  void _createControllers() {
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (i) => TextEditingController(text: _digits[i]),
    );
    _focusNodes = List<FocusNode>.generate(
      widget.length,
      (i) => FocusNode(),
    );
  }

  @override
  void didUpdateWidget(BcOtp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      final source = widget.value ?? '';
      _syncFromValue(source);
    }

    if (widget.length != oldWidget.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      for (final f in _focusNodes) {
        f.dispose();
      }
      _initDigits();
      _createControllers();
    }
  }

  void _syncFromValue(String source) {
    for (var i = 0; i < widget.length; i++) {
      final newDigit = i < source.length ? source[i] : '';
      _digits[i] = newDigit;
      if (_controllers[i].text != newDigit) {
        _controllers[i].text = newDigit;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isInteractive => !widget.disabled && !widget.readOnly;

  void _handleInput(int index, String entered) {
    if (!_isInteractive) return;

    String char = '';
    if (entered.isNotEmpty) {
      if (entered.length > 1) {
        char = entered[entered.length - 1];
      } else {
        char = entered;
      }
    }

    if (widget.numeric && char.isNotEmpty) {
      final codeUnit = char.codeUnitAt(0);
      if (codeUnit < 48 || codeUnit > 57) {
        _controllers[index].text = _digits[index];
        return;
      }
    }

    _digits[index] = char;
    _controllers[index].text = char;

    final fullCode = _digits.join();

    widget.onValueChange?.call(
      fullCode,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );

    if (char.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    if (fullCode.length == widget.length &&
        _digits.every((d) => d.isNotEmpty)) {
      widget.onComplete?.call(fullCode);
    }
  }

  void _handleBackspace(int index) {
    if (!_isInteractive) return;

    if (_digits[index].isNotEmpty) {
      _digits[index] = '';
      _controllers[index].text = '';
      _emitChange();
    } else if (index > 0) {
      final prev = index - 1;
      _digits[prev] = '';
      _controllers[prev].text = '';
      FocusScope.of(context).requestFocus(_focusNodes[prev]);
      _emitChange();
    }
  }

  void _emitChange() {
    final fullCode = _digits.join();
    widget.onValueChange?.call(
      fullCode,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cells = <Widget>[];
    for (var i = 0; i < widget.length; i++) {
      cells.add(_buildCell(context, i));
      if (i < widget.length - 1) {
        cells.add(const SizedBox(width: 8));
      }
    }

    final cellRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: cells,
    );

    if (widget.label == null) {
      return cellRow;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            widget.label!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: BcTheme.foreground,
            ),
          ),
        ),
        cellRow,
      ],
    );
  }

  Widget _buildCell(BuildContext context, int index) {
    return Semantics(
      label: 'Digit ${index + 1}',
      textField: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: KeyboardListener(
          focusNode: _focusNodes[index],
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              if (_controllers[index].text.isEmpty) {
                _handleBackspace(index);
              }
            }
          },
          child: TextField(
            key: ValueKey('otp_cell_$index'),
            controller: _controllers[index],
            enabled: !widget.disabled,
            readOnly: widget.readOnly,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            maxLength: 1,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.disabled
                  ? BcTheme.mutedForeground
                  : BcTheme.foreground,
            ),
            keyboardType:
                widget.numeric ? TextInputType.number : TextInputType.text,
            inputFormatters: widget.numeric
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: widget.disabled,
              fillColor: widget.disabled ? BcTheme.muted : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BcTheme.radius),
                borderSide: BorderSide(
                  color: _focusNodes[index].hasFocus
                      ? BcTheme.ring
                      : BcTheme.border,
                  width: _focusNodes[index].hasFocus ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BcTheme.radius),
                borderSide: const BorderSide(
                  color: BcTheme.ring,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BcTheme.radius),
                borderSide: const BorderSide(color: BcTheme.border),
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                _handleBackspace(index);
              } else {
                _handleInput(index, value);
              }
            },
            onTap: () {
              if (_controllers[index].text.isNotEmpty) {
                _controllers[index].selection = const TextSelection(
                  baseOffset: 0,
                  extentOffset: 1,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
