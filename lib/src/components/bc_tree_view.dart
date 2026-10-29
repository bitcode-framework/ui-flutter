library bc_tree_view;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A tree node.
class BcTreeViewNode {
  final String id;
  final String label;
  final List<BcTreeViewNode>? children;
  final IconData? icon;
  final String? badge;

  const BcTreeViewNode({
    required this.id,
    required this.label,
    this.children,
    this.icon,
    this.badge,
  });
}

/// Hierarchical tree view (ADR-006 Adapt).
///
/// Recursive widget with tap-to-select and tap-chevron-to-expand.
/// Controlled expanded keys via [expandedKeys] or uncontrolled via
/// [defaultExpandedKeys].
class BcTreeView extends StatefulWidget {
  final List<BcTreeViewNode> data;
  final Set<String>? expandedKeys;
  final Set<String>? defaultExpandedKeys;
  final String? selectedKey;
  final void Function(BcTreeViewNode node, BcChangeMeta meta)? onSelect;
  final void Function(String key, bool expanded, BcChangeMeta meta)? onExpand;

  const BcTreeView({
    super.key,
    required this.data,
    this.expandedKeys,
    this.defaultExpandedKeys,
    this.selectedKey,
    this.onSelect,
    this.onExpand,
  });

  @override
  State<BcTreeView> createState() => _BcTreeViewState();
}

class _BcTreeViewState extends State<BcTreeView> {
  late Set<String> _internalExpanded;
  late String _internalSelected;

  @override
  void initState() {
    super.initState();
    _internalExpanded = Set.from(widget.defaultExpandedKeys ?? {});
    _internalSelected = '';
  }

  bool get _isControlledExpanded => widget.expandedKeys != null;
  bool get _isControlledSelected => widget.selectedKey != null;

  Set<String> get _expandedSet => _isControlledExpanded
      ? widget.expandedKeys!
      : _internalExpanded;
  String get _selectedKey => _isControlledSelected
      ? (widget.selectedKey ?? '')
      : _internalSelected;

  void _handleSelect(BcTreeViewNode node) {
    if (!_isControlledSelected) {
      setState(() => _internalSelected = node.id);
    }
    widget.onSelect?.call(
      node,
      const BcChangeMeta(reason: BcChangeReason.select, source: BcEventSource.pointer),
    );
  }

  void _handleExpand(String key, bool expanded) {
    if (!_isControlledExpanded) {
      setState(() {
        if (expanded) {
          _internalExpanded.add(key);
        } else {
          _internalExpanded.remove(key);
        }
      });
    }
    widget.onExpand?.call(
      key,
      expanded,
      const BcChangeMeta(reason: BcChangeReason.toggle, source: BcEventSource.pointer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: bcI18n.t('bc.treeView.ariaLabel'),
      child: Container(
        key: const Key('bc-tree-view'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.data
              .map((node) => _buildRow(node, 0))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRow(BcTreeViewNode node, int depth) {
    final hasChildren = node.children != null && node.children!.isNotEmpty;
    final isExpanded = _expandedSet.contains(node.id);
    final isSelected = _selectedKey == node.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: Key('bc-tree-view-node-${node.id}'),
          onTap: () => _handleSelect(node),
          child: Container(
            padding: EdgeInsets.only(left: depth * 20.0 + 8.0, right: 8.0),
            constraints: const BoxConstraints(minHeight: 44),
            color: isSelected ? BcTheme.accent : null,
            child: Row(
              children: [
                if (hasChildren)
                  GestureDetector(
                    key: Key('bc-tree-view-toggle-${node.id}'),
                    onTap: () => _handleExpand(node.id, !isExpanded),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 32,
                      height: 44,
                      child: Center(
                        child: Icon(
                          isExpanded ? Icons.expand_more : Icons.chevron_right,
                          size: 20,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 32),
                if (node.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(node.icon, size: 16, color: BcTheme.foreground),
                  ),
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? BcTheme.accentForeground : BcTheme.foreground,
                    ),
                  ),
                ),
                if (node.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: BcTheme.muted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      node.badge!,
                      style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          ...node.children!.map((child) => _buildRow(child, depth + 1)),
      ],
    );
  }
}
