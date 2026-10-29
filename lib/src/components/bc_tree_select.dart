library bc_tree_select;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single node in a [BcTreeSelect] tree.
///
/// Mirrors TS `BcTreeSelectNode`.
class BcTreeSelectNode {
  final String label;
  final String value;
  final List<BcTreeSelectNode>? children;

  const BcTreeSelectNode({
    required this.label,
    required this.value,
    this.children,
  });
}

/// Tree-structured select dropdown (ADR-011 Phase 5c — M1).
///
/// Renders a flattened tree inside a dropdown overlay. Nodes with children
/// show expand/collapse markers. Selecting any node emits its value via
/// [onValueChange] with [BcChangeMeta].
///
/// Supports both single-select ([multiple] = false) and multi-select
/// ([multiple] = true) modes. In multi-select mode, parents with partial
/// child selection render as indeterminate.
class BcTreeSelect extends StatefulWidget {
  final String name;
  final String? label;
  final String placeholder;
  final List<BcTreeSelectNode> nodes;
  final Object value;
  final List<String> defaultExpanded;
  final bool disabled;
  final bool required;
  final bool multiple;
  final BcChangeHandler<Object>? onValueChange;

  const BcTreeSelect({
    super.key,
    required this.name,
    this.label,
    this.placeholder = 'Select...',
    this.nodes = const [],
    this.value = '',
    this.defaultExpanded = const [],
    this.disabled = false,
    this.required = false,
    this.multiple = false,
    this.onValueChange,
  });

  @override
  State<BcTreeSelect> createState() => _BcTreeSelectState();
}

class _BcTreeSelectState extends State<BcTreeSelect> {
  bool _isOpen = false;
  late Set<String> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = Set.from(widget.defaultExpanded);
  }

  @override
  void didUpdateWidget(covariant BcTreeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultExpanded != widget.defaultExpanded) {
      _expanded = Set.from(widget.defaultExpanded);
    }
  }

  Set<String> get _selectedValues {
    if (widget.value is List) {
      return (widget.value as List).cast<String>().toSet();
    }
    final v = widget.value.toString();
    return v.isEmpty ? <String>{} : {v};
  }

  List<_VisibleRow> get _visibleRows {
    final rows = <_VisibleRow>[];
    void walk(List<BcTreeSelectNode> list, int depth) {
      for (final node in list) {
        final hasChildren =
            node.children != null && node.children!.isNotEmpty;
        rows.add(_VisibleRow(node, depth, hasChildren));
        if (hasChildren && _expanded.contains(node.value)) {
          walk(node.children!, depth + 1);
        }
      }
    }

    walk(widget.nodes, 0);
    return rows;
  }

  String get _displayLabel {
    String result = '';
    void walk(List<BcTreeSelectNode> list) {
      for (final node in list) {
        if (_selectedValues.contains(node.value)) {
          result = result.isEmpty ? node.label : '$result, ${node.label}';
        }
        if (node.children != null) walk(node.children!);
      }
    }

    walk(widget.nodes);
    return result;
  }

  bool _isExpanded(String value) => _expanded.contains(value);

  void _toggleExpand(String value) {
    setState(() {
      if (_expanded.contains(value)) {
        _expanded.remove(value);
      } else {
        _expanded.add(value);
      }
    });
  }

  void _toggleOpen() {
    if (widget.disabled) return;
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _selectSingle(String value) {
    if (widget.disabled) return;
    setState(() {
      _isOpen = false;
    });
    widget.onValueChange?.call(
      value,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _toggleMulti(String value) {
    if (widget.disabled) return;
    final current = List<String>.from(_selectedValues);
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }

    final meta = BcChangeMeta(
      reason: current.length > _selectedValues.length
          ? BcChangeReason.select
          : BcChangeReason.deselect,
      source: BcEventSource.pointer,
    );
    widget.onValueChange?.call(current, meta);
  }

  bool _isChecked(String value) => _selectedValues.contains(value);

  bool? _getCheckState(BcTreeSelectNode node) {
    if (!_isParent(node)) {
      return _isChecked(node.value);
    }
    final childValues = _collectLeafValues(node);
    if (childValues.isEmpty) return _isChecked(node.value);
    final selectedCount =
        childValues.where((v) => _selectedValues.contains(v)).length;
    if (selectedCount == 0) return false;
    if (selectedCount == childValues.length) return true;
    return null;
  }

  bool _isParent(BcTreeSelectNode node) {
    return node.children != null && node.children!.isNotEmpty;
  }

  List<String> _collectLeafValues(BcTreeSelectNode node) {
    final result = <String>[];
    void walk(BcTreeSelectNode n) {
      if (n.children == null || n.children!.isEmpty) {
        result.add(n.value);
      } else {
        for (final child in n.children!) {
          walk(child);
        }
      }
    }

    if (_isParent(node)) {
      for (final child in node.children!) {
        walk(child);
      }
    }
    return result;
  }

  void _toggleParentSelection(BcTreeSelectNode node) {
    if (widget.disabled) return;
    final childValues = _collectLeafValues(node);
    final allSelected = childValues.every((v) => _selectedValues.contains(v));

    final current = List<String>.from(_selectedValues);
    if (allSelected) {
      current.removeWhere((v) => childValues.contains(v));
    } else {
      for (final v in childValues) {
        if (!current.contains(v)) current.add(v);
      }
    }

    widget.onValueChange?.call(
      current,
      BcChangeMeta(
        reason: allSelected
            ? BcChangeReason.deselect
            : BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
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
        if (_isOpen) _buildTree(),
      ],
    );
  }

  Widget _buildTrigger() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.disabled ? null : _toggleOpen,
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

  Widget _buildTree() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 288),
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
      child: _visibleRows.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No options'),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _visibleRows.map((row) => _buildRow(row)).toList(),
              ),
            ),
    );
  }

  Widget _buildRow(_VisibleRow row) {
    final isSelected = _isChecked(row.node.value);
    final indent = row.depth * 20.0;

    return Container(
      key: ValueKey('treeselect_row_${row.node.value}'),
      padding: EdgeInsets.only(left: 8 + indent),
      child: InkWell(
        onTap: widget.disabled
            ? null
            : () {
                if (widget.multiple) {
                  if (_isParent(row.node)) {
                    _toggleParentSelection(row.node);
                  } else {
                    _toggleMulti(row.node.value);
                  }
                } else {
                  _selectSingle(row.node.value);
                }
              },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              if (row.hasChildren)
                GestureDetector(
                  key: ValueKey('treeselect_expand_${row.node.value}'),
                  onTap:
                      widget.disabled ? null : () => _toggleExpand(row.node.value),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      _isExpanded(row.node.value) ? '\u25BE' : '\u25B8',
                      style: const TextStyle(
                        fontSize: 14,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 20),
              if (widget.multiple)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildCheckbox(row.node),
                ),
              Expanded(
                child: Text(
                  row.node.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? BcTheme.accentForeground
                        : BcTheme.popoverForeground,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BcTreeSelectNode node) {
    final checkState = _getCheckState(node);
    return SizedBox(
      width: 20,
      height: 20,
      child: Checkbox(
        key: ValueKey('treeselect_check_${node.value}'),
        value: checkState,
        tristate: true,
        onChanged: widget.disabled
            ? null
            : (_) {
                if (_isParent(node)) {
                  _toggleParentSelection(node);
                } else {
                  _toggleMulti(node.value);
                }
              },
      ),
    );
  }
}

class _VisibleRow {
  final BcTreeSelectNode node;
  final int depth;
  final bool hasChildren;

  _VisibleRow(this.node, this.depth, this.hasChildren);
}
