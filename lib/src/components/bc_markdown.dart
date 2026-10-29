library bc_markdown;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

enum BcMarkdownView { edit, preview }

enum BcMarkdownFormat { bold, italic, heading, list, link, code }

class BcMarkdown extends StatefulWidget {
  final String? name;
  final String? label;
  final String? placeholder;
  final String? value;
  final String? defaultValue;
  final bool disabled;
  final bool required;
  final int rows;
  final BcMarkdownView? view;
  final BcMarkdownView defaultView;
  final BcChangeHandler<String>? onValueChange;

  const BcMarkdown({
    super.key,
    this.name,
    this.label,
    this.placeholder = 'Write markdown...',
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.required = false,
    this.rows = 8,
    this.view,
    this.defaultView = BcMarkdownView.edit,
    this.onValueChange,
  });

  @override
  State<BcMarkdown> createState() => _BcMarkdownState();
}

class _BcMarkdownState extends State<BcMarkdown> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isControlledValue = false;
  bool _isControlledView = false;
  String _internalValue = '';
  BcMarkdownView _internalView = BcMarkdownView.edit;

  @override
  void initState() {
    super.initState();
    _isControlledValue = widget.value != null;
    _isControlledView = widget.view != null;
    _internalValue = widget.defaultValue ?? '';
    _internalView = widget.defaultView;
    _controller = TextEditingController(text: _currentValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BcMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasControlledValue = oldWidget.value != null;
    final wasControlledView = oldWidget.view != null;
    _isControlledValue = widget.value != null;
    _isControlledView = widget.view != null;

    final next = _currentValue;
    if (_controller.text != next) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    if (!_isControlledValue && !wasControlledValue) {
      _internalValue = _controller.text;
    }
    if (!_isControlledView && !wasControlledView) {
      _internalView = widget.defaultView;
    }
  }

  String get _currentValue =>
      _isControlledValue ? widget.value! : _internalValue;

  BcMarkdownView get _currentView =>
      _isControlledView ? widget.view! : _internalView;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleInput(String _) {
    final next = _controller.text;
    if (!_isControlledValue) {
      _internalValue = next;
    }
    widget.onValueChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );
  }

  void _applyFormat(BcMarkdownFormat format) {
    if (widget.disabled) return;
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);
    final selected = start == end ? '' : text.substring(start, end);

    String prefix;
    String suffix;
    String placeholderText;
    switch (format) {
      case BcMarkdownFormat.bold:
        prefix = '**';
        suffix = '**';
        placeholderText = 'bold';
        break;
      case BcMarkdownFormat.italic:
        prefix = '*';
        suffix = '*';
        placeholderText = 'italic';
        break;
      case BcMarkdownFormat.heading:
        prefix = '## ';
        suffix = '';
        placeholderText = 'Heading';
        break;
      case BcMarkdownFormat.list:
        prefix = '- ';
        suffix = '';
        placeholderText = 'item';
        break;
      case BcMarkdownFormat.link:
        prefix = '[';
        suffix = '](url)';
        placeholderText = 'text';
        break;
      case BcMarkdownFormat.code:
        prefix = '`';
        suffix = '`';
        placeholderText = 'code';
        break;
    }

    final body = selected.isEmpty ? placeholderText : selected;
    final wrapped = '$prefix$body$suffix';
    final next = text.substring(0, start) + wrapped + text.substring(end);
    final cursorEnd = start + prefix.length + body.length;

    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: cursorEnd),
    );
    if (!_isControlledValue) {
      _internalValue = next;
    }
    widget.onValueChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.valueChange,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _toggleView() {
    final next = _currentView == BcMarkdownView.edit
        ? BcMarkdownView.preview
        : BcMarkdownView.edit;
    if (!_isControlledView) {
      setState(() {
        _internalView = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minHeight = widget.rows * 18.0;

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
              const Spacer(),
              _buildViewToggle(),
            ],
          ),
        ),
      );
    } else {
      columnChildren.add(
        Align(
          alignment: Alignment.centerRight,
          child: _buildViewToggle(),
        ),
      );
    }

    if (_currentView == BcMarkdownView.edit) {
      columnChildren.add(_buildToolbar(context));
      columnChildren.add(const SizedBox(height: 6));
    }

    columnChildren.add(
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: _currentView == BcMarkdownView.edit
            ? _buildEditor(theme)
            : _buildPreview(theme),
      ),
    );

    return Semantics(
      container: true,
      textField: _currentView == BcMarkdownView.edit,
      enabled: !widget.disabled,
      readOnly: widget.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columnChildren,
      ),
    );
  }

  Widget _buildViewToggle() {
    final isPreview = _currentView == BcMarkdownView.preview;
    return IconButton(
      key: const Key('bc-markdown-view-toggle'),
      icon: Icon(isPreview ? Icons.edit : Icons.visibility, size: 18),
      tooltip: isPreview ? 'Edit' : 'Preview',
      onPressed: widget.disabled ? null : _toggleView,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final buttons = <Widget>[
      _toolbarButton(
        key: 'bc-markdown-toolbar-bold',
        icon: Icons.format_bold,
        tooltip: 'Bold',
        onPressed: widget.disabled ? null : () => _applyFormat(BcMarkdownFormat.bold),
      ),
      _toolbarButton(
        key: 'bc-markdown-toolbar-italic',
        icon: Icons.format_italic,
        tooltip: 'Italic',
        onPressed: widget.disabled ? null : () => _applyFormat(BcMarkdownFormat.italic),
      ),
      _toolbarButton(
        key: 'bc-markdown-toolbar-heading',
        icon: Icons.title,
        tooltip: 'Heading',
        onPressed: widget.disabled ? null : () => _applyFormat(BcMarkdownFormat.heading),
      ),
      _toolbarButton(
        key: 'bc-markdown-toolbar-list',
        icon: Icons.format_list_bulleted,
        tooltip: 'List',
        onPressed: widget.disabled ? null : () => _applyFormat(BcMarkdownFormat.list),
      ),
      _toolbarButton(
        key: 'bc-markdown-toolbar-link',
        icon: Icons.link,
        tooltip: 'Link',
        onPressed: widget.disabled ? null : () => _applyFormat(BcMarkdownFormat.link),
      ),
      _toolbarButton(
        key: 'bc-markdown-toolbar-code',
        icon: Icons.code,
        tooltip: 'Code',
        onPressed: widget.disabled ? null : () => _applyFormat(BcMarkdownFormat.code),
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: BcTheme.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Wrap(spacing: 2, children: buttons),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return TextField(
      key: const Key('bc-markdown-editor'),
      controller: _controller,
      focusNode: _focusNode,
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
      style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
        fontFamily: 'monospace',
        height: 1.4,
      ),
      onChanged: _handleInput,
    );
  }

  Widget _buildPreview(ThemeData theme) {
    final blocks = _renderMarkdown(_currentValue, theme);
    return KeyedSubtree(
      key: const Key('bc-markdown-preview'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: blocks.isEmpty
            ? Text(
                'Nothing to preview',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: BcTheme.mutedForeground,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: blocks,
              ),
      ),
    );
  }

  List<Widget> _renderMarkdown(String source, ThemeData theme) {
    final lines = source.split('\n');
    final blocks = <Widget>[];
    final listItems = <String>[];

    void flushList() {
      if (listItems.isEmpty) return;
      blocks.add(
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 2),
                      child: Text(
                        '\u2022',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
      listItems.clear();
    }

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.isEmpty) {
        flushList();
        continue;
      }

      if (line.startsWith('###### ')) {
        flushList();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            line.substring(7),
            style: theme.textTheme.titleSmall ?? const TextStyle(),
          ),
        ));
      } else if (line.startsWith('##### ')) {
        flushList();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            line.substring(6),
            style: theme.textTheme.titleSmall ?? const TextStyle(),
          ),
        ));
      } else if (line.startsWith('#### ')) {
        flushList();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            line.substring(5),
            style: theme.textTheme.titleMedium ?? const TextStyle(),
          ),
        ));
      } else if (line.startsWith('### ')) {
        flushList();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Text(
            line.substring(4),
            style: theme.textTheme.titleMedium ?? const TextStyle(),
          ),
        ));
      } else if (line.startsWith('## ')) {
        flushList();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 2),
          child: Text(
            line.substring(3),
            style: theme.textTheme.titleLarge ?? const TextStyle(),
          ),
        ));
      } else if (line.startsWith('# ')) {
        flushList();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line.substring(2),
            style: theme.textTheme.headlineSmall ?? const TextStyle(),
          ),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        listItems.add(line.substring(2));
      } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        final match = RegExp(r'^\d+\.\s(.*)$').firstMatch(line);
        if (match != null) {
          listItems.add(match.group(1)!);
        }
      } else {
        flushList();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: _renderInline(line, theme.textTheme.bodyMedium!),
        ));
      }
    }
    flushList();
    return blocks;
  }

  Widget _renderInline(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(
      r'(\*\*([^*]+)\*\*)|(\*([^*]+)\*)|(`([^`]+)`)|(\[([^\]]+)\]\(([^)]+)\))',
    );
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }
      if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(
          text: match.group(4),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(6) != null) {
        spans.add(TextSpan(
          text: match.group(6),
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            color: BcTheme.primary,
          ),
        ));
      } else if (match.group(8) != null) {
        spans.add(TextSpan(
          text: match.group(8),
          style: baseStyle.copyWith(
            color: BcTheme.primary,
            decoration: TextDecoration.underline,
          ),
        ));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }
    return RichText(
      text: TextSpan(children: spans, style: baseStyle),
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
