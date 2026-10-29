library bc_code;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcCode extends StatefulWidget {
  final String? name;
  final String? label;
  final String? value;
  final String? defaultValue;
  final String language;
  final bool disabled;
  final bool required;
  final int rows;
  final BcChangeHandler<String>? onValueChange;

  const BcCode({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.language = 'text',
    this.disabled = false,
    this.required = false,
    this.rows = 8,
    this.onValueChange,
  });

  @override
  State<BcCode> createState() => _BcCodeState();
}

class _BcCodeState extends State<BcCode> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isControlled = false;
  String _internalValue = '';

  static const Map<String, Set<String>> _keywords = <String, Set<String>>{
    'dart': <String>{
      'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch',
      'class', 'const', 'continue', 'default', 'deferred', 'do', 'dynamic',
      'else', 'enum', 'export', 'extends', 'extension', 'external', 'factory',
      'false', 'final', 'finally', 'for', 'Function', 'get', 'hide', 'if',
      'implements', 'import', 'in', 'interface', 'is', 'library', 'mixin',
      'new', 'null', 'on', 'operator', 'part', 'rethrow', 'return', 'set',
      'show', 'static', 'super', 'switch', 'sync', 'this', 'throw', 'true',
      'try', 'typedef', 'var', 'void', 'while', 'with', 'yield',
    },
    'python': <String>{
      'False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await',
      'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except',
      'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is',
      'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try',
      'while', 'with', 'yield',
    },
    'javascript': <String>{
      'abstract', 'async', 'await', 'break', 'case', 'catch', 'class',
      'const', 'continue', 'debugger', 'default', 'delete', 'do', 'else',
      'enum', 'export', 'extends', 'false', 'finally', 'for', 'from',
      'function', 'if', 'implements', 'import', 'in', 'instanceof',
      'interface', 'let', 'new', 'null', 'of', 'package', 'private',
      'protected', 'public', 'return', 'super', 'switch', 'static', 'this',
      'throw', 'true', 'try', 'typeof', 'undefined', 'var', 'void', 'while',
      'with', 'yield',
    },
    'typescript': <String>{
      'abstract', 'any', 'as', 'async', 'await', 'boolean', 'break', 'case',
      'catch', 'class', 'const', 'continue', 'debugger', 'declare', 'default',
      'delete', 'do', 'else', 'enum', 'export', 'extends', 'false', 'finally',
      'for', 'from', 'function', 'if', 'implements', 'import', 'in',
      'instanceof', 'interface', 'let', 'new', 'null', 'number', 'of',
      'package', 'private', 'protected', 'public', 'readonly', 'return',
      'super', 'switch', 'static', 'string', 'this', 'throw', 'true', 'try',
      'type', 'typeof', 'undefined', 'var', 'void', 'while', 'with', 'yield',
    },
    'go': <String>{
      'break', 'case', 'chan', 'const', 'continue', 'default', 'defer',
      'else', 'fallthrough', 'for', 'func', 'go', 'goto', 'if', 'import',
      'interface', 'map', 'package', 'range', 'return', 'select', 'struct',
      'switch', 'type', 'var',
    },
    'json': <String>{
      'false', 'null', 'true',
    },
  };

  @override
  void initState() {
    super.initState();
    _isControlled = widget.value != null;
    _internalValue = widget.defaultValue ?? '';
    _controller = TextEditingController(text: _currentValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BcCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasControlled = oldWidget.value != null;
    _isControlled = widget.value != null;
    final next = _currentValue;
    if (_controller.text != next) {
      _controller.value = TextEditingValue(
        text: next,
        selection: _controller.value.selection,
      );
    }
    if (!_isControlled && !wasControlled) {
      _internalValue = _controller.text;
    }
  }

  String get _currentValue =>
      _isControlled ? widget.value! : _internalValue;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleInput(String _) {
    final next = _controller.text;
    if (!_isControlled) {
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

  InlineSpan _buildHighlightedSpan(String text, TextStyle baseStyle) {
    final language = widget.language.toLowerCase();
    if (language == 'text' || language.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final keywords = _keywords[language] ?? const <String>{};
    const keywordColor = BcTheme.primary;
    const stringColor = BcTheme.success;
    const numberColor = BcTheme.warning;
    const commentColor = BcTheme.mutedForeground;

    final buffer = StringBuffer();
    final spans = <TextSpan>[];

    void flush(StringBuffer buf, TextStyle style) {
      if (buf.isNotEmpty) {
        spans.add(TextSpan(text: buf.toString(), style: style));
        buf.clear();
      }
    }

    int i = 0;
    while (i < text.length) {
      final ch = text[i];

      if (ch == '/' && i + 1 < text.length && text[i + 1] == '/') {
        flush(buffer, baseStyle);
        final start = i;
        while (i < text.length && text[i] != '\n') {
          buffer.write(text[i]);
          i++;
        }
        spans.add(TextSpan(
          text: text.substring(start, i),
          style: baseStyle.copyWith(color: commentColor),
        ));
        buffer.clear();
        continue;
      }

      if (ch == '"' || ch == "'") {
        flush(buffer, baseStyle);
        final quote = ch;
        buffer.write(ch);
        i++;
        while (i < text.length && text[i] != quote) {
          if (text[i] == '\\' && i + 1 < text.length) {
            buffer.write(text[i]);
            buffer.write(text[i + 1]);
            i += 2;
            continue;
          }
          buffer.write(text[i]);
          i++;
        }
        if (i < text.length) {
          buffer.write(text[i]);
          i++;
        }
        spans.add(TextSpan(
          text: buffer.toString(),
          style: baseStyle.copyWith(color: stringColor),
        ));
        buffer.clear();
        continue;
      }

      if (_isDigit(ch) || (ch == '-' &&
          i + 1 < text.length &&
          _isDigit(text[i + 1]) &&
          (buffer.isEmpty || _isWhitespace(text[i - 1])))) {
        flush(buffer, baseStyle);
        buffer.write(ch);
        i++;
        while (i < text.length && (_isDigit(text[i]) || text[i] == '.')) {
          buffer.write(text[i]);
          i++;
        }
        spans.add(TextSpan(
          text: buffer.toString(),
          style: baseStyle.copyWith(color: numberColor),
        ));
        buffer.clear();
        continue;
      }

      if (_isIdentifierStart(ch)) {
        flush(buffer, baseStyle);
        buffer.write(ch);
        i++;
        while (i < text.length && _isIdentifierPart(text[i])) {
          buffer.write(text[i]);
          i++;
        }
        final word = buffer.toString();
        if (keywords.contains(word)) {
          spans.add(TextSpan(
            text: word,
            style: baseStyle.copyWith(
              color: keywordColor,
              fontWeight: FontWeight.w600,
            ),
          ));
        } else {
          spans.add(TextSpan(text: word, style: baseStyle));
        }
        buffer.clear();
        continue;
      }

      buffer.write(ch);
      i++;
    }
    flush(buffer, baseStyle);

    return TextSpan(children: spans, style: baseStyle);
  }

  bool _isDigit(String ch) =>
      ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;

  bool _isWhitespace(String ch) =>
      ch == ' ' || ch == '\n' || ch == '\t' || ch == '\r';

  bool _isIdentifierStart(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || ch == '_' || ch == r'$';
  }

  bool _isIdentifierPart(String ch) =>
      _isIdentifierStart(ch) || _isDigit(ch);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontFamily: 'monospace',
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      height: 1.4,
    );

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

    columnChildren.add(
      Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.rows * 18.0),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IgnorePointer(
                    child: KeyedSubtree(
                      key: const Key('bc-code-highlighted'),
                      child: RichText(
                        text: _buildHighlightedSpan(
                          _controller.text,
                          baseStyle,
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                ),
                TextField(
                  key: const Key('bc-code-editor'),
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.disabled,
                  maxLines: null,
                  style: baseStyle.copyWith(color: Colors.transparent),
                  cursorColor: BcTheme.foreground,
                  decoration: InputDecoration(
                    hintText: widget.disabled ? null : 'Enter code',
                    hintStyle: baseStyle.copyWith(
                      color: BcTheme.mutedForeground,
                    ),
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
                  onChanged: _handleInput,
                ),
              ],
            ),
          ),
          if (widget.language.isNotEmpty &&
              widget.language.toLowerCase() != 'text')
            Positioned(
              top: 6,
              right: 8,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: BcTheme.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.language,
                    style: baseStyle.copyWith(
                      fontSize: 11,
                      color: BcTheme.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
}
