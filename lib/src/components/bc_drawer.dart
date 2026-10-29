library bc_drawer;

import 'package:flutter/material.dart';

/// Material-only navigation drawer (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart.
class BcDrawer extends StatelessWidget {
  final Widget? header;
  final List<BcDrawerItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;

  const BcDrawer({
    super.key,
    this.header,
    required this.items,
    this.selectedIndex,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (header != null) header!,
          for (int i = 0; i < items.length; i++)
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: items[i].icon != null ? Icon(items[i].icon) : null,
                title: Text(items[i].label),
                selected: i == selectedIndex,
                onTap: () => onSelected?.call(i),
              ),
            ),
        ],
      ),
    );
  }
}

class BcDrawerItem {
  final String label;
  final IconData? icon;

  const BcDrawerItem({required this.label, this.icon});
}
