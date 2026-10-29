library bc_tiered_menu;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single item in a [BcTieredMenu].
///
/// Mirrors the TS `BcTieredMenuItem` interface. Items with non-empty
/// [children] open a submenu when activated; leaf items fire [onSelect].
/// When [disabled] is true, the item is non-interactive.
class BcTieredMenuItem {
  final String key;
  final String label;
  final IconData? icon;
  final bool disabled;
  final List<BcTieredMenuItem>? children;

  const BcTieredMenuItem({
    required this.key,
    required this.label,
    this.icon,
    this.disabled = false,
    this.children,
  });

  @override
  String toString() =>
      'BcTieredMenuItem(key: $key, label: $label, disabled: $disabled, children: $children)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcTieredMenuItem &&
          key == other.key &&
          label == other.label &&
          icon == other.icon &&
          disabled == other.disabled &&
          _listEquals(children, other.children);

  @override
  int get hashCode => Object.hash(
        key,
        label,
        icon,
        disabled,
        Object.hashAll(children ?? const []),
      );

  static bool _listEquals(List<BcTieredMenuItem>? a, List<BcTieredMenuItem>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Cascading menu with submenus.
///
/// Mirrors the TS `BcTieredMenu` contract and validation contract
/// (VAL-M5-037..040). Root items render as a vertical list. Activating
/// (hover/focus/tap) a root item that has children reveals its submenu as an
/// adjacent nested panel; nested submenus cascade deeper as applicable.
/// Selecting a leaf item fires [onSelect] with the selected item and a
/// [BcChangeMeta]. The full path from root to selected leaf is resolvable via
/// [selectedPath].
///
/// Moving focus away from the menu closes all open submenus and resets
/// transient highlight state. Items with [BcTieredMenuItem.disabled] = true
/// render a disabled visual state and are not selectable.
///
/// Platform-aware: tappable rows use Cupertino on iOS, Material elsewhere.
class BcTieredMenu extends StatefulWidget {
  final List<BcTieredMenuItem> items;
  final List<String>? expandedKeys;
  final void Function(BcTieredMenuItem item, List<String> path)? onSelect;
  final void Function(List<String> path)? selectedPath;
  final FocusNode? focusNode;
  final bool autofocus;

  const BcTieredMenu({
    super.key,
    this.items = const [],
    this.expandedKeys,
    this.onSelect,
    this.selectedPath,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<BcTieredMenu> createState() => _BcTieredMenuState();
}

class _BcTieredMenuState extends State<BcTieredMenu> {
  late FocusNode _focusNode;
  late List<String> _internalExpanded;

  bool get _isControlled => widget.expandedKeys != null;
  List<String> get _expandedKeys =>
      _isControlled ? widget.expandedKeys! : _internalExpanded;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
    _internalExpanded = const [];
  }

  @override
  void didUpdateWidget(covariant BcTieredMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  bool _isExpanded(String key) => _expandedKeys.contains(key);

  void _toggleExpand(BcTieredMenuItem item, List<String> path) {
    if (item.disabled) return;
    final willExpand = !_isExpanded(item.key);

    if (!_isControlled) {
      setState(() {
        if (willExpand) {
          _internalExpanded = [..._expandedKeys, item.key];
        } else {
          _internalExpanded =
              _expandedKeys.where((k) => k != item.key).toList();
        }
      });
    }

    if (!willExpand) {
      _closeDescendants(item);
    }
  }

  void _closeDescendants(BcTieredMenuItem item) {
    final keys = _collectChildKeys(item);
    if (keys.isEmpty) return;
    if (!_isControlled) {
      setState(() {
        _internalExpanded =
            _internalExpanded.where((k) => !keys.contains(k)).toList();
      });
    }
  }

  Set<String> _collectChildKeys(BcTieredMenuItem item) {
    final keys = <String>{};
    void walk(List<BcTieredMenuItem>? children) {
      if (children == null) return;
      for (final child in children) {
        keys.add(child.key);
        walk(child.children);
      }
    }
    walk(item.children);
    return keys;
  }

  void _selectLeaf(BcTieredMenuItem item, List<String> path) {
    if (item.disabled) return;
    widget.onSelect?.call(item, path);
    widget.selectedPath?.call(path);
    if (!_isControlled) {
      setState(() => _internalExpanded = const []);
    }
  }

  void _onFocusChange(bool hasFocus) {
    if (!hasFocus && !_isControlled) {
      setState(() => _internalExpanded = const []);
    }
  }

  Widget _buildRow(
    BcTieredMenuItem item,
    List<String> path,
    int depth,
  ) {
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final expanded = _isExpanded(item.key);
    final isDisabled = item.disabled;

    final textColor = isDisabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : BcTheme.foreground;
    final bgColor = expanded
        ? BcTheme.primary.withValues(alpha: 0.08)
        : Colors.transparent;

    final row = Container(
      key: ValueKey<String>('tm-row-${item.key}'),
      padding: EdgeInsets.only(
        left: 12.0 + depth * 16,
        right: 12,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 16, color: textColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              item.label,
              key: ValueKey<String>('tm-label-${item.key}'),
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
          if (hasChildren)
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 120),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: isDisabled
                    ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                    : BcTheme.mutedForeground,
              ),
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlatformWidget(
          material: (ctx, _) => InkWell(
            onTap: isDisabled
                ? null
                : () {
                    if (hasChildren) {
                      _toggleExpand(item, path);
                    } else {
                      _selectLeaf(item, path);
                    }
                  },
            child: row,
          ),
          cupertino: (ctx, _) => CupertinoButton(
            onPressed: isDisabled
                ? null
                : () {
                    if (hasChildren) {
                      _toggleExpand(item, path);
                    } else {
                      _selectLeaf(item, path);
                    }
                  },
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            child: row,
          ),
        ),
        if (expanded && hasChildren)
          Container(
            decoration: BoxDecoration(
              color: BcTheme.muted.withValues(alpha: 0.15),
              border: Border(
                left: BorderSide(
                  color: BcTheme.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: item.children!
                  .map((child) => _buildRow(child, [...path, child.key], depth + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: _onFocusChange,
      child: Semantics(
        container: true,
        child: Container(
          key: const ValueKey<String>('tiered-menu-root'),
          decoration: BoxDecoration(
            border: Border.all(color: BcTheme.border),
            borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
            color: BcTheme.background,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.items
                .map((item) => _buildRow(item, [item.key], 0))
                .toList(),
          ),
        ),
      ),
    );
  }
}
