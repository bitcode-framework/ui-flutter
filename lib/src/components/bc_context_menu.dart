library bc_context_menu;

import 'package:flutter/material.dart';

/// Material-only context menu (ADR-011 Section 5).
/// Pure Material 3 — uses PopupMenuButton on long-press.
class BcContextMenu extends StatelessWidget {
  final Widget child;
  final List<BcContextMenuItem> items;

  const BcContextMenu({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMenu(context),
      onSecondaryTap: () => _showMenu(context),
      child: child,
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromLTRB(
      box.localToGlobal(Offset.zero).dx,
      box.localToGlobal(Offset.zero).dy + box.size.height,
      box.localToGlobal(Offset.zero).dx + box.size.width,
      0,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: items
          .map((item) => PopupMenuItem<String>(
                value: item.key,
                enabled: item.enabled,
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(item.label),
                  ],
                ),
              ))
          .toList(),
    ).then((key) {
      if (key == null) return;
      final item = items.where((i) => i.key == key).firstOrNull;
      item?.onTap?.call();
    });
  }
}

class BcContextMenuItem {
  final String key;
  final String label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback? onTap;

  const BcContextMenuItem({
    required this.key,
    required this.label,
    this.icon,
    this.enabled = true,
    this.onTap,
  });
}
