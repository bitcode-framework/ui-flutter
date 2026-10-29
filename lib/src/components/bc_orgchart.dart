library bc_orgchart;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcOrgNode {
  final String id;
  final String label;
  final String? title;
  final String? avatar;
  final List<BcOrgNode>? children;

  const BcOrgNode({
    required this.id,
    required this.label,
    this.title,
    this.avatar,
    this.children,
  });
}

class _FlatRow {
  final BcOrgNode node;
  final int depth;
  final bool hasChildren;

  const _FlatRow({
    required this.node,
    required this.depth,
    required this.hasChildren,
  });
}

class BcOrgChart extends StatefulWidget {
  final BcOrgNode? root;
  final List<String>? defaultExpanded;
  final void Function(BcOrgNode node, BcChangeMeta meta)? onNodeSelect;

  const BcOrgChart({
    super.key,
    this.root,
    this.defaultExpanded,
    this.onNodeSelect,
  });

  @override
  State<BcOrgChart> createState() => _BcOrgChartState();
}

class _BcOrgChartState extends State<BcOrgChart> {
  late Set<String> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = Set<String>.from(widget.defaultExpanded ?? const []);
  }

  @override
  void didUpdateWidget(BcOrgChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultExpanded != oldWidget.defaultExpanded) {
      _expanded = Set<String>.from(widget.defaultExpanded ?? const []);
    }
  }

  void _toggle(String id) {
    setState(() {
      if (_expanded.contains(id)) {
        _expanded.remove(id);
      } else {
        _expanded.add(id);
      }
    });
  }

  List<_FlatRow> _flatten() {
    final out = <_FlatRow>[];
    void walk(BcOrgNode? node, int depth) {
      if (node == null || depth > 64) return;
      final hasChildren =
          node.children != null && node.children!.isNotEmpty;
      out.add(_FlatRow(node: node, depth: depth, hasChildren: hasChildren));
      if (hasChildren && _expanded.contains(node.id)) {
        for (final child in node.children!) {
          walk(child, depth + 1);
        }
      }
    }

    walk(widget.root, 0);
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.root == null) {
      return const SizedBox.shrink();
    }

    final rows = _flatten();

    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.map((row) => _buildRow(row)).toList(),
      ),
    );
  }

  Widget _buildRow(_FlatRow row) {
    final isExpanded = _expanded.contains(row.node.id);
    const indentUnit = 24.0;

    return Padding(
      padding: EdgeInsets.only(left: row.depth * indentUnit, bottom: 4),
      child: InkWell(
        key: Key('bc_orgchart_node_${row.node.id}'),
        onTap: () {
          widget.onNodeSelect?.call(
            row.node,
            const BcChangeMeta(
              reason: BcChangeReason.select,
              source: BcEventSource.pointer,
            ),
          );
        },
        borderRadius: BorderRadius.circular(BcTheme.radius),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: BcTheme.background,
            border: Border.all(color: BcTheme.border),
            borderRadius: BorderRadius.circular(BcTheme.radius),
          ),
          child: Row(
            children: [
              if (row.hasChildren)
                GestureDetector(
                  key: Key('bc_orgchart_expand_${row.node.id}'),
                  onTap: () => _toggle(row.node.id),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Icon(
                      isExpanded
                          ? Icons.expand_more
                          : Icons.chevron_right,
                      size: 18,
                      color: BcTheme.mutedForeground,
                    ),
                  ),
                )
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              if (row.node.avatar != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(row.node.avatar!),
                    backgroundColor: BcTheme.muted,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.node.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: BcTheme.foreground,
                      ),
                    ),
                    if (row.node.title != null)
                      Text(
                        row.node.title!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
