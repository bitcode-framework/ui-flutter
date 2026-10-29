library bc_menubar;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcMenubarItem {
  final String label;
  final String value;
  final bool disabled;
  final bool separator;

  const BcMenubarItem({
    required this.label,
    required this.value,
    this.disabled = false,
    this.separator = false,
  });
}

class BcMenubarMenu {
  final String label;
  final List<BcMenubarItem> items;
  final bool disabled;

  const BcMenubarMenu({
    required this.label,
    this.items = const [],
    this.disabled = false,
  });
}

class BcMenubar extends StatefulWidget {
  final List<BcMenubarMenu> menus;
  final bool disabled;
  final BcChangeHandler<String>? onSelected;

  const BcMenubar({
    super.key,
    this.menus = const [],
    this.disabled = false,
    this.onSelected,
  });

  @override
  State<BcMenubar> createState() => _BcMenubarState();
}

class _BcMenubarState extends State<BcMenubar> {
  int _openIndex = -1;

  void _close() {
    if (_openIndex != -1) {
      setState(() => _openIndex = -1);
    }
  }

  void _toggle(int index) {
    if (widget.disabled) return;
    final menu = widget.menus[index];
    if (menu.disabled || menu.items.isEmpty) return;

    setState(() {
      _openIndex = _openIndex == index ? -1 : index;
    });
  }

  void _pick(BcMenubarItem item) {
    if (item.disabled || item.separator) return;
    _close();
    widget.onSelected?.call(
      item.value,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegionSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: BcTheme.border),
              borderRadius: BorderRadius.circular(8),
              color: BcTheme.background,
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.menus.asMap().entries.map((entry) {
                return _buildRootItem(entry.key, entry.value);
              }).toList(),
            ),
          ),
          if (_openIndex != -1)
            TapRegion(
              onTapOutside: (_) => _close(),
              child: _buildSubmenu(widget.menus[_openIndex]),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmenu(BcMenubarMenu menu) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: BcTheme.popover,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: menu.items.map((item) {
            if (item.separator) {
              return Padding(
                key: ValueKey<String>('sep-${item.value}'),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                  color: BcTheme.border,
                ),
              );
            }
            return InkWell(
              key: ValueKey<String>('item-${item.value}'),
              onTap: item.disabled ? null : () => _pick(item),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.disabled
                        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                        : BcTheme.popoverForeground,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRootItem(int index, BcMenubarMenu menu) {
    final isOpen = _openIndex == index;
    final isDisabled = widget.disabled || menu.disabled;

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: isDisabled ? null : () => _toggle(index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          key: ValueKey<String>('root-${menu.label}'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isOpen ? BcTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            menu.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDisabled
                  ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                  : BcTheme.foreground,
            ),
          ),
        ),
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: isDisabled ? null : () => _toggle(index),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        child: Text(
          menu.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDisabled
                ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                : BcTheme.foreground,
          ),
        ),
      ),
    );
  }
}
