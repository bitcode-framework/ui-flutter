library bc_virtual_scroller;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single item rendered by [BcVirtualScroller].
///
/// Mirrors the TS `BcVirtualScrollerItem` interface.
class BcVirtualScrollerItem {
  final String id;
  final String label;
  final String? description;

  const BcVirtualScrollerItem({
    required this.id,
    required this.label,
    this.description,
  });

  @override
  String toString() =>
      'BcVirtualScrollerItem(id: $id, label: $label, description: $description)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcVirtualScrollerItem &&
          id == other.id &&
          label == other.label &&
          description == other.description;

  @override
  int get hashCode => Object.hash(id, label, description);
}

/// Windowed virtual list for large datasets.
///
/// Mirrors the TS `BcVirtualScroller` contract and validation contract
/// (VAL-M5-033..036). Only the visible window of items is rendered, keeping
/// the rendered node count bounded regardless of the dataset size. As the
/// viewport scrolls, the rendered window updates and each node displays the
/// correct content for its underlying data index.
///
/// Provides a [scrollToIndex] programmatic API via the
/// [BcVirtualScrollerController]. An out-of-range index clamps to the nearest
/// valid index without throwing.
///
/// An empty dataset renders an empty state without error and without item nodes.
class BcVirtualScroller extends StatefulWidget {
  final List<BcVirtualScrollerItem> items;
  final double height;
  final double itemHeight;
  final int overscan;
  final String emptyText;
  final BcVirtualScrollerController? controller;
  final void Function(int index, BcChangeMeta meta)? onIndexChange;

  const BcVirtualScroller({
    super.key,
    this.items = const [],
    this.height = 400,
    this.itemHeight = 48,
    this.overscan = 3,
    this.emptyText = 'No items',
    this.controller,
    this.onIndexChange,
  });

  @override
  State<BcVirtualScroller> createState() => _BcVirtualScrollerState();
}

class _BcVirtualScrollerState extends State<BcVirtualScroller> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant BcVirtualScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  void _scrollToIndex(int index) {
    if (widget.items.isEmpty) return;
    final clamped = index.clamp(0, widget.items.length - 1);
    final targetOffset = clamped * widget.itemHeight;
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _doScrollToIndex(clamped, targetOffset);
      });
      return;
    }
    _doScrollToIndex(clamped, targetOffset);
  }

  void _doScrollToIndex(int clamped, double targetOffset) {
    final maxExtent = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxExtent);
    _scrollController.animateTo(
      clampedOffset.toDouble(),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    widget.onIndexChange?.call(
      clamped,
      const BcChangeMeta(
        reason: BcChangeReason.valueChange,
        source: BcEventSource.programmatic,
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(BcVirtualScrollerItem item) {
    return Container(
      key: ValueKey<String>('vs-item-${item.id}'),
      height: widget.itemHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: BcTheme.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            key: ValueKey<String>('vs-label-${item.id}'),
            style: const TextStyle(
              fontSize: 14,
              color: BcTheme.foreground,
            ),
          ),
          if (item.description != null && item.description!.isNotEmpty)
            Text(
              item.description!,
              key: ValueKey<String>('vs-desc-${item.id}'),
              style: const TextStyle(
                fontSize: 11,
                color: BcTheme.mutedForeground,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            widget.emptyText,
            key: const ValueKey<String>('vs-empty'),
            style: const TextStyle(
              fontSize: 14,
              color: BcTheme.mutedForeground,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildItem(widget.items[index]),
              childCount: widget.items.length,
            ),
          ),
        ],
      ),
    );
  }
}

/// Imperative controller for [BcVirtualScroller].
///
/// Provides [scrollToIndex] to programmatically position an item into view.
class BcVirtualScrollerController {
  _BcVirtualScrollerState? _state;

  void _attach(_BcVirtualScrollerState state) => _state = state;
  void _detach() => _state = null;

  /// Positions the viewport such that [index] is brought into view.
  /// Out-of-range indices clamp to the nearest valid index without throwing.
  void scrollToIndex(int index) {
    _state?._scrollToIndex(index);
  }
}
