library bc_cascader;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single option in a [BcCascader] tree.
///
/// Mirrors TS `BcCascaderOption`.
class BcCascaderOption {
  final String label;
  final String value;
  final List<BcCascaderOption>? children;

  const BcCascaderOption({
    required this.label,
    required this.value,
    this.children,
  });
}

/// Multi-level cascading select (ADR-011 Phase 5c — M1).
///
/// Renders side-by-side columns representing tree levels. Selecting an
/// option in a column reveals the next level (if children exist). Only
/// selecting a leaf (no children) emits the full path via [onValueChange].
///
/// Controlled via [value] — a list of value strings forming the selection
/// path (e.g. `['jabar', 'bandung']`).
class BcCascader extends StatefulWidget {
  final String name;
  final String? label;
  final String placeholder;
  final List<BcCascaderOption> options;
  final List<String> value;
  final bool disabled;
  final bool required;
  final String separator;
  final BcChangeHandler<List<String>>? onValueChange;

  const BcCascader({
    super.key,
    required this.name,
    this.label,
    this.placeholder = 'Select...',
    this.options = const [],
    this.value = const [],
    this.disabled = false,
    this.required = false,
    this.separator = ' / ',
    this.onValueChange,
  });

  @override
  State<BcCascader> createState() => _BcCascaderState();
}

class _BcCascaderState extends State<BcCascader> {
  bool _isOpen = false;
  late List<String> _activePath;

  @override
  void initState() {
    super.initState();
    _activePath = List.from(widget.value);
  }

  @override
  void didUpdateWidget(covariant BcCascader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _activePath = List.from(widget.value);
    }
  }

  List<List<BcCascaderOption>> get _columns {
    final cols = <List<BcCascaderOption>>[];
    var level = widget.options;
    cols.add(level);
    for (final val in _activePath) {
      final found = level.where((o) => o.value == val).firstOrNull;
      if (found != null &&
          found.children != null &&
          found.children!.isNotEmpty) {
        level = found.children!;
        cols.add(level);
      } else {
        break;
      }
    }
    return cols;
  }

  String get _displayLabel {
    if (_activePath.isEmpty) return '';
    final labels = <String>[];
    var level = widget.options;
    for (final val in _activePath) {
      final found = level.where((o) => o.value == val).firstOrNull;
      if (found == null) break;
      labels.add(found.label);
      level = found.children ?? const [];
    }
    return labels.join(widget.separator);
  }

  bool _isActive(int colIndex, String value) {
    if (colIndex < _activePath.length) {
      return _activePath[colIndex] == value;
    }
    return false;
  }

  void _pick(int colIndex, BcCascaderOption option) {
    if (widget.disabled) return;
    final next = _activePath.sublist(0, colIndex);
    next.add(option.value);
    setState(() {
      _activePath = next;
    });
    final isLeaf =
        option.children == null || option.children!.isEmpty;
    if (isLeaf) {
      setState(() {
        _isOpen = false;
      });
      widget.onValueChange?.call(
        next,
        const BcChangeMeta(
          reason: BcChangeReason.select,
          source: BcEventSource.pointer,
        ),
      );
    }
  }

  void _toggle() {
    if (widget.disabled) return;
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: BcTheme.foreground,
                    ),
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
        _buildTrigger(),
        if (_isOpen)
          _buildColumns(),
      ],
    );
  }

  Widget _buildTrigger() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.disabled ? null : _toggle,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        child: Opacity(
          opacity: widget.disabled ? 0.5 : 1.0,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: BcTheme.border),
              borderRadius: BorderRadius.circular(BcTheme.radius),
              color: BcTheme.background,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayLabel.isEmpty
                        ? widget.placeholder
                        : _displayLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: _displayLabel.isEmpty
                          ? BcTheme.mutedForeground
                          : BcTheme.foreground,
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: BcTheme.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumns() {
    final cols = _columns;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
        color: BcTheme.popover,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var ci = 0; ci < cols.length; ci++) ...[
              if (ci > 0)
                Container(
                  width: 1,
                  color: BcTheme.border,
                ),
              _buildColumn(ci, cols[ci]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(int colIndex, List<BcCascaderOption> options) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) {
          final active = _isActive(colIndex, option.value);
          final hasChildren =
              option.children != null && option.children!.isNotEmpty;
          return InkWell(
            key: ValueKey('cascader_col${colIndex}_${option.value}'),
            onTap: widget.disabled ? null : () => _pick(colIndex, option),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? BcTheme.accent
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: active
                            ? BcTheme.accentForeground
                            : BcTheme.popoverForeground,
                      ),
                    ),
                  ),
                  if (hasChildren) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '\u203A',
                      style: TextStyle(
                        fontSize: 14,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
