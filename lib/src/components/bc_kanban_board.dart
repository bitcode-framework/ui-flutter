library bc_kanban_board;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Enterprise Kanban board with cross-column drag-drop, within-column
/// reorder, and disabled/readonly modes
/// (ADR-011 Phase 5c — M5 data display).
///
/// Columns and cards are provided via props. Dragging a card from one
/// column to another (or within the same column) fires [onCardMove] with
/// a [BcKanbanCardMoveEvent] and a [BcChangeMeta].
///
/// When [disabled] or [readOnly] is true, cards cannot be dragged.
class BcKanbanBoard extends StatefulWidget {
  final List<BcKanbanColumnConfig> columns;
  final List<BcKanbanCard> cards;
  final String boardTitle;
  final bool disabled;
  final bool readOnly;
  final bool searchable;
  final BcChangeHandler<BcKanbanCardMoveEvent>? onCardMove;
  final void Function(BcKanbanCard card)? onCardTap;
  final bool allowAddCard;
  final void Function(String columnId, String title)? onCardCreate;

  const BcKanbanBoard({
    super.key,
    required this.columns,
    required this.cards,
    this.boardTitle = '',
    this.disabled = false,
    this.readOnly = false,
    this.searchable = false,
    this.onCardMove,
    this.onCardTap,
    this.allowAddCard = false,
    this.onCardCreate,
  });

  @override
  State<BcKanbanBoard> createState() => _BcKanbanBoardState();
}

class _BcKanbanBoardState extends State<BcKanbanBoard> {
  late List<BcKanbanCard> _cards;
  String? _draggingCardId;
  String? _dragOverColumnId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards);
  }

  @override
  void didUpdateWidget(BcKanbanBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(widget.cards, oldWidget.cards)) {
      _cards = List.from(widget.cards);
    }
  }

  bool get _isDragDisabled => widget.disabled || widget.readOnly;

  List<BcKanbanCard> _cardsForColumn(String columnId) {
    final filtered = _cards.where((c) => c.column == columnId).toList();
    filtered.sort((a, b) {
      final pa = a.position ?? 0;
      final pb = b.position ?? 0;
      if (pa != pb) return pa.compareTo(pb);
      return _cards.indexOf(a).compareTo(_cards.indexOf(b));
    });
    if (_searchQuery.isNotEmpty) {
      return filtered
          .where((c) =>
              c.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  void _onCardDragStart(String cardId) {
    if (_isDragDisabled) return;
    setState(() {
      _draggingCardId = cardId;
    });
  }

  void _onDrop(String targetColumnId, int? targetIndex) {
    if (_isDragDisabled || _draggingCardId == null) return;

    final cardIdx = _cards.indexWhere((c) => c.id == _draggingCardId);
    if (cardIdx == -1) return;

    final card = _cards[cardIdx];
    final fromColumn = card.column;

    final targetCards = _cardsForColumn(targetColumnId);
    final newIndex = targetIndex ?? targetCards.length;

    final updated = List<BcKanbanCard>.from(_cards);
    updated[cardIdx] = BcKanbanCard(
      id: card.id,
      title: card.title,
      description: card.description,
      column: targetColumnId,
      position: newIndex,
      priority: card.priority,
      dueDate: card.dueDate,
      labels: card.labels,
    );

    if (fromColumn != targetColumnId) {
      _reindexColumn(updated, fromColumn);
    }
    _reindexColumn(updated, targetColumnId);

    final event = BcKanbanCardMoveEvent(
      cardId: card.id,
      fromColumn: fromColumn,
      toColumn: targetColumnId,
      toPosition: newIndex,
    );

    setState(() {
      _cards = updated;
      _draggingCardId = null;
      _dragOverColumnId = null;
    });

    widget.onCardMove?.call(
      event,
      const BcChangeMeta(
        reason: BcChangeReason.valueChange,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _reindexColumn(List<BcKanbanCard> cards, String columnId) {
    final colCards = cards.where((c) => c.column == columnId).toList();
    colCards.sort((a, b) {
      final pa = a.position ?? 0;
      final pb = b.position ?? 0;
      return pa.compareTo(pb);
    });
    for (var i = 0; i < colCards.length; i++) {
      final idx = cards.indexWhere((c) => c.id == colCards[i].id);
      if (idx != -1) {
        final c = cards[idx];
        cards[idx] = BcKanbanCard(
          id: c.id,
          title: c.title,
          description: c.description,
          column: c.column,
          position: i,
          priority: c.priority,
          dueDate: c.dueDate,
          labels: c.labels,
        );
      }
    }
  }

  void moveCard(String cardId, String toColumn, int toIndex) {
    if (_isDragDisabled) return;

    final cardIdx = _cards.indexWhere((c) => c.id == cardId);
    if (cardIdx == -1) return;

    final card = _cards[cardIdx];
    final fromColumn = card.column;

    final updated = List<BcKanbanCard>.from(_cards);
    updated[cardIdx] = BcKanbanCard(
      id: card.id,
      title: card.title,
      description: card.description,
      column: toColumn,
      position: toIndex,
      priority: card.priority,
      dueDate: card.dueDate,
      labels: card.labels,
    );

    if (fromColumn != toColumn) {
      _reindexColumn(updated, fromColumn);
    }
    _reindexColumn(updated, toColumn);

    final event = BcKanbanCardMoveEvent(
      cardId: card.id,
      fromColumn: fromColumn,
      toColumn: toColumn,
      toPosition: toIndex,
    );

    setState(() {
      _cards = updated;
    });

    widget.onCardMove?.call(
      event,
      const BcChangeMeta(
        reason: BcChangeReason.valueChange,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bc_kanban_board'),
      color: BcTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.boardTitle.isNotEmpty || widget.searchable)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (widget.boardTitle.isNotEmpty)
                    Expanded(
                      child: Text(
                        widget.boardTitle,
                        key: const Key('bc_kanban_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: BcTheme.foreground,
                        ),
                      ),
                    ),
                  if (widget.searchable)
                    SizedBox(
                      width: 200,
                      child: PlatformWidget(
                        material: (ctx, _) => TextField(
                          key: const Key('bc_kanban_search'),
                          decoration: const InputDecoration(
                            hintText: 'Search cards...',
                            isDense: true,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search, size: 18),
                          ),
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                        ),
                        cupertino: (ctx, _) => const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: widget.columns.isEmpty
                ? const Center(child: Text('No columns'))
                : _buildColumns(context),
          ),
        ],
      ),
    );
  }

  Widget _buildColumns(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.columns.map((col) {
          return _buildColumn(context, col);
        }).toList(),
      ),
    );
  }

  Widget _buildColumn(
    BuildContext context,
    BcKanbanColumnConfig column,
  ) {
    final colCards = _cardsForColumn(column.id);
    final isDragTarget =
        _dragOverColumnId == column.id && _draggingCardId != null;

    final columnColor = column.color ?? BcTheme.primary;

    return Container(
      key: Key('bc_kanban_column_${column.id}'),
      width: 260,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (_) => !_isDragDisabled,
        onAcceptWithDetails: (details) {
          final data = details.data;
          final cardId = data['cardId'] as String?;
          if (cardId != null) {
            _onDrop(column.id, null);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              color: BcTheme.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(BcTheme.radius),
              border: isDragTarget
                  ? Border.all(color: columnColor, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColumnHeader(column, colCards.length),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...colCards.asMap().entries.map((entry) {
                          return _buildCardDragTarget(
                            column.id,
                            entry.key,
                            child: _buildCard(context, entry.value),
                          );
                        }),
                        if (colCards.isEmpty)
                          _buildEmptyDropZone(column.id),
                        if (widget.allowAddCard && !_isDragDisabled)
                          _buildAddCardButton(column.id),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumnHeader(BcKanbanColumnConfig column, int cardCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: BcTheme.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: column.color ?? BcTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              column.name,
              key: Key('bc_kanban_col_name_${column.id}'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BcTheme.foreground,
              ),
            ),
          ),
          Container(
            key: Key('bc_kanban_col_count_${column.id}'),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: BcTheme.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$cardCount',
              style: const TextStyle(
                fontSize: 11,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, BcKanbanCard card) {
    final isDragging = _draggingCardId == card.id;

    final cardWidget = GestureDetector(
      key: Key('bc_kanban_card_${card.id}'),
      onTap: () => widget.onCardTap?.call(card),
      child: Opacity(
        opacity: isDragging ? 0.4 : 1.0,
        child: _buildCardContent(card),
      ),
    );

    if (_isDragDisabled) {
      return cardWidget;
    }

    return LongPressDraggable<Map<String, dynamic>>(
      data: {'cardId': card.id, 'columnId': card.column},
      delay: const Duration(milliseconds: 200),
      onDragStarted: () => _onCardDragStart(card.id),
      onDragEnd: (_) {
        setState(() {
          _draggingCardId = null;
          _dragOverColumnId = null;
        });
      },
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        child: Container(
          width: 230,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BcTheme.background,
            borderRadius: BorderRadius.circular(BcTheme.radius),
            border: Border.all(color: BcTheme.border),
          ),
          child: Text(
            card.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildCardContent(card),
      ),
      child: cardWidget,
    );
  }

  Widget _buildCardContent(BcKanbanCard card) {
    final priorityColor = _priorityColor(card.priority);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BcTheme.card,
        borderRadius: BorderRadius.circular(BcTheme.radius),
        border: Border.all(color: BcTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.priority != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    card.priority!.name.toUpperCase(),
                    key: Key('bc_kanban_card_priority_${card.id}'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            card.title,
            key: Key('bc_kanban_card_title_${card.id}'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: BcTheme.foreground,
            ),
          ),
          if (card.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                card.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: BcTheme.mutedForeground,
                ),
              ),
            ),
          if (card.labels != null && card.labels!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: card.labels!.map((label) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: BcTheme.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: BcTheme.info,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardDragTarget(
    String columnId,
    int index, {
    required Widget child,
  }) {
    if (_isDragDisabled) return child;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (_) => !_isDragDisabled,
      onAcceptWithDetails: (details) {
        final cardId = details.data['cardId'] as String?;
        if (cardId != null) {
          moveCard(cardId, columnId, index);
        }
      },
      builder: (context, candidate, rejected) {
        final isTarget = candidate.isNotEmpty;
        return Container(
          decoration: isTarget
              ? BoxDecoration(
                  border: Border.all(color: BcTheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(BcTheme.radius),
                )
              : null,
          child: child,
        );
      },
    );
  }

  Widget _buildEmptyDropZone(String columnId) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (_) => !_isDragDisabled,
      onAcceptWithDetails: (details) {
        final cardId = details.data['cardId'] as String?;
        if (cardId != null) {
          moveCard(cardId, columnId, 0);
        }
      },
      builder: (context, candidate, rejected) {
        return Container(
          key: Key('bc_kanban_empty_$columnId'),
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: candidate.isNotEmpty
                  ? BcTheme.primary
                  : BcTheme.border.withValues(alpha: 0.5),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(BcTheme.radius),
          ),
          child: const Center(
            child: Text(
              'Drop here',
              style: TextStyle(
                fontSize: 11,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddCardButton(String columnId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextButton.icon(
        key: Key('bc_kanban_add_card_$columnId'),
        onPressed: () => _showAddCardDialog(columnId),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add card', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  void _showAddCardDialog(String columnId) {
    final controller = TextEditingController();
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('New Card'),
        content: PlatformWidget(
          material: (ctx, _) => TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'Card title...'),
          ),
          cupertino: (ctx, _) => const SizedBox.shrink(),
        ),
        actions: [
          PlatformDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          PlatformDialogAction(
            child: const Text('Add'),
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                widget.onCardCreate?.call(columnId, title);
                setState(() {
                  final maxPos = _cardsForColumn(columnId).fold<int>(0,
                      (max, c) => math.max(max, (c.position ?? 0) + 1));
                  _cards.add(BcKanbanCard(
                    id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    column: columnId,
                    position: maxPos,
                  ));
                });
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Color _priorityColor(BcKanbanPriority? priority) {
    switch (priority) {
      case BcKanbanPriority.critical:
        return BcTheme.destructive;
      case BcKanbanPriority.high:
        return BcTheme.warning;
      case BcKanbanPriority.medium:
        return BcTheme.info;
      case BcKanbanPriority.low:
        return BcTheme.success;
      case null:
        return BcTheme.mutedForeground;
    }
  }

  bool _listEquals(List<BcKanbanCard> a, List<BcKanbanCard> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
