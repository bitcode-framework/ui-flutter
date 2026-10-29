library bc_sidebar;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Sidebar navigation item.
class BcSidebarItem {
  final String value;
  final String label;
  final IconData? icon;
  final bool disabled;
  final bool isDivider;

  const BcSidebarItem({
    required this.value,
    required this.label,
    this.icon,
    this.disabled = false,
    this.isDivider = false,
  });

  @override
  String toString() =>
      'BcSidebarItem(value: $value, label: $label, icon: $icon, disabled: $disabled)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcSidebarItem &&
          value == other.value &&
          label == other.label &&
          icon == other.icon &&
          disabled == other.disabled &&
          isDivider == other.isDivider;

  @override
  int get hashCode => Object.hash(value, label, icon, disabled, isDivider);
}

/// Sidebar side.
enum BcSidebarSide { left, right }

/// Collapsible navigation panel (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcSidebarContract] ({ title?, width?, collapsedWidth?,
/// collapsed?, side?, onToggle? }).
///
/// Renders a vertical navigation panel with menu items. Collapsing the
/// sidebar hides item labels (showing icons only). Expanding shows full
/// labels. The collapsed/expanded state emits [onCollapsedChange] with
/// the boolean state and [BcChangeMeta]. Item selection emits
/// [onSelected] with the item's value and [BcChangeMeta].
class BcSidebar extends StatefulWidget {
  final String? title;
  final double width;
  final double collapsedWidth;
  final bool? collapsed;
  final bool? defaultCollapsed;
  final BcSidebarSide side;
  final List<BcSidebarItem> items;
  final String? selectedValue;
  final BcChangeHandler<bool>? onCollapsedChange;
  final BcChangeHandler<String>? onSelected;

  const BcSidebar({
    super.key,
    this.title,
    this.width = 240,
    this.collapsedWidth = 64,
    this.collapsed,
    this.defaultCollapsed,
    this.side = BcSidebarSide.left,
    this.items = const [],
    this.selectedValue,
    this.onCollapsedChange,
    this.onSelected,
  });

  @override
  State<BcSidebar> createState() => _BcSidebarState();
}

class _BcSidebarState extends State<BcSidebar> {
  bool _internalCollapsed = false;
  String? _internalSelected;

  @override
  void initState() {
    super.initState();
    _internalCollapsed = widget.defaultCollapsed ?? false;
    _internalSelected = widget.items
        .where((i) => !i.isDivider && !i.disabled)
        .firstOrNull
        ?.value;
  }

  @override
  void didUpdateWidget(BcSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultCollapsed != oldWidget.defaultCollapsed) {
      _internalCollapsed = widget.defaultCollapsed ?? false;
    }
  }

  bool get _isCollapsed => widget.collapsed ?? _internalCollapsed;

  String? get _currentSelected => widget.selectedValue ?? _internalSelected;

  void _toggleCollapse() {
    final next = !_isCollapsed;

    if (widget.collapsed == null) {
      setState(() => _internalCollapsed = next);
    }

    widget.onCollapsedChange?.call(
      next,
      const BcChangeMeta(
        reason: BcChangeReason.toggle,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _selectItem(BcSidebarItem item) {
    if (item.disabled || item.isDivider) return;

    if (widget.selectedValue == null) {
      setState(() => _internalSelected = item.value);
    }

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
    final effectiveWidth = _isCollapsed ? widget.collapsedWidth : widget.width;

    final children = <Widget>[];

    children.add(_buildHeader());

    children.add(const Divider(height: 1, color: BcTheme.border));

    children.add(
      Expanded(
        child: ListView(
          key: const Key('bc_sidebar_items'),
          padding: EdgeInsets.zero,
          children: widget.items.map((item) {
            if (item.isDivider) {
              return Padding(
                key: Key('bc_sidebar_item_${item.value}'),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Divider(height: 1, color: BcTheme.border),
              );
            }
            return _buildItem(item);
          }).toList(),
        ),
      ),
    );

    children.add(_buildCollapseButton());

    Widget sidebar = Container(
      key: const Key('bc_sidebar'),
      width: effectiveWidth,
      decoration: BoxDecoration(
        color: BcTheme.background,
        border: Border(
          right: widget.side == BcSidebarSide.left
              ? const BorderSide(color: BcTheme.border)
              : BorderSide.none,
          left: widget.side == BcSidebarSide.right
              ? const BorderSide(color: BcTheme.border)
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: children,
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: effectiveWidth,
      child: sidebar,
    );
  }

  Widget _buildHeader() {
    return Container(
      key: const Key('bc_sidebar_header'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          if (widget.title != null)
            Expanded(
              child: _isCollapsed
                  ? Center(
                      child: Text(
                        widget.title!.characters.first,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: BcTheme.foreground,
                        ),
                      ),
                    )
                  : Text(
                      widget.title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: BcTheme.foreground,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildItem(BcSidebarItem item) {
    final isSelected = item.value == _currentSelected;

    final bgColor = isSelected
        ? BcTheme.primary.withValues(alpha: 0.1)
        : Colors.transparent;
    final textColor = item.disabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : isSelected
            ? BcTheme.primary
            : BcTheme.foreground;
    final iconColor = item.disabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : isSelected
            ? BcTheme.primary
            : BcTheme.mutedForeground;

    return InkWell(
      key: Key('bc_sidebar_item_${item.value}'),
      onTap: item.disabled ? null : () => _selectItem(item),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _isCollapsed ? 0 : 16,
          vertical: 12,
        ),
        color: bgColor,
        child: _isCollapsed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null)
                    Icon(item.icon, size: 22, color: iconColor)
                  else
                    Text(
                      item.label.isNotEmpty
                          ? item.label.characters.first
                          : '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                ],
              )
            : Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 20, color: iconColor),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Container(
      key: const Key('bc_sidebar_collapse_btn'),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: BcTheme.border)),
      ),
      child: InkWell(
        onTap: _toggleCollapse,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: _isCollapsed
              ? Center(
                  child: Icon(
                    widget.side == BcSidebarSide.left
                        ? Icons.menu_open
                        : Icons.menu_open_outlined,
                    size: 22,
                    color: BcTheme.mutedForeground,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      widget.side == BcSidebarSide.left
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      size: 20,
                      color: BcTheme.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Collapse',
                      style: TextStyle(
                        fontSize: 13,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
