library bc_json;

import 'dart:convert';

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

enum BcJsonView { raw, tree }

class BcJson extends StatefulWidget {
  final String? name;
  final String? label;
  final String? value;
  final String? defaultValue;
  final bool disabled;
  final bool required;
  final int rows;
  final BcJsonView? view;
  final BcJsonView defaultView;
  final BcChangeHandler<String>? onValueChange;

  const BcJson({
    super.key,
    this.name,
    this.label,
    this.value,
    this.defaultValue,
    this.disabled = false,
    this.required = false,
    this.rows = 8,
    this.view,
    this.defaultView = BcJsonView.raw,
    this.onValueChange,
  });

  @override
  State<BcJson> createState() => _BcJsonState();
}

class _BcJsonState extends State<BcJson> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isControlledValue = false;
  bool _isControlledView = false;
  String _internalValue = '';
  BcJsonView _internalView = BcJsonView.raw;
  String _invalidMessage = '';

  @override
  void initState() {
    super.initState();
    _isControlledValue = widget.value != null;
    _isControlledView = widget.view != null;
    _internalValue = widget.defaultValue ?? '';
    _internalView = widget.defaultView;
    _controller = TextEditingController(text: _currentValue);
    _focusNode = FocusNode();
    _validate(_currentValue);
  }

  @override
  void didUpdateWidget(BcJson oldWidget) {
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
    _validate(_currentValue);
  }

  String get _currentValue =>
      _isControlledValue ? widget.value! : _internalValue;

  BcJsonView get _currentView =>
      _isControlledView ? widget.view! : _internalView;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validate(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _invalidMessage = '';
      return;
    }
    try {
      jsonDecode(trimmed);
      _invalidMessage = '';
    } catch (_) {
      _invalidMessage = 'Invalid JSON';
    }
  }

  bool get _isValid => _invalidMessage.isEmpty;

  void _handleInput(String _) {
    final next = _controller.text;
    if (!_isControlledValue) {
      _internalValue = next;
    }
    setState(() {
      _validate(next);
    });
    widget.onValueChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );
  }

  void _format() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    try {
      final parsed = jsonDecode(trimmed);
      const encoder = JsonEncoder.withIndent('  ');
      final formatted = encoder.convert(parsed);
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      if (!_isControlledValue) {
        _internalValue = formatted;
      }
      setState(() {
        _validate(formatted);
      });
      widget.onValueChange?.call(
        formatted,
        const BcChangeMeta(
          reason: BcChangeReason.input,
          source: BcEventSource.keyboard,
        ),
      );
    } catch (_) {}
  }

  void _toggleView() {
    final next =
        _currentView == BcJsonView.raw ? BcJsonView.tree : BcJsonView.raw;
    if (!_isControlledView) {
      setState(() {
        _internalView = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monoStyle =
        (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
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

    columnChildren.add(
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.rows * 18.0),
        child: _currentView == BcJsonView.raw
            ? _buildRawEditor(theme, monoStyle)
            : _buildTreeView(theme, monoStyle),
      ),
    );

    if (!_isValid) {
      columnChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _invalidMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: BcTheme.destructive,
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      textField: _currentView == BcJsonView.raw,
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
    final isTree = _currentView == BcJsonView.tree;
    return IconButton(
      key: const Key('bc-json-view-toggle'),
      icon: Icon(isTree ? Icons.code : Icons.account_tree, size: 18),
      tooltip: isTree ? 'Switch to raw' : 'Switch to tree',
      onPressed: widget.disabled ? null : _toggleView,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildRawEditor(ThemeData theme, TextStyle monoStyle) {
    return TextField(
      key: const Key('bc-json-raw-editor'),
      controller: _controller,
      focusNode: _focusNode,
      enabled: !widget.disabled,
      maxLines: null,
      style: monoStyle,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: widget.disabled ? null : '{"key": "value"}',
        hintStyle: monoStyle.copyWith(color: BcTheme.mutedForeground),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: BcTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: _isValid ? BcTheme.border : BcTheme.destructive,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: _isValid ? BcTheme.ring : BcTheme.destructive,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: BcTheme.background,
      ),
      onChanged: _handleInput,
      onEditingComplete: _format,
      onSubmitted: (_) => _format(),
    );
  }

  Widget _buildTreeView(ThemeData theme, TextStyle monoStyle) {
    final value = _currentValue.trim();
    if (value.isEmpty) {
      return KeyedSubtree(
        key: const Key('bc-json-tree-view'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: BcTheme.background,
            border: Border.all(color: BcTheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '(empty)',
            style: monoStyle.copyWith(color: BcTheme.mutedForeground),
          ),
        ),
      );
    }

    final List<Widget> rows = <Widget>[];
    try {
      final decoded = jsonDecode(value);
      rows.addAll(_renderNode(decoded, 0, theme, monoStyle));
    } catch (_) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _invalidMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: BcTheme.destructive,
            ),
          ),
        ),
      );
    }

    return KeyedSubtree(
      key: const Key('bc-json-tree-view'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: BcTheme.background,
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }

  List<Widget> _renderNode(
    Object? node,
    int depth,
    ThemeData theme,
    TextStyle base,
  ) {
    final indent = depth * 16.0;
    final keyStyle = base.copyWith(
      color: BcTheme.primary,
      fontWeight: FontWeight.w600,
    );
    final stringStyle = base.copyWith(color: BcTheme.success);
    final numberStyle = base.copyWith(color: BcTheme.warning);
    final boolStyle = base.copyWith(color: BcTheme.info);
    final nullStyle = base.copyWith(color: BcTheme.mutedForeground);

    final List<Widget> rows = <Widget>[];

    if (node is Map<String, dynamic>) {
      final entries = node.entries.toList();
      for (final entry in entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is Map<String, dynamic> || value is List<dynamic>) {
          rows.add(
            Padding(
              padding: EdgeInsets.only(left: indent),
              child: Text('$key:', style: keyStyle),
            ),
          );
          rows.addAll(_renderNode(value, depth + 1, theme, base));
        } else {
          rows.add(
            Padding(
              padding: EdgeInsets.only(left: indent),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(key, style: keyStyle),
                  ),
                  Text(
                    value?.toString() ?? 'null',
                    style: _scalarStyle(
                      value,
                      stringStyle,
                      numberStyle,
                      boolStyle,
                      nullStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } else if (node is List<dynamic>) {
      for (var i = 0; i < node.length; i++) {
        final value = node[i];
        if (value is Map<String, dynamic> || value is List<dynamic>) {
          rows.add(
            Padding(
              padding: EdgeInsets.only(left: indent),
              child: Text('[$i]:', style: keyStyle),
            ),
          );
          rows.addAll(_renderNode(value, depth + 1, theme, base));
        } else {
          rows.add(
            Padding(
              padding: EdgeInsets.only(left: indent),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text('[$i]', style: keyStyle),
                  ),
                  Text(
                    value?.toString() ?? 'null',
                    style: _scalarStyle(
                      value,
                      stringStyle,
                      numberStyle,
                      boolStyle,
                      nullStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } else {
      rows.add(
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: Text(
            node?.toString() ?? 'null',
            style: base,
          ),
        ),
      );
    }
    return rows;
  }

  TextStyle _scalarStyle(
    Object? value,
    TextStyle stringStyle,
    TextStyle numberStyle,
    TextStyle boolStyle,
    TextStyle nullStyle,
  ) {
    if (value == null) return nullStyle;
    if (value is bool) return boolStyle;
    if (value is num) return numberStyle;
    if (value is String) return stringStyle;
    return stringStyle;
  }
}
