library bc_richtext;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

enum BcRichTextFormat { bold, italic, underline }

class BcRichText extends StatefulWidget {
  final String? name;
  final String? label;
  final String? placeholder;
  final String? value;
  final String? defaultValue;
  final bool disabled;
  final bool required;
  final int rows;
  final BcChangeHandler<String>? onValueChange;

  const BcRichText({
    super.key,
    this.name,
    this.label,
    this.placeholder = 'Start typing...',
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.required = false,
    this.rows = 5,
    this.onValueChange,
  });

  @override
  State<BcRichText> createState() => _BcRichTextState();
}

class _BcRichTextState extends State<BcRichText> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isControlled = false;
  String _internalValue = '';
  TextSelection _selection = const TextSelection.collapsed(offset: 0);

  @override
  void initState() {
    super.initState();
    _isControlled = widget.value != null;
    _internalValue = widget.defaultValue ?? '';
    _controller = TextEditingController(text: _currentValue);
    _focusNode = FocusNode();
    _controller.addListener(() {
      if (_controller.selection != _selection) {
        _selection = _controller.selection;
      }
    });
  }

  @override
  void didUpdateWidget(BcRichText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasControlled = oldWidget.value != null;
    _isControlled = widget.value != null;
    final next = _currentValue;
    if (_controller.text != next) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    if (!_isControlled && !wasControlled) {
      _internalValue = _controller.text;
    }
  }

  String get _currentValue => _isControlled ? widget.value! : _internalValue;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _emit(String next, BcChangeReason reason, BcEventSource source) {
    if (!_isControlled) {
      _internalValue = next;
    }
    widget.onValueChange?.call(
      next,
      BcChangeMeta(reason: reason, source: source),
    );
  }

  void _handleInput(String _) {
    final next = _controller.text;
    _emit(next, BcChangeReason.input, BcEventSource.keyboard);
  }

  void _applyFormat(BcRichTextFormat format) {
    if (widget.disabled) return;
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);
    final selectedText =
        start == end ? text : text.substring(start, end);
    final targetText = start == end ? (text.isEmpty ? 'text' : '') : selectedText;

    final tags = <BcRichTextFormat, (String, String)>{
      BcRichTextFormat.bold: ('<b>', '</b>'),
      BcRichTextFormat.italic: ('<i>', '</i>'),
      BcRichTextFormat.underline: ('<u>', '</u>'),
    };
    final tag = tags[format]!;
    final body = targetText.isEmpty ? 'text' : targetText;
    final wrapped = '${tag.$1}$body${tag.$2}';
    final next = start == end
        ? (text.isEmpty
            ? wrapped
            : text.substring(0, start) + wrapped + text.substring(end))
        : text.substring(0, start) + wrapped + text.substring(end);

    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + wrapped.length),
    );
    _emit(next, BcChangeReason.valueChange, BcEventSource.pointer);
  }

  void _clearAll() {
    if (widget.disabled) return;
    _controller.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    );
    _emit('', BcChangeReason.clear, BcEventSource.pointer);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final isControlPressed = HardwareKeyboard.instance.isControlPressed;
    final isBold = key == LogicalKeyboardKey.keyB && isControlPressed;
    final isItalic = key == LogicalKeyboardKey.keyI && isControlPressed;
    final isUnderline = key == LogicalKeyboardKey.keyU && isControlPressed;
    if (isBold) {
      _applyFormat(BcRichTextFormat.bold);
      return KeyEventResult.handled;
    }
    if (isItalic) {
      _applyFormat(BcRichTextFormat.italic);
      return KeyEventResult.handled;
    }
    if (isUnderline) {
      _applyFormat(BcRichTextFormat.underline);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minHeight = widget.rows * 20.0;

    final List<Widget> columnChildren = <Widget>[];

    if (widget.label != null) {
      columnChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: <Widget>[
              Text(
                widget.label!,
                style: theme.textTheme.labelMedium,
              ),
              if (widget.required)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    '*',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: BcTheme.destructive,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    columnChildren.add(_buildToolbar(context));
    columnChildren.add(
      const SizedBox(height: 6),
    );

    columnChildren.add(
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: TextField(
            key: const Key('bc-richtext-editor'),
            controller: _controller,
            enabled: !widget.disabled,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: _controller.text.isEmpty ? widget.placeholder : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: BcTheme.border),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: BcTheme.border),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: BcTheme.ring, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: BcTheme.background,
            ),
            style: theme.textTheme.bodyMedium,
            onChanged: _handleInput,
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      textField: true,
      enabled: !widget.disabled,
      readOnly: widget.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columnChildren,
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    if (widget.disabled) {
      return _wrapToolbar(
        <Widget>[
          _toolbarButton(
            key: 'bc-richtext-toolbar-bold',
            icon: Icons.format_bold,
            tooltip: 'Bold',
            onPressed: null,
          ),
          _toolbarButton(
            key: 'bc-richtext-toolbar-italic',
            icon: Icons.format_italic,
            tooltip: 'Italic',
            onPressed: null,
          ),
          _toolbarButton(
            key: 'bc-richtext-toolbar-underline',
            icon: Icons.format_underline,
            tooltip: 'Underline',
            onPressed: null,
          ),
          _toolbarButton(
            key: 'bc-richtext-toolbar-clear',
            icon: Icons.delete_outline,
            tooltip: 'Clear',
            onPressed: null,
          ),
        ],
      );
    }
    return _wrapToolbar(
      <Widget>[
        _toolbarButton(
          key: 'bc-richtext-toolbar-bold',
          icon: Icons.format_bold,
          tooltip: 'Bold',
          onPressed: () => _applyFormat(BcRichTextFormat.bold),
        ),
        _toolbarButton(
          key: 'bc-richtext-toolbar-italic',
          icon: Icons.format_italic,
          tooltip: 'Italic',
          onPressed: () => _applyFormat(BcRichTextFormat.italic),
        ),
        _toolbarButton(
          key: 'bc-richtext-toolbar-underline',
          icon: Icons.format_underline,
          tooltip: 'Underline',
          onPressed: () => _applyFormat(BcRichTextFormat.underline),
        ),
        _toolbarButton(
          key: 'bc-richtext-toolbar-clear',
          icon: Icons.delete_outline,
          tooltip: 'Clear',
          onPressed: _clearAll,
        ),
      ],
    );
  }

  Widget _wrapToolbar(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: BcTheme.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Wrap(
        spacing: 2,
        children: children,
      ),
    );
  }

  Widget _toolbarButton({
    required String key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      key: Key(key),
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }
}
