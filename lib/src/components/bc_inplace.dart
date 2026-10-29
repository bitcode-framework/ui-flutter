library bc_inplace;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Inline editable text component.
///
/// Mirrors the TS `BcInplaceContract`: in display mode, renders its value as
/// non-editable text. Activating it (tap) switches to edit mode, focusing an
/// input pre-filled with the current value.
///
/// Confirming commits the new value: [onChange] fires with the edited string
/// and a [BcChangeMeta] whose reason is [BcChangeReason.confirm], then the
/// widget returns to display mode showing the committed value.
///
/// Cancelling reverts to the prior value and returns to display mode without
/// emitting a change. The draft is discarded.
///
/// When [disabled] is true, activating the display text does not enter edit
/// mode, the input is never mounted, and the component renders with disabled
/// token styling (reduced opacity, no hover cursor).
///
/// Controlled mode: the parent manages [value]; the display always reflects
/// the controlled value. In edit mode, the draft starts from the controlled
/// value.
/// Uncontrolled mode: [value] is null and [defaultValue] seeds the initial
/// display; commits update the internal state.
///
/// [withButtons] controls the commit model:
/// - `true`: Save and Cancel buttons render alongside the input. Save commits;
///   Cancel reverts.
/// - `false` (default): blur commits, Escape cancels, Enter commits.
class BcInplace extends StatefulWidget {
  /// Field name (for form integration / data-bc-inplace attribute).
  final String? name;

  /// Controlled value. When non-null, the display reflects this value.
  final String? value;

  /// Initial value for uncontrolled mode.
  final String? defaultValue;

  /// Placeholder text when the value is empty.
  final String? placeholder;

  /// When true, the component cannot enter edit mode.
  final bool disabled;

  /// When true, Save/Cancel buttons render. When false (default), blur
  /// commits and Escape cancels.
  final bool withButtons;

  /// Label for the save button (when [withButtons] is true).
  final String saveLabel;

  /// Label for the cancel button (when [withButtons] is true).
  final String cancelLabel;

  /// Called when the value is committed (only when it actually changed).
  final BcChangeHandler<String>? onChange;

  const BcInplace({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.placeholder,
    this.disabled = false,
    this.withButtons = false,
    this.saveLabel = 'Save',
    this.cancelLabel = 'Cancel',
    this.onChange,
  });

  @override
  State<BcInplace> createState() => _BcInplaceState();
}

class _BcInplaceState extends State<BcInplace> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String? _internalValue;

  String get _currentValue =>
      widget.value ?? _internalValue ?? widget.defaultValue ?? '';

  bool get _isControlled => widget.value != null;

  @override
  void initState() {
    super.initState();
    _internalValue = widget.defaultValue;
    _controller = TextEditingController(text: _currentValue);
    _focusNode = FocusNode(onKeyEvent: _onKeyEvent);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant BcInplace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled && widget.value != oldWidget.value) {
      if (!_isEditing) {
        _controller.text = widget.value!;
      }
    }
    if (!_isControlled &&
        widget.defaultValue != oldWidget.defaultValue &&
        _internalValue == null) {
      _controller.text = widget.defaultValue ?? '';
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _isEditing && !widget.withButtons) {
      _commit();
    }
  }

  void _enterEditMode() {
    if (widget.disabled) return;
    setState(() {
      _isEditing = true;
      _controller.text = _currentValue;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _commit() {
    final newValue = _controller.text;
    final oldValue = _currentValue;
    setState(() {
      _isEditing = false;
      _internalValue = newValue;
    });
    _focusNode.unfocus();
    if (newValue != oldValue) {
      widget.onChange?.call(
        newValue,
        const BcChangeMeta(
          reason: BcChangeReason.confirm,
          source: BcEventSource.pointer,
        ),
      );
    }
  }

  void _cancel() {
    setState(() {
      _controller.text = _currentValue;
      _isEditing = false;
    });
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && !widget.disabled) {
      return _buildEditMode();
    }
    return _buildDisplayMode();
  }

  Widget _buildDisplayMode() {
    final displayText = _currentValue.isEmpty
        ? (widget.placeholder ?? 'Click to edit')
        : _currentValue;
    final isEmpty = _currentValue.isEmpty;

    if (widget.disabled) {
      return Container(
        key: const Key('bc-inplace-display'),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: isEmpty
                ? BcTheme.mutedForeground
                : BcTheme.mutedForeground.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return InkWell(
      key: const Key('bc-inplace-display'),
      onTap: _enterEditMode,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: isEmpty ? BcTheme.mutedForeground : BcTheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    final textField = TextField(
      key: const Key('bc-inplace-input'),
      controller: _controller,
      focusNode: _focusNode,
      style: const TextStyle(
        fontSize: 14,
        color: BcTheme.foreground,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BcTheme.radius),
          borderSide: const BorderSide(color: BcTheme.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BcTheme.radius),
          borderSide: const BorderSide(color: BcTheme.ring, width: 2),
        ),
      ),
      onSubmitted: (_) => _commit(),
    );

    if (!widget.withButtons) {
      return textField;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: textField,
        ),
        const SizedBox(width: 4),
        _buildSaveButton(),
        const SizedBox(width: 4),
        _buildCancelButton(),
      ],
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.enter) {
        _commit();
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.escape) {
        _cancel();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      key: const Key('bc-inplace-save'),
      onPressed: _commit,
      style: ElevatedButton.styleFrom(
        backgroundColor: BcTheme.primary,
        foregroundColor: BcTheme.primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13),
      ),
      child: Text(widget.saveLabel),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      key: const Key('bc-inplace-cancel'),
      onPressed: _cancel,
      style: ElevatedButton.styleFrom(
        backgroundColor: BcTheme.background,
        foregroundColor: BcTheme.foreground,
        elevation: 0,
        side: const BorderSide(color: BcTheme.border),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13),
      ),
      child: Text(widget.cancelLabel),
    );
  }
}
