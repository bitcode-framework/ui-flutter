library bc_megamenu;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcMegaMenuLink {
  final String label;
  final String value;
  final String? description;
  final bool disabled;

  const BcMegaMenuLink({
    required this.label,
    required this.value,
    this.description,
    this.disabled = false,
  });
}

class BcMegaMenuColumn {
  final String? title;
  final List<BcMegaMenuLink> links;

  const BcMegaMenuColumn({
    this.title,
    this.links = const [],
  });
}

class BcMegaMenuItem {
  final String label;
  final List<BcMegaMenuColumn> columns;

  const BcMegaMenuItem({
    required this.label,
    this.columns = const [],
  });
}

class BcMegaMenu extends StatefulWidget {
  final List<BcMegaMenuItem> items;
  final bool disabled;
  final BcChangeHandler<String>? onSelected;
  final VoidCallback? onClose;

  const BcMegaMenu({
    super.key,
    this.items = const [],
    this.disabled = false,
    this.onSelected,
    this.onClose,
  });

  @override
  State<BcMegaMenu> createState() => _BcMegaMenuState();
}

class _BcMegaMenuState extends State<BcMegaMenu> {
  int _openIndex = -1;
  bool _justClosed = false;

  void _close({bool notify = true}) {
    if (_openIndex == -1) return;
    setState(() {
      _openIndex = -1;
      _justClosed = true;
    });
    if (notify) {
      widget.onClose?.call();
    }
  }

  void _toggle(int index) {
    if (widget.disabled) return;

    if (_justClosed) {
      _justClosed = false;
      return;
    }

    setState(() {
      _openIndex = _openIndex == index ? -1 : index;
    });
  }

  void _pick(BcMegaMenuLink link) {
    if (link.disabled) return;
    setState(() => _openIndex = -1);
    widget.onSelected?.call(
      link.value,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.asMap().entries.map((entry) {
            return _buildTrigger(entry.key, entry.value);
          }).toList(),
        ),
        if (_openIndex != -1) ...[
          const SizedBox(height: 4),
          TapRegion(
            onTapOutside: (_) => _close(),
            child: _buildPanel(widget.items[_openIndex]),
          ),
        ],
      ],
    );
  }

  Widget _buildPanel(BcMegaMenuItem item) {
    final nonEmptyColumns =
        item.columns.where((c) => c.links.isNotEmpty).toList();
    if (nonEmptyColumns.isEmpty) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: BcTheme.popover,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: nonEmptyColumns.map((col) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildColumn(col),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(BcMegaMenuColumn col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (col.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              col.title!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
        ...col.links.map((link) => _buildLink(link)),
      ],
    );
  }

  Widget _buildLink(BcMegaMenuLink link) {
    return InkWell(
      key: ValueKey<String>('link-${link.value}'),
      onTap: link.disabled ? null : () => _pick(link),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              link.label,
              style: TextStyle(
                fontSize: 14,
                color: link.disabled
                    ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                    : BcTheme.popoverForeground,
              ),
            ),
            if (link.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  link.description!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrigger(int index, BcMegaMenuItem item) {
    final isOpen = _openIndex == index;

    return PlatformWidget(
      material: (ctx, _) => InkWell(
        onTap: widget.disabled ? null : () => _toggle(index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          key: ValueKey<String>('trigger-${item.label}'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isOpen ? BcTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.disabled
                  ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                  : BcTheme.foreground,
            ),
          ),
        ),
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: widget.disabled ? null : () => _toggle(index),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size.zero,
        child: Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.disabled
                ? BcTheme.mutedForeground.withValues(alpha: 0.5)
                : BcTheme.foreground,
          ),
        ),
      ),
    );
  }
}
