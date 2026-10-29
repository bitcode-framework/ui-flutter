library bc_notification_center;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import '../theme/bc_theme.dart';

enum BcNotificationVariant { info, warning, error, success, mention, message }

class BcNotificationItemData {
  final String id;
  final BcNotificationVariant type;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? readAt;
  final String? createdAt;
  final String? notifiableType;
  final String? notifiableId;

  const BcNotificationItemData({
    required this.id,
    this.type = BcNotificationVariant.info,
    this.title,
    this.body,
    this.data,
    this.readAt,
    this.createdAt,
    this.notifiableType,
    this.notifiableId,
  });

  bool get isUnread => readAt == null || readAt!.isEmpty;

  BcNotificationItemData copyWith({
    BcNotificationVariant? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? readAt,
    String? createdAt,
    String? notifiableType,
    String? notifiableId,
  }) {
    return BcNotificationItemData(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      notifiableType: notifiableType ?? this.notifiableType,
      notifiableId: notifiableId ?? this.notifiableId,
    );
  }

  factory BcNotificationItemData.fromJson(Map<String, dynamic> json) {
    return BcNotificationItemData(
      id: (json['id'] ?? '').toString(),
      type: _parseVariant(json['type']),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      notifiableType: json['notifiable_type']?.toString(),
      notifiableId: json['notifiable_id']?.toString(),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  static BcNotificationVariant _parseVariant(dynamic v) {
    switch (v) {
      case 'warning':
        return BcNotificationVariant.warning;
      case 'error':
        return BcNotificationVariant.error;
      case 'success':
        return BcNotificationVariant.success;
      case 'mention':
        return BcNotificationVariant.mention;
      case 'message':
        return BcNotificationVariant.message;
      default:
        return BcNotificationVariant.info;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BcNotificationItemData && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class BcNotificationDataSource {
  final String? endpoint;
  final String? wsChannel;

  const BcNotificationDataSource({this.endpoint, this.wsChannel});
}

/// Notification center dropdown.
///
/// Mirrors the TS `BcNotificationCenter` contract (ADR-014 D2 §9). Renders
/// a bell icon with an unread badge, opens an adaptive dropdown panel
/// (Material PopupMenu / Cupertino ActionSheet) listing notifications, and
/// exposes mark-read / mark-all-read / load-more handlers.
///
/// Platform-aware (ADR-011): iOS uses CupertinoButton + CupertinoActionSheet;
/// Android uses IconButton + Material PopupMenu.
class BcNotificationCenter extends StatefulWidget {
  final List<BcNotificationItemData> notifications;
  final int unreadCount;
  final bool hasMore;
  final BcNotificationDataSource? dataSource;
  final bool loading;
  final String? error;
  final bool disabled;
  final String bellLabel;
  final String markAllReadLabel;
  final String emptyText;
  final String loadMoreText;
  final void Function(String id)? onMarkRead;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onLoadMore;
  final void Function(BcNotificationItemData item)? onItemClick;

  const BcNotificationCenter({
    super.key,
    this.notifications = const [],
    this.unreadCount = 0,
    this.hasMore = false,
    this.dataSource,
    this.loading = false,
    this.error,
    this.disabled = false,
    this.bellLabel = 'Notifications',
    this.markAllReadLabel = 'Mark all as read',
    this.emptyText = 'No notifications',
    this.loadMoreText = 'Load more',
    this.onMarkRead,
    this.onMarkAllRead,
    this.onLoadMore,
    this.onItemClick,
  });

  @override
  State<BcNotificationCenter> createState() => _BcNotificationCenterState();
}

class _BcNotificationCenterState extends State<BcNotificationCenter> {
  List<BcNotificationItemData> _fetched = const [];
  int _fetchedUnread = 0;
  bool _fetchedHasMore = false;
  bool _isLoading = false;
  String _loadError = '';
  int _page = 1;

  @override
  void initState() {
    super.initState();
    if (widget.dataSource != null) {
      _fetchPage(1, false);
    }
  }

  List<BcNotificationItemData> get _effectiveNotifications {
    if (widget.notifications.isNotEmpty) return widget.notifications;
    return _fetched;
  }

  int get _effectiveUnread {
    if (widget.unreadCount != 0) return widget.unreadCount;
    return _fetchedUnread;
  }

  bool get _effectiveHasMore {
    if (widget.hasMore) return true;
    return _fetchedHasMore;
  }

  bool get _effectiveLoading => widget.loading || _isLoading;

  String? get _effectiveError => widget.error ?? (_loadError.isEmpty ? null : _loadError);

  Future<void> _fetchPage(int pageNum, bool append) async {
    final ds = widget.dataSource;
    if (ds == null) return;
    setState(() {
      _isLoading = true;
      _loadError = '';
    });
    try {
      final endpoint = ds.endpoint ?? '/api/v1/notifications';
      final uri = Uri.parse(endpoint).replace(queryParameters: {
        'page': pageNum.toString(),
        'page_size': '20',
      });
      final resp = await http.get(uri, headers: {'Accept': 'application/json'});
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        setState(() {
          _loadError = 'Failed to load notifications (${resp.statusCode})';
          _isLoading = false;
        });
        return;
      }
      final body = jsonDecode(resp.body);
      final data = body is Map ? body['data'] : null;
      if (data is! List) {
        setState(() => _isLoading = false);
        return;
      }
      final records = data
          .whereType<Map>()
          .map((e) => BcNotificationItemData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final unread = body is Map ? (body['unread_count'] ?? 0) as int : 0;
      final total = body is Map ? (body['total'] ?? 0) as int : 0;
      final loaded = append ? _fetched.length + records.length : records.length;

      setState(() {
        if (append) {
          _fetched = [..._fetched, ...records];
        } else {
          _fetched = records;
        }
        _fetchedUnread = unread;
        _fetchedHasMore = loaded < total;
        _page = pageNum;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    }
  }

  void _markRead(String id) {
    widget.onMarkRead?.call(id);
    setState(() {
      _fetched = _fetched
          .map((n) => n.id == id ? n.copyWith(readAt: DateTime.now().toIso8601String()) : n)
          .toList();
      _fetchedUnread = _fetchedUnread > 0 ? _fetchedUnread - 1 : 0;
    });
  }

  void _markAllRead() {
    widget.onMarkAllRead?.call();
    setState(() {
      _fetched = _fetched
          .map((n) => n.copyWith(readAt: n.readAt ?? DateTime.now().toIso8601String()))
          .toList();
      _fetchedUnread = 0;
    });
  }

  void _loadMore() {
    if (!_effectiveHasMore || _effectiveLoading || widget.disabled) return;
    if (widget.dataSource != null || widget.notifications.isEmpty) {
      _fetchPage(_page + 1, true);
    }
    widget.onLoadMore?.call();
  }

  Color _variantColor(BcNotificationVariant v) {
    switch (v) {
      case BcNotificationVariant.warning:
        return BcTheme.warning;
      case BcNotificationVariant.error:
        return BcTheme.destructive;
      case BcNotificationVariant.success:
        return BcTheme.success;
      case BcNotificationVariant.mention:
        return BcTheme.info;
      case BcNotificationVariant.message:
        return BcTheme.primary;
      default:
        return BcTheme.mutedForeground;
    }
  }

  String _variantIconEmoji(BcNotificationVariant v) {
    switch (v) {
      case BcNotificationVariant.warning:
        return '\u26A0';
      case BcNotificationVariant.error:
        return '\u2716';
      case BcNotificationVariant.success:
        return '\u2714';
      case BcNotificationVariant.mention:
        return '@';
      case BcNotificationVariant.message:
        return '\u2709';
      default:
        return 'i';
    }
  }

  Widget _buildItem(BcNotificationItemData item) {
    final isUnread = item.isUnread;
    return InkWell(
      key: ValueKey<String>('bc_notification_item_${item.id}'),
      onTap: widget.disabled
          ? null
          : () {
              widget.onItemClick?.call(item);
              if (isUnread) _markRead(item.id);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUnread ? BcTheme.muted.withValues(alpha: 0.3) : Colors.transparent,
          border: Border(bottom: BorderSide(color: BcTheme.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _variantColor(item.type).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                _variantIconEmoji(item.type),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _variantColor(item.type),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title != null && item.title!.isNotEmpty)
                    Text(
                      item.title!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: BcTheme.foreground,
                      ),
                    ),
                  if (item.body != null && item.body!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.body!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  ],
                  if (item.createdAt != null && item.createdAt!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.createdAt!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 8, left: 8),
                decoration: const BoxDecoration(
                  color: BcTheme.destructive,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          widget.emptyText,
          style: const TextStyle(
            fontSize: 13,
            color: BcTheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: BcTheme.destructive),
      ),
    );
  }

  Widget _buildLoadMore() {
    return InkWell(
      key: const ValueKey<String>('bc_notification_load_more'),
      onTap: _effectiveLoading || widget.disabled ? null : _loadMore,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: Text(
          _effectiveLoading ? 'Loading...' : widget.loadMoreText,
          style: const TextStyle(
            fontSize: 12,
            color: BcTheme.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: BcTheme.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.bellLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_effectiveUnread > 0)
            TextButton(
              onPressed: widget.disabled ? null : _markAllRead,
              child: Text(
                widget.markAllReadLabel,
                style: const TextStyle(fontSize: 12, color: BcTheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPanelContent() {
    Widget body;
    if (_effectiveLoading && _effectiveNotifications.isEmpty) {
      body = _buildLoading();
    } else if (_effectiveError != null) {
      body = _buildError(_effectiveError!);
    } else if (_effectiveNotifications.isEmpty) {
      body = _buildEmpty();
    } else {
      body = ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in _effectiveNotifications) _buildItem(item),
            if (_effectiveHasMore) _buildLoadMore(),
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey<String>('bc_notification_panel'),
      width: 320,
      decoration: BoxDecoration(
        color: BcTheme.popover,
        border: Border.all(color: BcTheme.border),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          body,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = _effectiveUnread > 99
        ? '99+'
        : _effectiveUnread > 0
            ? _effectiveUnread.toString()
            : null;

    return Semantics(
      container: true,
      label: widget.bellLabel,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          PlatformWidget(
            material: (ctx, _) => PopupMenuButton<void>(
              key: const ValueKey<String>('bc_notification_bell'),
              tooltip: widget.bellLabel,
              enabled: !widget.disabled,
              onSelected: (_) {},
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: SizedBox(width: 320, child: _buildPanelContent()),
                ),
              ],
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BcTheme.muted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none, size: 20),
              ),
            ),
            cupertino: (ctx, _) => CupertinoButton(
              key: const ValueKey<String>('bc_notification_bell'),
              padding: EdgeInsets.zero,
              onPressed: widget.disabled
                  ? null
                  : () => _showCupertinoPanel(context),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BcTheme.muted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.bell, size: 20),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                key: const ValueKey<String>('bc_notification_badge'),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: BcTheme.destructive,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: BcTheme.destructiveForeground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCupertinoPanel(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(8),
        child: _buildPanelContent(),
      ),
    );
  }
}
