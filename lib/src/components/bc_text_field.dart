library bc_text_field;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Reason the text field value changed.
enum BcTextFieldChangeReason { input, clear, autogrow, programmatic }

/// Validation status mapped to border tokens.
enum BcTextFieldValidationStatus { none, valid, invalid }

/// Rich text input with multiline auto-grow, character counter, and
/// prefix/suffix slots (ADR-007 contract parity).
///
/// Distinct from [BcInput] (basic) by supporting multiline auto-grow,
/// visible char counter against [maxLength], and affixed content. The
/// Flutter adapter maps autoGrow to `maxLines: null` + `minLines`, which
/// is the idiomatic Flutter auto-resize behavior.
class BcTextField extends StatefulWidget {
  final String name;
  final String? label;
  final String? value;
  final String? defaultValue;
  final String? placeholder;
  final bool multiline;
  final bool autoGrow;
  final int rows;
  final int minRows;
  final int maxRows;
  final bool showCount;
  final int? maxLength;
  final String? prefixText;
  final String? suffixText;
  final bool clearable;
  final bool disabled;
  final bool readonly;
  final bool required;
  final bool loading;
  final bool autofocus;
  final String? description;
  final String? errorMessage;
  final BcTextFieldValidationStatus validationStatus;
  final String? autoComplete;
  final BcChangeHandler<String>? onValueChange;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final VoidCallback? onClear;
  final VoidCallback? onEnter;

  const BcTextField({
    super.key,
    required this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.placeholder,
    this.multiline = false,
    this.autoGrow = false,
    this.rows = 4,
    this.minRows = 1,
    this.maxRows = 8,
    this.showCount = false,
    this.maxLength,
    this.prefixText,
    this.suffixText,
    this.clearable = false,
    this.disabled = false,
    this.readonly = false,
    this.required = false,
    this.loading = false,
    this.autofocus = false,
    this.description,
    this.errorMessage,
    this.validationStatus = BcTextFieldValidationStatus.none,
    this.autoComplete,
    this.onValueChange,
    this.onFocus,
    this.onBlur,
    this.onClear,
    this.onEnter,
  });

  @override
  State<BcTextField> createState() => _BcTextFieldState();
}

class _BcTextFieldState extends State<BcTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isControlled = false;

  @override
  void initState() {
    super.initState();
    _isControlled = widget.value != null;
    _controller = TextEditingController(
      text: widget.value ?? widget.defaultValue ?? '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void didUpdateWidget(covariant BcTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.value ?? widget.defaultValue ?? '';
    if (_controller.text != external) {
      _controller.text = external;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  void _handleChange(String value) {
    if (widget.maxLength != null && widget.maxLength! > 0 && value.length > widget.maxLength!) {
      return;
    }
    if (!_isControlled) {
      _controller.text = value;
    }
    widget.onValueChange?.call(
      value,
      const BcChangeMeta(reason: BcChangeReason.input, source: BcEventSource.keyboard),
    );
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onValueChange?.call(
      '',
      const BcChangeMeta(reason: BcChangeReason.clear, source: BcEventSource.pointer),
    );
  }

  Color get _borderColor {
    switch (widget.validationStatus) {
      case BcTextFieldValidationStatus.invalid:
        return BcTheme.destructive;
      case BcTextFieldValidationStatus.valid:
        return BcTheme.success;
      case BcTextFieldValidationStatus.none:
        return BcTheme.input;
    }
  }

  int? get _effectiveMaxLines {
    if (!widget.multiline) return 1;
    if (widget.autoGrow) return null; // null = grow unbounded
    return widget.rows;
  }

  int? get _effectiveMinLines {
    if (!widget.multiline) return 1;
    if (widget.autoGrow) return widget.minRows;
    return widget.rows;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.validationStatus == BcTextFieldValidationStatus.invalid &&
        widget.errorMessage != null;

    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.disabled ? BcTheme.mutedForeground : BcTheme.foreground,
                ),
                children: [
                  TextSpan(text: widget.label),
                  if (widget.required)
                    const TextSpan(text: ' *', style: TextStyle(color: BcTheme.destructive)),
                ],
              ),
            ),
          ),
        _buildControl(),
        const SizedBox(height: 4),
        _buildFooter(hasError),
      ],
    );

    return Semantics(
      container: true,
      textField: true,
      enabled: !widget.disabled,
      label: widget.label ?? widget.name,
      child: ExcludeSemantics(
        excluding: false,
        child: field,
      ),
    );
  }

  Widget _buildControl() {
    return Stack(
      alignment: Alignment.center,
      children: [
        TextField(
          key: const Key('bc-text-field-input'),
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.disabled,
          readOnly: widget.readonly,
          maxLength: widget.showCount && widget.maxLength != null ? widget.maxLength : null,
          maxLines: _effectiveMaxLines,
          minLines: _effectiveMinLines,
          obscureText: false,
          autofocus: false, // handled via FocusNode for deterministic timing
          decoration: InputDecoration(
            hintText: widget.placeholder,
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            prefixStyle: const TextStyle(color: BcTheme.mutedForeground, fontSize: 14),
            suffixStyle: const TextStyle(color: BcTheme.mutedForeground, fontSize: 14),
            // Suppress the built-in counter when we render our own below.
            // An empty counterText hides the Flutter default "n/maxLength".
            counterText: (widget.showCount && widget.maxLength != null) ? '' : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BcTheme.radius),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BcTheme.radius),
              borderSide: BorderSide(color: _borderColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BcTheme.radius),
              borderSide: const BorderSide(color: BcTheme.destructive),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BcTheme.radius),
              borderSide: const BorderSide(color: BcTheme.destructive, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BcTheme.radius),
              borderSide: BorderSide(color: BcTheme.input.withValues(alpha: 0.5)),
            ),
          ),
          style: TextStyle(
            fontSize: 14,
            color: widget.disabled ? BcTheme.mutedForeground : BcTheme.foreground,
          ),
          keyboardType: widget.multiline ? TextInputType.multiline : TextInputType.text,
          textInputAction: widget.multiline ? TextInputAction.newline : TextInputAction.done,
          inputFormatters: widget.maxLength != null && !widget.showCount
              ? [
                  LengthLimitingTextInputFormatter(widget.maxLength),
                ]
              : null,
          onChanged: _handleChange,
          onSubmitted: widget.multiline ? null : (_) => widget.onEnter?.call(),
        ),
        Positioned(
          right: widget.suffixText != null ? 56 : 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.loading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (widget.clearable && _controller.text.isNotEmpty && !widget.disabled && !widget.readonly)
                IconButton(
                  key: const Key('bc-text-field-clear'),
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: _handleClear,
                  tooltip: bcI18n.t('bc.textField.clearAriaLabel'),
                  color: BcTheme.mutedForeground,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool hasError) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: hasError
              ? Text(
                  widget.errorMessage!,
                  key: const Key('bc-text-field-error'),
                  style: const TextStyle(color: BcTheme.destructive, fontSize: 12),
                )
              : (widget.description != null
                  ? Text(
                      widget.description!,
                      key: const Key('bc-text-field-description'),
                      style: const TextStyle(color: BcTheme.mutedForeground, fontSize: 12),
                    )
                  : const SizedBox.shrink()),
        ),
        if (widget.showCount)
          Text(
            widget.maxLength != null
                ? '${_controller.text.length}/${widget.maxLength}'
                : '${_controller.text.length}',
            key: const Key('bc-text-field-counter'),
            style: const TextStyle(color: BcTheme.mutedForeground, fontSize: 12),
          ),
      ],
    );
  }
}
