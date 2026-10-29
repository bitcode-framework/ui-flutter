library bc_navigation_menu;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single root entry in a [BcNavigationMenu].
///
/// Mirrors a tabbed-navigation item: [value] identifies the item, [label]
/// is the displayed text, and [panel] is the content widget revealed when
/// this item is active. When [disabled] is true the item cannot be
/// selected.
class BcNavigationMenuItem {
  final String value;
  final String label;
  final Widget? panel;
  final bool disabled;

  const BcNavigationMenuItem({
    required this.value,
    required this.label,
    this.panel,
    this.disabled = false,
  });
}

/// Navigation menu with root items and content panels.
///
/// Mirrors the TS `BcNavigationMenu` contract: a list of root items
/// rendered horizontally; selecting a root item reveals its associated
/// content panel while hiding the previously visible panel. Supports
/// controlled ([value]) and uncontrolled ([defaultValue]) selection.
/// Tapping a root item fires [onSelected] with the item's value and a
/// [BcChangeMeta]. Disabled root items are non-interactive.
///
/// Platform-aware: renders Cupertino-style tab affordances on iOS,
/// Material elsewhere.
class BcNavigationMenu extends StatefulWidget {
  final List<BcNavigationMenuItem> items;
  final String? value;
  final String? defaultValue;
  final Axis orientation;
  final BcChangeHandler<String>? onSelected;

  const BcNavigationMenu({
    super.key,
    this.items = const [],
    this.value,
    this.defaultValue,
    this.orientation = Axis.horizontal,
    this.onSelected,
  });

  @override
  State<BcNavigationMenu> createState() => _BcNavigationMenuState();
}

class _BcNavigationMenuState extends State<BcNavigationMenu> {
  String? _internalValue;

  bool get _isControlled => widget.value != null;

  String? get _currentValue => _isControlled ? widget.value : _internalValue;

  @override
  void initState() {
    super.initState();
    _internalValue = widget.defaultValue;
  }

  void _select(BcNavigationMenuItem item) {
    if (item.disabled) return;
    if (!_isControlled) {
      setState(() => _internalValue = item.value);
    }
    widget.onSelected?.call(
      item.value,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  Widget _buildRootItem(BcNavigationMenuItem item) {
    final isActive = _currentValue == item.value;
    final isDisabled = item.disabled;

    final labelColor = isDisabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : isActive
            ? BcTheme.primary
            : BcTheme.foreground;

    final labelWidget = Text(
      item.label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: labelColor,
      ),
    );

    final content = Container(
      key: ValueKey<String>('nav-root-${item.value}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: isActive
            ? Border(
                bottom: BorderSide(
                  color: isDisabled ? Colors.transparent : BcTheme.primary,
                  width: 2,
                ),
              )
            : null,
      ),
      child: labelWidget,
    );

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: isDisabled ? null : () => _select(item),
        child: content,
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: isDisabled ? null : () => _select(item),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: content,
      ),
    );
  }

  Widget _buildRootBar() {
    final children =
        widget.items.map((item) => _buildRootItem(item)).toList();

    if (widget.orientation == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeItem = widget.items.cast<BcNavigationMenuItem?>().firstWhere(
          (item) => item?.value == _currentValue,
          orElse: () => null,
        );

    final panel = activeItem?.panel ?? const SizedBox.shrink();

    return Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: BcTheme.border),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: widget.orientation == Axis.horizontal
                  ? Axis.horizontal
                  : Axis.vertical,
              child: _buildRootBar(),
            ),
          ),
          Flexible(child: panel),
        ],
      ),
    );
  }
}
