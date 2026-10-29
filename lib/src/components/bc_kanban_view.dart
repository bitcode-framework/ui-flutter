library bc_kanban_view;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A kanban column.
class BcKanbanViewColumn {
  final String id;
  final String title;
  final Color? color;

  const BcKanbanViewColumn({
    required this.id,
    required this.title,
    this.color,
  });
}

/// A kanban card.
class BcKanbanViewCard {
  final String id;
  final String title;
  final String columnId;
  final String? description;
  final String? priority;
  final List<String>? labels;

  const BcKanbanViewCard({
    required this.id,
    required this.title,
    required this.columnId,
    this.description,
    this.priority,
    this.labels,
  });
}

/// Kanban board with drag-drop between columns (ADR-006 Adapt).
///
/// Flutter uses long-press + drag via Draggable/DragTarget. Tap card to select.
class BcKanbanView extends StatefulWidget {
  final List<BcKanbanViewColumn> columns;
  final List<BcKanbanViewCard> cards;
  final void Function(String cardId, String fromColumn, String toColumn, BcChangeMeta meta)? onCardMove;
  final void Function(BcKanbanViewCard card)? onCardClick;

  const BcKanbanView({
    super.key,
    required this.columns,
    required this.cards,
    this.onCardMove,
    this.onCardClick,
  });

  @override
  State<BcKanbanView> createState() => _BcKanbanViewState();
}

class _BcKanbanViewState extends State<BcKanbanView> {
  late List<BcKanbanViewCard> _cards;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards);
  }

  @override
  void didUpdateWidget(covariant BcKanbanView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards != widget.cards) {
      _cards = List.from(widget.cards);
    }
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'low': return BcTheme.success;
      case 'medium': return BcTheme.warning;
      case 'high': return BcTheme.destructive;
      case 'urgent': return BcTheme.destructive;
      default: return BcTheme.border;
    }
  }

  List<BcKanbanViewCard> _cardsForColumn(String columnId) {
    return _cards.where((c) => c.columnId == columnId).toList();
  }

  void _handleCardMove(BcKanbanViewCard card, String toColumnId) {
    if (card.columnId == toColumnId) return;
    setState(() {
      final idx = _cards.indexWhere((c) => c.id == card.id);
      if (idx >= 0) {
        _cards[idx] = BcKanbanViewCard(
          id: card.id,
          title: card.title,
          columnId: toColumnId,
          description: card.description,
          priority: card.priority,
          labels: card.labels,
        );
      }
    });
    widget.onCardMove?.call(
      card.id,
      card.columnId,
      toColumnId,
      const BcChangeMeta(reason: BcChangeReason.valueChange, source: BcEventSource.pointer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: bcI18n.t('bc.kanbanView.ariaLabel'),
      child: SingleChildScrollView(
        key: const Key('bc-kanban-view'),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.columns.map((col) {
            final colCards = _cardsForColumn(col.id);
            return _buildColumn(col, colCards);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColumn(BcKanbanViewColumn col, List<BcKanbanViewCard> colCards) {
    return DragTarget<BcKanbanViewCard>(
      key: Key('bc-kanban-view-column-${col.id}'),
      onAcceptWithDetails: (details) => _handleCardMove(details.data, col.id),
      builder: (context, candidateData, rejectedData) {
        final isTarget = candidateData.isNotEmpty;
        return Container(
          width: 260,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BcTheme.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTarget ? BcTheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (col.color != null)
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: col.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      col.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: BcTheme.foreground,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: BcTheme.mutedForeground.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${colCards.length}',
                      key: Key('bc-kanban-view-count-${col.id}'),
                      style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (colCards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No cards',
                      style: TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                    ),
                  ),
                )
              else
                ...colCards.map((card) => _buildCard(card)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BcKanbanViewCard card) {
    return Draggable<BcKanbanViewCard>(
      key: Key('bc-kanban-view-card-${card.id}'),
      data: card,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 230,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BcTheme.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(card.title),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _cardContent(card),
      ),
      child: GestureDetector(
        onTap: () => widget.onCardClick?.call(card),
        child: _cardContent(card),
      ),
    );
  }

  Widget _cardContent(BcKanbanViewCard card) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BcTheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: _priorityColor(card.priority), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: BcTheme.foreground.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: BcTheme.foreground),
          ),
          if (card.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                card.description!,
                style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
              ),
            ),
          if (card.labels != null && card.labels!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 4,
                children: card.labels!.map((label) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: BcTheme.muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
