library bc_calendar_view;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Calendar view modes.
enum BcCalendarViewMode { month, week, day }

/// A calendar event.
class BcCalendarViewEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final Color? color;

  const BcCalendarViewEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.color,
  });
}

/// Month/week/day calendar views with event overlay (ADR-006 Adapt).
///
/// Flutter implementation: month grid with event badges + prev/next nav.
/// Tap day to select.
class BcCalendarView extends StatefulWidget {
  final BcCalendarViewMode view;
  final DateTime? date;
  final List<BcCalendarViewEvent> events;
  final void Function(DateTime date, BcChangeMeta meta)? onDateSelect;
  final void Function(BcCalendarViewEvent event)? onEventClick;
  final void Function(BcCalendarViewMode view, BcChangeMeta meta)? onViewChange;

  const BcCalendarView({
    super.key,
    this.view = BcCalendarViewMode.month,
    this.date,
    this.events = const [],
    this.onDateSelect,
    this.onEventClick,
    this.onViewChange,
  });

  @override
  State<BcCalendarView> createState() => _BcCalendarViewState();
}

class _BcCalendarViewState extends State<BcCalendarView> {
  late BcCalendarViewMode _view;
  late DateTime _centerDate;

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _view = widget.view;
    _centerDate = widget.date ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant BcCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.view != oldWidget.view) _view = widget.view;
    if (widget.date != oldWidget.date && widget.date != null) {
      _centerDate = widget.date!;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<BcCalendarViewEvent> _eventsOnDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    return widget.events.where((e) {
      return !e.start.isAfter(dayEnd) && !e.end.isBefore(dayStart);
    }).toList();
  }

  void _navigate(String direction) {
    setState(() {
      final d = _centerDate;
      if (direction == 'today') {
        _centerDate = DateTime.now();
      } else {
        final delta = direction == 'next' ? 1 : -1;
        if (_view == BcCalendarViewMode.month) {
          _centerDate = DateTime(d.year, d.month + delta, d.day);
        } else if (_view == BcCalendarViewMode.week) {
          _centerDate = d.add(Duration(days: delta * 7));
        } else {
          _centerDate = d.add(Duration(days: delta));
        }
      }
    });
  }

  void _changeView(BcCalendarViewMode newView) {
    setState(() => _view = newView);
    widget.onViewChange?.call(
      newView,
      const BcChangeMeta(reason: BcChangeReason.typeChange, source: BcEventSource.pointer),
    );
  }

  String get _headerLabel {
    switch (_view) {
      case BcCalendarViewMode.month:
        return '${_months[_centerDate.month - 1]} ${_centerDate.year}';
      case BcCalendarViewMode.week:
        return 'Week of ${_months[_centerDate.month - 1]} ${_centerDate.day}';
      case BcCalendarViewMode.day:
        return '${_months[_centerDate.month - 1]} ${_centerDate.day}, ${_centerDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: bcI18n.t('bc.calendarView.ariaLabel'),
      child: Column(
        key: const Key('bc-calendar-view'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Flexible(child: SingleChildScrollView(child: _buildBody())),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // The label and the control cluster can both be wide (three nav buttons
    // plus the view-mode switcher). A rigid Row overflows as soon as the host
    // is narrower than their combined natural width, so the label is allowed
    // to ellipsize and the controls are allowed to wrap.
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        final controls = Wrap(
          key: const Key('bc-calendar-view-nav'),
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _navButton('‹', () => _navigate('prev'), 'Previous'),
            _navButton('Today', () => _navigate('today'), null),
            _navButton('›', () => _navigate('next'), 'Next'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: BcTheme.border),
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: BcCalendarViewMode.values.map((v) {
                  final isActive = _view == v;
                  return GestureDetector(
                    onTap: () => _changeView(v),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      color: isActive ? BcTheme.primary : BcTheme.card,
                      child: Text(
                        v.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isActive
                              ? BcTheme.primaryForeground
                              : BcTheme.foreground,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );

        final label = Text(
          _headerLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: BcTheme.foreground,
          ),
        );

        if (compact) {
          // Stack label above controls so neither has to shrink to nothing.
          return Column(
            key: const Key('bc-calendar-view-header'),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              label,
              const SizedBox(height: 8),
              controls,
            ],
          );
        }

        return Row(
          key: const Key('bc-calendar-view-header'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: label),
            const SizedBox(width: 8),
            Flexible(child: controls),
          ],
        );
      },
    );
  }

  Widget _navButton(String label, VoidCallback onTap, String? tooltip) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      margin: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: BcTheme.foreground,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: BcTheme.border),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildBody() {
    switch (_view) {
      case BcCalendarViewMode.month:
        return _buildMonthGrid();
      case BcCalendarViewMode.week:
        return _buildWeekGrid();
      case BcCalendarViewMode.day:
        return _buildDayView();
    }
  }

  Widget _buildMonthGrid() {
    final monthStart = DateTime(_centerDate.year, _centerDate.month, 1);
    final startWeekday = monthStart.weekday % 7;
    final gridStart = monthStart.subtract(Duration(days: startWeekday));
    final today = DateTime.now();

    final cells = List.generate(42, (i) {
      return gridStart.add(Duration(days: i));
    });

    return Container(
      key: const Key('bc-calendar-view-month'),
      decoration: BoxDecoration(
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: _weekdays.map((wd) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: BcTheme.muted,
                  child: Center(
                    child: Text(
                      wd,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: BcTheme.mutedForeground),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          ...List.generate(6, (row) {
            return Row(
              children: cells.skip(row * 7).take(7).map((day) {
                final inMonth = day.month == _centerDate.month;
                final isToday = _isSameDay(day, today);
                final dayEvents = _eventsOnDay(day);
                return Expanded(
                  child: GestureDetector(
                    key: Key('bc-calendar-view-cell-${day.toIso8601String().substring(0, 10)}'),
                    onTap: () => widget.onDateSelect?.call(
                      day,
                      const BcChangeMeta(reason: BcChangeReason.select, source: BcEventSource.pointer),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isToday ? BcTheme.primary.withValues(alpha: 0.05) : BcTheme.card,
                        border: Border(
                          right: BorderSide(color: BcTheme.border, width: 0.5),
                          bottom: BorderSide(color: BcTheme.border, width: 0.5),
                        ),
                      ),
                      child: Opacity(
                        opacity: inMonth ? 1.0 : 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isToday ? BcTheme.primary : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isToday ? BcTheme.primaryForeground : BcTheme.foreground,
                                  ),
                                ),
                              ),
                            ),
                            ...dayEvents.take(3).map((ev) {
                              return GestureDetector(
                                key: Key('bc-calendar-view-event-${ev.id}'),
                                onTap: () => widget.onEventClick?.call(ev),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: (ev.color ?? BcTheme.primary).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    ev.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ev.color ?? BcTheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            if (dayEvents.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '+${dayEvents.length - 3} more',
                                  style: const TextStyle(fontSize: 11, color: BcTheme.mutedForeground),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekGrid() {
    final today = DateTime.now();
    final weekStart = _centerDate.subtract(Duration(days: _centerDate.weekday % 7));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Container(
      key: const Key('bc-calendar-view-week'),
      decoration: BoxDecoration(
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: days.map((day) {
          final isToday = _isSameDay(day, today);
          final dayEvents = _eventsOnDay(day);
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onDateSelect?.call(
                day,
                const BcChangeMeta(reason: BcChangeReason.select, source: BcEventSource.pointer),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 120),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: BcTheme.border, width: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weekdays[day.weekday % 7],
                      style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isToday ? BcTheme.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isToday ? BcTheme.primaryForeground : BcTheme.foreground,
                          ),
                        ),
                      ),
                    ),
                    ...dayEvents.map((ev) {
                      return GestureDetector(
                        key: Key('bc-calendar-view-event-${ev.id}'),
                        onTap: () => widget.onEventClick?.call(ev),
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: (ev.color ?? BcTheme.primary).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            ev.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: ev.color ?? BcTheme.primary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayView() {
    final dayEvents = _eventsOnDay(_centerDate)
      ..sort((a, b) => a.start.compareTo(b.start));

    return Container(
      key: const Key('bc-calendar-view-day'),
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: BcTheme.muted,
            child: Text(
              '${_weekdays[_centerDate.weekday % 7]}, ${_months[_centerDate.month - 1]} ${_centerDate.day}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: BcTheme.foreground),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, hour) {
                final hourEvents = dayEvents.where((e) => e.start.hour == hour).toList();
                return Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: BcTheme.border, width: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          hour == 0 ? '12 AM'
                            : hour < 12 ? '$hour AM'
                            : hour == 12 ? '12 PM'
                            : '${hour - 12} PM',
                          style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: hourEvents.map((ev) {
                            return GestureDetector(
                              key: Key('bc-calendar-view-event-${ev.id}'),
                              onTap: () => widget.onEventClick?.call(ev),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (ev.color ?? BcTheme.primary).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ev.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ev.color ?? BcTheme.primary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
