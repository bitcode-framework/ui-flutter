library bc_activity;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Social activity timeline that renders entries in chronological order with
/// timestamps and actor labels.
///
/// Mirrors TS `BcActivity` contract and validation contract VAL-M6-019/020.
///
/// VAL-M6-019: renders N entries in the provided order, each showing actor
/// label and formatted timestamp. Empty items renders emptyState (or default).
///
/// VAL-M6-020: tapping an item emits onItemClick with item id and a
/// BcChangeMeta (pointer source). When disabled, no callback fires. Items
/// without an id do not crash the handler.
///
/// ADR-008 upgraded surface: [dataSource] declarative fetch, [loading]
/// skeleton, [onLoadMore] pagination, [variant] layout (timeline/feed/compact),
/// [onItemAction] item click.
class BcActivity extends StatefulWidget {
  final List<BcActivityEntry> items;
  final bool disabled;
  final String emptyText;
  final Widget? emptyState;
  final BcChangeHandler<String>? onItemClick;

  /// Layout variant: timeline (avatar + gaps), feed (default), compact (dense).
  final BcActivityLayout variant;

  /// When true, renders skeleton placeholder rows instead of data.
  final bool loading;

  /// Declarative data-source binding. When provided, the widget fetches
  /// entries from the engine activity API on init.
  final BcActivityDataSource? dataSource;

  /// Called when the user taps the "Load more" affordance.
  /// Pagination callback — invoked when the user taps the "Load more" button.
  /// Declared as `void Function()` (not `Future<void>`) so simple synchronous
  /// callbacks (e.g. `() => page++`) work without an async wrapper.
  final void Function()? onLoadMore;

  /// Called when the user taps an activity entry. Receives the full entry.
  final void Function(BcActivityEntry entry)? onItemAction;

  /// Label for the "Load more" button.
  final String loadMoreText;

  const BcActivity({
    super.key,
    this.items = const [],
    this.disabled = false,
    this.emptyText = 'No activity',
    this.emptyState,
    this.onItemClick,
    this.variant = BcActivityLayout.feed,
    this.loading = false,
    this.dataSource,
    this.onLoadMore,
    this.onItemAction,
    this.loadMoreText = 'Load more',
  });

  @override
  State<BcActivity> createState() => _BcActivityState();
}

class _BcActivityState extends State<BcActivity> {
  List<BcActivityEntry> _fetched = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dataSource != null) {
      _fetchFromDataSource();
    }
  }

  Future<void> _fetchFromDataSource() async {
    final ds = widget.dataSource;
    if (ds == null) return;
    setState(() => _isLoading = true);
    try {
      final entries = await _fetchActivity(ds);
      if (mounted) {
        setState(() {
          _fetched = entries;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<BcActivityEntry>> _fetchActivity(BcActivityDataSource ds) async {
    final uri = Uri.parse(ds.endpoint ?? '/api/v1/activity');
    final params = Map<String, String>.from(ds.params ?? {});
    if (ds.model != null) params['model'] = ds.model!;
    if (ds.recordId != null) params['record_id'] = ds.recordId!;
    final url = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...params,
    });
    final resp = await http.get(url, headers: {'Accept': 'application/json'});
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return const [];
    }
    final body = jsonDecode(resp.body);
    final data = body is Map ? body['data'] : body;
    if (data is! List) return const [];
    return data
        .map((e) => BcActivityEntry(
              id: (e['id'] ?? '').toString(),
              actor: (e['actor'] ?? '').toString(),
              action: (e['verb'] ?? e['action'] ?? '').toString(),
              timestamp: (e['timestamp'] ?? '').toString(),
              target: e['target']?.toString(),
              variant: _parseVariant(e['variant']),
            ))
        .toList();
  }

  BcActivityVariant _parseVariant(dynamic v) {
    switch (v) {
      case 'success':
        return BcActivityVariant.success;
      case 'warning':
        return BcActivityVariant.warning;
      case 'destructive':
        return BcActivityVariant.destructive;
      case 'info':
        return BcActivityVariant.info;
      default:
        return BcActivityVariant.defaultVariant;
    }
  }

  List<BcActivityEntry> get _effectiveItems {
    if (widget.items.isNotEmpty) return widget.items;
    return _fetched;
  }

  bool get _showLoading => widget.loading || (widget.dataSource != null && _isLoading);

  Color _variantColor(BcActivityVariant variant) {
    switch (variant) {
      case BcActivityVariant.success:
        return BcTheme.success;
      case BcActivityVariant.warning:
        return BcTheme.warning;
      case BcActivityVariant.destructive:
        return BcTheme.destructive;
      case BcActivityVariant.info:
        return BcTheme.info;
      case BcActivityVariant.defaultVariant:
        return BcTheme.primary;
    }
  }

  IconData _variantIcon(BcActivityVariant variant) {
    switch (variant) {
      case BcActivityVariant.success:
        return Icons.check_circle_outline;
      case BcActivityVariant.warning:
        return Icons.warning_amber_outlined;
      case BcActivityVariant.destructive:
        return Icons.error_outline;
      case BcActivityVariant.info:
        return Icons.info_outline;
      case BcActivityVariant.defaultVariant:
        return Icons.radio_button_unchecked;
    }
  }

  void _onTap(BcActivityEntry entry) {
    if (widget.disabled) return;
    widget.onItemClick?.call(
      entry.id,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
    widget.onItemAction?.call(entry);
  }

  Widget _buildAvatar(BcActivityEntry entry) {
    final initial = entry.actor.isEmpty
        ? '?'
        : entry.actor.substring(0, 1).toUpperCase();
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _variantColor(entry.variant),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: BcTheme.primaryForeground,
        ),
      ),
    );
  }

  Widget _buildItem(BcActivityEntry entry, int index) {
    final variantKey = 'bc_activity_${widget.variant.name}_$index';
    final content = Container(
      key: ValueKey<String>(variantKey),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: BcTheme.border),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(entry),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.actor,
                        key: ValueKey<String>(
                            'bc_activity_actor_${entry.id}_$index'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BcTheme.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        entry.action,
                        key: ValueKey<String>(
                            'bc_activity_action_${entry.id}_$index'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      _variantIcon(entry.variant),
                      size: 12,
                      color: _variantColor(entry.variant),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        entry.timestamp,
                        key: ValueKey<String>(
                            'bc_activity_timestamp_${entry.id}_$index'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                if (entry.target != null && entry.target!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.target!,
                    key: ValueKey<String>(
                        'bc_activity_target_${entry.id}_$index'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: BcTheme.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.disabled) {
      return Opacity(opacity: 0.6, child: content);
    }

    return PlatformWidget(
      material: (ctx, _) => Material(
        color: Colors.transparent,
        child: InkWell(
        onTap: () => _onTap(entry),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
        child: content,
        ),
      ),
      cupertino: (ctx, _) => CupertinoButton(
        onPressed: () => _onTap(entry),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: content,
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: BcTheme.border),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BcTheme.muted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: BcTheme.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 120,
                  decoration: BoxDecoration(
                    color: BcTheme.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: PlatformWidget(
          material: (ctx, _) => Material(
            color: BcTheme.muted,
            borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
            child: InkWell(
              key: const ValueKey<String>('bc_activity_load_more'),
              onTap: widget.onLoadMore,
              borderRadius:
                  const BorderRadius.all(Radius.circular(BcTheme.radius)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.loadMoreText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BcTheme.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          cupertino: (ctx, _) => CupertinoButton(
            key: const ValueKey<String>('bc_activity_load_more'),
            onPressed: widget.onLoadMore,
            color: BcTheme.muted,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.loadMoreText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoading) {
      return Semantics(
        container: true,
        label: 'Loading activity',
        child: Column(
          key: const ValueKey<String>('bc_activity_loading'),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSkeletonItem(),
              ),
          ],
        ),
      );
    }

    final items = _effectiveItems;
    if (items.isEmpty) {
      return widget.emptyState ??
          Center(
            key: const ValueKey<String>('bc_activity_empty'),
            child: Text(
              widget.emptyText,
              style: const TextStyle(
                fontSize: 14,
                color: BcTheme.mutedForeground,
              ),
            ),
          );
    }

    final children = <Widget>[
      for (var i = 0; i < items.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildItem(items[i], i),
        ),
    ];

    if (widget.onLoadMore != null) {
      children.add(_buildLoadMore());
    }

    return Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
