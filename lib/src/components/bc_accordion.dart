library bc_accordion;

import 'package:flutter/material.dart';

/// Material-only accordion (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart.
class BcAccordion extends StatefulWidget {
  final List<BcAccordionItem> items;
  final int? initialExpandedIndex;
  final bool allowMultiple;

  const BcAccordion({
    super.key,
    required this.items,
    this.initialExpandedIndex,
    this.allowMultiple = false,
  });

  @override
  State<BcAccordion> createState() => _BcAccordionState();
}

class _BcAccordionState extends State<BcAccordion> {
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialExpandedIndex != null) {
      _expanded.add(widget.initialExpandedIndex!);
    }
  }

  void _toggle(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        if (!widget.allowMultiple) _expanded.clear();
        _expanded.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          Material(
            color: Colors.transparent,
            child: ExpansionTile(
              title: Text(widget.items[i].title),
              subtitle: widget.items[i].subtitle != null
                  ? Text(widget.items[i].subtitle!)
                  : null,
              leading: widget.items[i].icon != null ? Icon(widget.items[i].icon) : null,
              initiallyExpanded: _expanded.contains(i),
              onExpansionChanged: (_) => _toggle(i),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: widget.items[i].child,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class BcAccordionItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;

  const BcAccordionItem({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
  });
}
