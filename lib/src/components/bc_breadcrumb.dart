library bc_breadcrumb;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcBreadcrumbItem {
  final String label;
  final String? path;
  final bool disabled;
  final bool active;

  const BcBreadcrumbItem({
    required this.label,
    this.path,
    this.disabled = false,
    this.active = false,
  });
}

class BcBreadcrumb extends StatelessWidget {
  final List<BcBreadcrumbItem> items;
  final String separator;
  final BcChangeHandler<String>? onSelected;
  final IconData? separatorIcon;

  const BcBreadcrumb({
    super.key,
    this.items = const [],
    this.separator = '/',
    this.onSelected,
    this.separatorIcon,
  });

  void _navigate(BcBreadcrumbItem item) {
    if (item.disabled || item.active) return;
    final path = item.path ?? item.label;
    onSelected?.call(
      path,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (i > 0) {
        children.add(_buildSeparator(context, i));
      }
      children.add(_buildItem(context, item));
    }

    return Semantics(
      label: 'Breadcrumb',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return Padding(
      key: Key('bc-breadcrumb-separator-$index'),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: separatorIcon != null
          ? Icon(
              separatorIcon,
              size: 14,
              color: BcTheme.mutedForeground,
            )
          : Text(
              separator,
              style: const TextStyle(
                color: BcTheme.mutedForeground,
                fontSize: 14,
              ),
            ),
    );
  }

  Widget _buildItem(BuildContext context, BcBreadcrumbItem item) {
    final isActive = item.active || item == items.last;
    final color = item.disabled
        ? BcTheme.mutedForeground.withValues(alpha: 0.5)
        : isActive
            ? BcTheme.foreground
            : BcTheme.mutedForeground;

    final labelWidget = Text(
      item.label,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      ),
    );

    if (item.disabled || isActive) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: labelWidget,
      );
    }

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: () => _navigate(item),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: labelWidget,
        ),
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: () => _navigate(item),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        minimumSize: Size.zero,
        child: labelWidget,
      ),
    );
  }
}
