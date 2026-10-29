library bc_panel_menu;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single item (group or child) in a [BcPanelMenu].
///
/// Mirrors the TS `BcPanelMenuItem` interface. Groups have [children];
/// leaf items do not. When [disabled] is true, the item cannot be toggled
/// (for groups) or selected (for children).
class BcPanelMenuItem {
  final String key;
  final String label;
  final IconData? icon;
  final bool disabled;
  final List<BcPanelMenuItem>? children;

  const BcPanelMenuItem({
    required this.key,
    required this.label,
    this.icon,
    this.disabled = false,
    this.children,
  });
}

/// Panel menu with expandable/collapsible groups.
///
/// Mirrors the TS `BcPanelMenu` contract: renders a vertical list of groups
/// (parent items). Tapping a group header toggles its child items between
/// visible and hidden; the header chevron rotates to indicate the expanded
/// or collapsed state.
///
/// Tapping a child item invokes [onSelected] with that item's value (its
/// [BcPanelMenuItem.key]) and a [BcChangeMeta]; the selected item receives
/// an active visual state.
///
/// When a group is collapsed, its children are not rendered and cannot be
/// selected.
///
/// Supports controlled ([expandedKeys]) and uncontrolled ([defaultExpandedKeys])
/// expansion. When `expandedKeys` is controlled, tapping a header fires
/// [onGroupToggle] but does not change visibility until the parent updates
/// `expandedKeys`.
///
/// Platform-aware: uses PlatformIconButton for chevrons on iOS (Cupertino),
/// Material elsewhere.
class BcPanelMenu extends StatefulWidget {
  final List<BcPanelMenuItem> items;
  final List<String>? expandedKeys;
  final List<String> defaultExpandedKeys;
  final String? selectedKey;
  final void Function(
    String key,
    bool expanded,
    BcChangeMeta meta,
  )? onGroupToggle;
  final void Function(BcPanelMenuItem item, BcChangeMeta meta)? onSelected;

  const BcPanelMenu({
    super.key,
    this.items = const [],
    this.expandedKeys,
    this.defaultExpandedKeys = const [],
    this.selectedKey,
    this.onGroupToggle,
    this.onSelected,
  });

  @override
  State<BcPanelMenu> createState() => _BcPanelMenuState();
}

class _BcPanelMenuState extends State<BcPanelMenu>
    with SingleTickerProviderStateMixin {
  late List<String> _internalExpanded;
  String? _internalSelected;

  bool get _isExpandedControlled => widget.expandedKeys != null;

  List<String> get _expandedKeys =>
      _isExpandedControlled ? widget.expandedKeys! : _internalExpanded;

  bool get _isSelectedControlled => widget.selectedKey != null;

  String? get _selectedKey =>
      _isSelectedControlled ? widget.selectedKey : _internalSelected;

  @override
  void initState() {
    super.initState();
    _internalExpanded = List.from(widget.defaultExpandedKeys);
  }

  bool _isExpanded(String key) => _expandedKeys.contains(key);

  void _toggleGroup(BcPanelMenuItem item) {
    if (item.disabled) return;

    final willExpand = !_isExpanded(item.key);

    if (!_isExpandedControlled) {
      setState(() {
        if (willExpand) {
          _internalExpanded.add(item.key);
        } else {
          _internalExpanded.remove(item.key);
        }
      });
    }

    widget.onGroupToggle?.call(
      item.key,
      willExpand,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _selectChild(BcPanelMenuItem child) {
    if (child.disabled) return;

    if (!_isSelectedControlled) {
      setState(() => _internalSelected = child.key);
    }

    widget.onSelected?.call(
      child,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  Widget _buildGroupHeader(BcPanelMenuItem item) {
    final expanded = _isExpanded(item.key);
    final hasChildren = item.children != null && item.children!.isNotEmpty;

    final iconColor = item.disabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : BcTheme.foreground;

    final headerContent = Container(
      key: ValueKey<String>('panel-header-${item.key}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.disabled ? BcTheme.muted.withValues(alpha: 0.3) : null,
      ),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
            ),
          ),
          if (hasChildren)
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: item.disabled
                    ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                    : BcTheme.mutedForeground,
              ),
            ),
        ],
      ),
    );

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: item.disabled ? null : () => _toggleGroup(item),
        child: headerContent,
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: item.disabled ? null : () => _toggleGroup(item),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: headerContent,
      ),
    );
  }

  Widget _buildChild(BcPanelMenuItem child, int groupIndex) {
    final isSelected = _selectedKey == child.key;
    final isDisabled = child.disabled;

    final bgColor = isSelected
        ? BcTheme.primary.withValues(alpha: 0.1)
        : Colors.transparent;
    final textColor = isDisabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : isSelected
            ? BcTheme.primary
            : BcTheme.foreground;

    final childContent = Container(
      key: ValueKey<String>('panel-child-${child.key}'),
      padding: const EdgeInsets.only(left: 36, right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        children: [
          if (child.icon != null) ...[
            Icon(child.icon, size: 16, color: textColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              child.label,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: child.disabled ? null : () => _selectChild(child),
        child: childContent,
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: child.disabled ? null : () => _selectChild(child),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: childContent,
      ),
    );
  }

  Widget _buildGroup(BcPanelMenuItem item, int index) {
    final expanded = _isExpanded(item.key);
    final hasChildren = item.children != null && item.children!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: index < widget.items.length - 1
            ? const Border(
                bottom: BorderSide(color: BcTheme.border),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGroupHeader(item),
          if (expanded && hasChildren)
            Container(
              decoration: BoxDecoration(
                color: BcTheme.muted.withValues(alpha: 0.15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: item.children!
                    .map((child) => _buildChild(child, index))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: BcTheme.border),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: BcTheme.background,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.items
              .asMap()
              .entries
              .map((entry) => _buildGroup(entry.value, entry.key))
              .toList(),
        ),
      ),
    );
  }
}
