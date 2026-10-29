library bc_view_activity;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single activity feed entry in a [BcViewActivity].
///
/// Mirrors the TS `BcViewActivityEntry` interface: [timestamp] is an ISO-8601
/// string; [actor] is the name/avatar label; [action] is the action label;
/// [detail] is the optional body content.
class BcViewActivityEntry {
  final String id;
  final DateTime timestamp;
  final String actor;
  final String action;
  final String? detail;

  const BcViewActivityEntry({
    required this.id,
    required this.timestamp,
    required this.actor,
    required this.action,
    this.detail,
  });

  @override
  String toString() =>
      'BcViewActivityEntry(id: $id, timestamp: $timestamp, actor: $actor, action: $action, detail: $detail)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcViewActivityEntry &&
          id == other.id &&
          timestamp == other.timestamp &&
          actor == other.actor &&
          action == other.action &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(id, timestamp, actor, action, detail);
}

/// Activity feed timeline that renders entries in chronological order.
///
/// Mirrors the TS `BcViewActivity` contract and validation contract
/// (VAL-M5-030..032): entries are sorted with the newest first (descending by
/// timestamp); identical timestamps preserve their input order (stable sort).
/// Each rendered item displays the actor, action, formatted timestamp, and
/// optional detail body. Tapping an item fires [onItemSelect] with the item's
/// id and a [BcChangeMeta]; the selected item reflects a selected visual
/// state and (in single-select mode) the previously selected item is
/// deselected.
///
/// Platform-aware: tappable items use Cupertino on iOS, Material elsewhere.
class BcViewActivity extends StatefulWidget {
  final List<BcViewActivityEntry> entries;
  final String? selectedId;
  final bool groupByDay;
  final String emptyText;
  final BcChangeHandler<String>? onItemSelect;

  const BcViewActivity({
    super.key,
    this.entries = const [],
    this.selectedId,
    this.groupByDay = false,
    this.emptyText = 'No activity',
    this.onItemSelect,
  });

  @override
  State<BcViewActivity> createState() => _BcViewActivityState();
}

class _BcViewActivityState extends State<BcViewActivity> {
  String? _internalSelected;

  bool get _isControlled => widget.selectedId != null;
  String? get _selectedId =>
      _isControlled ? widget.selectedId : _internalSelected;

  List<BcViewActivityEntry> get _sorted {
    final indexed = widget.entries.asMap().entries.toList();
    indexed.sort((a, b) {
      final cmp = b.value.timestamp.compareTo(a.value.timestamp);
      if (cmp != 0) return cmp;
      return a.key.compareTo(b.key);
    });
    return indexed.map((e) => e.value).toList(growable: false);
  }

  void _onTap(BcViewActivityEntry entry) {
    if (!_isControlled) {
      setState(() => _internalSelected = entry.id);
    }
    widget.onItemSelect?.call(
      entry.id,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }

  Widget _buildAvatar(String actor) {
    final initial =
        actor.isEmpty ? '?' : actor.substring(0, 1).toUpperCase();
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: BcTheme.primary,
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

  Widget _buildItem(BcViewActivityEntry entry, bool selected) {
    final bg = selected ? BcTheme.primary.withValues(alpha: 0.08) : Colors.transparent;
    final borderColor = selected ? BcTheme.primary : BcTheme.border;

    final content = Container(
      key: ValueKey<String>('activity-item-${entry.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(entry.actor),
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
                        key: ValueKey<String>('activity-actor-${entry.id}'),
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
                        key: ValueKey<String>('activity-action-${entry.id}'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(entry.timestamp),
                  key: ValueKey<String>('activity-timestamp-${entry.id}'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: BcTheme.mutedForeground,
                  ),
                ),
                if (entry.detail != null && entry.detail!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.detail!,
                    key: ValueKey<String>('activity-detail-${entry.id}'),
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: BcTheme.foreground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

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

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return Semantics(
        container: true,
        child: Center(
          child: Text(
            widget.emptyText,
            key: const ValueKey<String>('activity-empty'),
            style: const TextStyle(
              fontSize: 14,
              color: BcTheme.mutedForeground,
            ),
          ),
        ),
      );
    }

    final sorted = _sorted;
    final items = Column(
      mainAxisSize: MainAxisSize.min,
      children: sorted.map((entry) {
        final selected = _selectedId == entry.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildItem(entry, selected),
        );
      }).toList(),
    );

    // Entries size to their content, so a host that caps the height (e.g. a
    // SizedBox in a dashboard card) would clip them. Scroll when bounded;
    // shrink-wrap when the parent is already unbounded (a scroll view).
    return Semantics(
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) return items;
          return SingleChildScrollView(child: items);
        },
      ),
    );
  }
}
