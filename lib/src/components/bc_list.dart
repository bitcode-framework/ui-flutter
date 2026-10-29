library bc_list;

import 'package:flutter/material.dart';

/// Material-only list view (ADR-011 Section 5).
/// Pure Material 3 — no Cupertino counterpart.
class BcList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, T item)? trailingBuilder;
  final Widget Function(BuildContext context, T item)? leadingBuilder;
  final void Function(T item)? onTap;
  final Widget? header;
  final Widget? emptyState;
  final bool shrinkWrap;

  const BcList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.trailingBuilder,
    this.leadingBuilder,
    this.onTap,
    this.header,
    this.emptyState,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && emptyState != null) {
      return emptyState!;
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      itemCount: items.length + (header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header!;
        final itemIndex = header != null ? index - 1 : index;
        final item = items[itemIndex];

        return Material(
          color: Colors.transparent,
          child: ListTile(
            leading: leadingBuilder?.call(context, item),
            title: itemBuilder(context, item, itemIndex),
            trailing: trailingBuilder?.call(context, item),
            onTap: onTap != null ? () => onTap!(item) : null,
          ),
        );
      },
    );
  }
}
