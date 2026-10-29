library bc_view_gantt;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/types.dart';

const double _defaultUnitWidth = 28;
const double _defaultRowHeight = 36;
const double _headerHeight = 40;
const double _nameColumnWidth = 200;
const double _taskBarHeight = 20;
const double _milestoneSize = 14;
const double _toolbarHeight = 44;

final Map<BcGanttZoomLevel, double> _zoomUnitWidths = {
  BcGanttZoomLevel.day: _defaultUnitWidth,
  BcGanttZoomLevel.week: _defaultUnitWidth * 2,
  BcGanttZoomLevel.month: _defaultUnitWidth * 4,
  BcGanttZoomLevel.quarter: _defaultUnitWidth * 7,
};

Color _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.blue;
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return Colors.blue;
  if (cleaned.length == 6) return Color(0xFF000000 | value);
  if (cleaned.length == 8) return Color(value);
  return Colors.blue;
}

class BcViewGantt extends StatefulWidget {
  final List<BcGanttTask>? tasks;
  final List<BcGanttLink>? links;
  final String? timelineStart;
  final String? timelineEnd;
  final BcGanttZoomLevel? zoomLevel;
  final num? unitWidth;
  final num? rowHeight;
  final bool? showCriticalPath;
  final bool? showTodayLine;
  final bool? showDependencies;
  final bool? showProgress;
  final bool? showAssignees;
  final bool? allowTaskDrag;
  final bool? allowTaskResize;
  final bool? allowDependencyCreate;
  final String? model;
  final String? taskNameField;
  final String? taskStartField;
  final String? taskEndField;
  final String? taskDurationField;
  final String? taskProgressField;
  final String? taskDependencyField;
  final String? taskParentField;
  final void Function(String)? onTaskClick;
  final void Function(String, num)? onTaskMove;
  final void Function(String, num)? onTaskResize;
  final void Function(String, num)? onTaskProgressChange;
  final void Function(String, String)? onDependencyCreate;
  final void Function(BcGanttZoomLevel)? onZoomChange;

  const BcViewGantt({
    super.key,
    this.tasks,
    this.links,
    this.timelineStart,
    this.timelineEnd,
    this.zoomLevel,
    this.unitWidth,
    this.rowHeight,
    this.showCriticalPath,
    this.showTodayLine,
    this.showDependencies,
    this.showProgress,
    this.showAssignees,
    this.allowTaskDrag,
    this.allowTaskResize,
    this.allowDependencyCreate,
    this.model,
    this.taskNameField,
    this.taskStartField,
    this.taskEndField,
    this.taskDurationField,
    this.taskProgressField,
    this.taskDependencyField,
    this.taskParentField,
    this.onTaskClick,
    this.onTaskMove,
    this.onTaskResize,
    this.onTaskProgressChange,
    this.onDependencyCreate,
    this.onZoomChange,
  });

  @override
  State<BcViewGantt> createState() => BcViewGanttState();
}

class BcViewGanttState extends State<BcViewGantt> {
  late ScrollController _horizontalController;
  late ScrollController _verticalNameController;
  late ScrollController _verticalChartController;
  BcGanttZoomLevel _currentZoom = BcGanttZoomLevel.day;
  bool _criticalPathActive = false;
  final Set<String> _collapsedTasks = <String>{};

  double get scrollOffset => _horizontalController.offset;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.zoomLevel ?? BcGanttZoomLevel.day;
    _criticalPathActive = widget.showCriticalPath ?? false;
    _horizontalController = ScrollController();
    _verticalNameController = ScrollController();
    _verticalChartController = ScrollController();
    _syncVerticalScroll();
    _initCollapsed();
  }

  void _initCollapsed() {
    final tasks = widget.tasks ?? const <BcGanttTask>[];
    for (final t in tasks) {
      if (t.type == BcGanttTaskType.summary && t.collapsed == true) {
        _collapsedTasks.add(t.id);
      }
    }
  }

  void _syncVerticalScroll() {
    _verticalChartController.addListener(() {
      if (_verticalNameController.hasClients &&
          _verticalNameController.offset != _verticalChartController.offset) {
        _verticalNameController.jumpTo(_verticalChartController.offset);
      }
    });
    _verticalNameController.addListener(() {
      if (_verticalChartController.hasClients &&
          _verticalChartController.offset != _verticalNameController.offset) {
        _verticalChartController.jumpTo(_verticalNameController.offset);
      }
    });
  }

  @override
  void didUpdateWidget(BcViewGantt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zoomLevel != null && widget.zoomLevel != _currentZoom) {
      _currentZoom = widget.zoomLevel!;
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalNameController.dispose();
    _verticalChartController.dispose();
    super.dispose();
  }

  void scrollToTask(String taskId) {
    final tasks = _visibleTasks;
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) return;
    final task = tasks[index];
    final effectiveUnitWidth = widget.unitWidth?.toDouble() ??
        _zoomUnitWidths[_currentZoom] ??
        _defaultUnitWidth;
    final barCenter =
        task.start * effectiveUnitWidth + task.duration * effectiveUnitWidth / 2;
    final viewportWidth = _horizontalController.hasClients
        ? _horizontalController.position.viewportDimension
        : 800;
    final target = (barCenter - viewportWidth / 2)
        .clamp(0.0, _horizontalController.position.maxScrollExtent);
    _horizontalController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollToDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return;
    final tasks = widget.tasks ?? const <BcGanttTask>[];
    if (tasks.isEmpty) return;
    final tlStart = _timelineStart(tasks);
    final daysDiff = date.difference(tlStart).inDays.toDouble();
    final effectiveUnitWidth = widget.unitWidth?.toDouble() ??
        _zoomUnitWidths[_currentZoom] ??
        _defaultUnitWidth;
    double target;
    switch (_currentZoom) {
      case BcGanttZoomLevel.day:
        target = daysDiff * effectiveUnitWidth;
        break;
      case BcGanttZoomLevel.week:
        target = (daysDiff / 7) * effectiveUnitWidth;
        break;
      case BcGanttZoomLevel.month:
        target = (daysDiff / 30) * effectiveUnitWidth;
        break;
      case BcGanttZoomLevel.quarter:
        target = (daysDiff / 90) * effectiveUnitWidth;
        break;
    }
    final viewportWidth = _horizontalController.hasClients
        ? _horizontalController.position.viewportDimension
        : 800;
    target = (target - viewportWidth / 2).clamp(
        0.0,
        _horizontalController.hasClients
            ? _horizontalController.position.maxScrollExtent
            : 0.0);
    _horizontalController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void setZoom(BcGanttZoomLevel level) {
    setState(() => _currentZoom = level);
    widget.onZoomChange?.call(level);
  }

  void toggleTask(String taskId, [bool? collapsed]) {
    setState(() {
      final isCurrentlyCollapsed = _collapsedTasks.contains(taskId);
      final shouldBeCollapsed = collapsed ?? !isCurrentlyCollapsed;
      if (shouldBeCollapsed) {
        _collapsedTasks.add(taskId);
      } else {
        _collapsedTasks.remove(taskId);
      }
    });
  }

  List<BcGanttTask> get _visibleTasks {
    final allTasks = widget.tasks ?? const <BcGanttTask>[];
    if (_collapsedTasks.isEmpty) return allTasks;
    final hidden = <String>{};
    for (final t in allTasks) {
      if (t.parentId != null && _collapsedTasks.contains(t.parentId)) {
        hidden.add(t.id);
      }
    }
    return allTasks.where((t) => !hidden.contains(t.id)).toList();
  }

  DateTime _timelineStart(List<BcGanttTask> tasks) {
    if (widget.timelineStart != null) {
      return DateTime.tryParse(widget.timelineStart!) ?? DateTime(2026, 1, 1);
    }
    if (tasks.isEmpty) return DateTime(2026, 1, 1);
    final minStart = tasks.map((t) => t.start).reduce(math.min);
    return DateTime(2026, 1, 1).add(Duration(days: minStart.toInt()));
  }

  DateTime _timelineEnd(List<BcGanttTask> tasks) {
    if (widget.timelineEnd != null) {
      return DateTime.tryParse(widget.timelineEnd!) ?? DateTime(2026, 12, 31);
    }
    if (tasks.isEmpty) return DateTime(2026, 12, 31);
    final maxEnd = tasks.map((t) => t.start + t.duration).reduce(math.max);
    return DateTime(2026, 1, 1).add(Duration(days: maxEnd.toInt() + 10));
  }

  void _handleZoomIn() {
    final index = BcGanttZoomLevel.values.indexOf(_currentZoom);
    if (index < BcGanttZoomLevel.values.length - 1) {
      setZoom(BcGanttZoomLevel.values[index + 1]);
    }
  }

  void _handleZoomOut() {
    final index = BcGanttZoomLevel.values.indexOf(_currentZoom);
    if (index > 0) {
      setZoom(BcGanttZoomLevel.values[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks ?? const <BcGanttTask>[];
    if (tasks.isEmpty) {
      return const Center(
        key: ValueKey<String>('empty'),
        child: Text('No tasks'),
      );
    }

    final effectiveRowHeight =
        widget.rowHeight?.toDouble() ?? _defaultRowHeight;
    final visibleTasks = _visibleTasks;
    final contentHeight = visibleTasks.length * effectiveRowHeight;

    return Column(
      children: [
        _buildToolbar(),
        _buildTimelineHeader(),
        Expanded(
          child: Row(
            children: [
              _buildNameColumn(visibleTasks, effectiveRowHeight),
              _buildChartArea(
                  visibleTasks, contentHeight, effectiveRowHeight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    final zoomIndex = BcGanttZoomLevel.values.indexOf(_currentZoom);
    return Container(
      height: _toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey<String>('zoomOut'),
            icon: const Icon(Icons.remove, size: 20),
            onPressed: zoomIndex > 0 ? _handleZoomOut : null,
            tooltip: 'Zoom out',
          ),
          IconButton(
            key: const ValueKey<String>('zoomIn'),
            icon: const Icon(Icons.add, size: 20),
            onPressed: zoomIndex < BcGanttZoomLevel.values.length - 1
                ? _handleZoomIn
                : null,
            tooltip: 'Zoom in',
          ),
          const SizedBox(width: 8),
          IconButton(
            key: const ValueKey<String>('todayBtn'),
            icon: const Icon(Icons.today, size: 20),
            onPressed: () {
              final now = DateTime.now();
              scrollToDate(
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
            },
            tooltip: 'Today',
          ),
          const SizedBox(width: 8),
          IconButton(
            key: const ValueKey<String>('criticalPathToggle'),
            icon: Icon(
              Icons.warning_amber,
              size: 20,
              color: _criticalPathActive ? Colors.red : null,
            ),
            onPressed: widget.showCriticalPath == true
                ? () => setState(
                    () => _criticalPathActive = !_criticalPathActive)
                : null,
            tooltip: 'Critical path',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader() {
    final tasks = widget.tasks ?? const <BcGanttTask>[];
    final tlStart = _timelineStart(tasks);
    final tlEnd = _timelineEnd(tasks);
    final effectiveUnitWidth = widget.unitWidth?.toDouble() ??
        _zoomUnitWidths[_currentZoom] ??
        _defaultUnitWidth;

    return Row(
      children: [
        Container(
          width: _nameColumnWidth,
          height: _headerHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: const Text('Task',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        Expanded(
          child: SizedBox(
            key: const ValueKey<String>('timelineHead'),
            height: _headerHeight,
            child: CustomPaint(
              size: Size.infinite,
              painter: _GanttTimelineHeaderPainter(
                zoomLevel: _currentZoom,
                unitWidth: effectiveUnitWidth,
                timelineStart: tlStart,
                timelineEnd: tlEnd,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameColumn(List<BcGanttTask> visibleTasks, double rowHeight) {
    return SizedBox(
      width: _nameColumnWidth,
      child: Scrollbar(
        controller: _verticalNameController,
        child: SingleChildScrollView(
          controller: _verticalNameController,
          child: Column(
            children: List.generate(visibleTasks.length, (i) {
              final task = visibleTasks[i];
              return Container(
                height: rowHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Text(
                  task.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildChartArea(
      List<BcGanttTask> visibleTasks, double contentHeight, double rowHeight) {
    final tasks = widget.tasks ?? const <BcGanttTask>[];
    final tlStart = _timelineStart(tasks);
    final tlEnd = _timelineEnd(tasks);
    final effectiveUnitWidth = widget.unitWidth?.toDouble() ??
        _zoomUnitWidths[_currentZoom] ??
        _defaultUnitWidth;
    final totalUnits = tlEnd.difference(tlStart).inDays.toDouble();
    final chartWidth = totalUnits * effectiveUnitWidth;
    final effectiveShowDependencies = widget.showDependencies ?? false;
    final effectiveShowProgress = widget.showProgress ?? false;
    final effectiveShowAssignees = widget.showAssignees ?? false;
    final effectiveShowTodayLine = widget.showTodayLine ?? false;

    return Expanded(
      child: Scrollbar(
        controller: _verticalChartController,
        notificationPredicate: (notification) => notification.depth == 1,
        child: SingleChildScrollView(
          controller: _verticalChartController,
          child: SizedBox(
            height: contentHeight,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                key: const ValueKey<String>('chartArea'),
                width: chartWidth > 0 ? chartWidth : 400,
                height: contentHeight,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(chartWidth > 0 ? chartWidth : 400,
                          contentHeight),
                      painter: _GanttChartPainter(
                        tasks: visibleTasks,
                        links: effectiveShowDependencies
                            ? (widget.links ?? const <BcGanttLink>[])
                            : const <BcGanttLink>[],
                        zoomLevel: _currentZoom,
                        unitWidth: effectiveUnitWidth,
                        rowHeight: rowHeight,
                        timelineStart: tlStart,
                        timelineEnd: tlEnd,
                        showTodayLine: effectiveShowTodayLine,
                        showProgress: effectiveShowProgress,
                        showAssignees: effectiveShowAssignees,
                        showCriticalPath: _criticalPathActive,
                      ),
                    ),
                    ..._buildBarWidgets(visibleTasks, effectiveUnitWidth,
                        rowHeight),
                    if (effectiveShowDependencies)
                      ..._buildLinkWidgets(visibleTasks, effectiveUnitWidth,
                          rowHeight),
                    if (effectiveShowTodayLine)
                      _buildTodayLineWidget(
                          effectiveUnitWidth, tlStart, contentHeight),
                    if (effectiveShowProgress)
                      ..._buildProgressWidgets(
                          visibleTasks, effectiveUnitWidth, rowHeight),
                    if (effectiveShowAssignees)
                      ..._buildAssigneeWidgets(
                          visibleTasks, effectiveUnitWidth, rowHeight),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayLineWidget(
      double unitWidth, DateTime tlStart, double chartHeight) {
    final now = DateTime.now();
    final daysDiff = now.difference(tlStart).inDays;
    double x;
    switch (_currentZoom) {
      case BcGanttZoomLevel.day:
        x = daysDiff * unitWidth;
        break;
      case BcGanttZoomLevel.week:
        x = (daysDiff / 7) * unitWidth;
        break;
      case BcGanttZoomLevel.month:
        x = (daysDiff / 30) * unitWidth;
        break;
      case BcGanttZoomLevel.quarter:
        x = (daysDiff / 90) * unitWidth;
        break;
    }
    return Positioned(
      key: const ValueKey<String>('todayLine'),
      left: x,
      top: 0,
      child: Container(width: 2, height: chartHeight, color: Colors.red),
    );
  }

  List<Widget> _buildBarWidgets(
      List<BcGanttTask> tasks, double unitWidth, double rowHeight) {
    return tasks.map((task) {
      final rowIndex = tasks.indexOf(task);
      final left = task.start * unitWidth;
      final top = rowIndex * rowHeight + (rowHeight - _taskBarHeight) / 2;
      final width = task.duration * unitWidth;
      final taskType = task.type ?? BcGanttTaskType.task;

      final keyString = taskType == BcGanttTaskType.milestone
          ? 'milestone-${task.id}'
          : taskType == BcGanttTaskType.summary
              ? 'summary-${task.id}'
              : 'bar-${task.id}';

      return Positioned(
        key: ValueKey<String>(keyString),
        left: left,
        top: top,
        width: taskType == BcGanttTaskType.milestone
            ? _milestoneSize
            : math.max(width, 4),
        height: _taskBarHeight,
        child: GestureDetector(
          onTap: () => widget.onTaskClick?.call(task.id),
          child: CustomPaint(
            size: Size(
              taskType == BcGanttTaskType.milestone
                  ? _milestoneSize
                  : math.max(width, 4),
              _taskBarHeight,
            ),
            painter: _TaskBarPainter(
              taskType: taskType,
              color: _parseColor(task.color),
              width: taskType == BcGanttTaskType.milestone
                  ? _milestoneSize
                  : math.max(width, 4),
              height: _taskBarHeight,
              label: task.label,
              showAssignees: widget.showAssignees ?? false,
              assignees: task.assignees,
              criticalPath: _criticalPathActive,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildProgressWidgets(
      List<BcGanttTask> tasks, double unitWidth, double rowHeight) {
    return tasks
        .where((t) => t.progress != null && t.progress! > 0)
        .map((task) {
      final rowIndex = tasks.indexOf(task);
      final left = task.start * unitWidth;
      final top = rowIndex * rowHeight + (rowHeight - _taskBarHeight) / 2;
      final barWidth = math.max(task.duration * unitWidth, 4);
      final progressWidth =
          barWidth * (task.progress!.clamp(0, 100) / 100);

      return Positioned(
        key: ValueKey<String>('progress-${task.id}'),
        left: left,
        top: top,
        width: progressWidth,
        height: _taskBarHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(102),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildAssigneeWidgets(
      List<BcGanttTask> tasks, double unitWidth, double rowHeight) {
    final widgets = <Widget>[];
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.assignees == null || task.assignees!.isEmpty) continue;
      final left = task.start * unitWidth + 4;
      final top =
          i * rowHeight + (rowHeight - _taskBarHeight) / 2 + _taskBarHeight + 2;
      widgets.add(Positioned(
        key: ValueKey<String>('assignee-${task.id}'),
        left: left,
        top: top,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: task.assignees!
              .map((name) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      name,
                      style:
                          const TextStyle(fontSize: 9, color: Colors.black87),
                    ),
                  ))
              .toList(),
        ),
      ));
    }
    return widgets;
  }

  List<Widget> _buildLinkWidgets(
      List<BcGanttTask> tasks, double unitWidth, double rowHeight) {
    final links = widget.links ?? const <BcGanttLink>[];
    return links.map((link) {
      final fromTask = tasks.where((t) => t.id == link.from).isEmpty
          ? null
          : tasks.firstWhere((t) => t.id == link.from);
      final toTask = tasks.where((t) => t.id == link.to).isEmpty
          ? null
          : tasks.firstWhere((t) => t.id == link.to);
      if (fromTask == null || toTask == null) {
        return const SizedBox.shrink();
      }

      final fromIndex = tasks.indexOf(fromTask);
      final toIndex = tasks.indexOf(toTask);
      final fromCenter =
          _connectionPoint(fromTask, link.type ?? 'FS', unitWidth, true);
      final toCenter =
          _connectionPoint(toTask, link.type ?? 'FS', unitWidth, false);
      final fromY = fromIndex * rowHeight + rowHeight / 2;
      final toY = toIndex * rowHeight + rowHeight / 2;

      final left = math.min(fromCenter, toCenter) - 4;
      final top = math.min(fromY, toY) - 4;
      final width = (toCenter - fromCenter).abs() + 8;
      final height = (toY - fromY).abs() + 8;

      return Positioned(
        key: ValueKey<String>('link-${link.id}'),
        left: left,
        top: top,
        width: math.max(width, 8),
        height: math.max(height, 8),
        child: CustomPaint(
          size: Size(math.max(width, 8), math.max(height, 8)),
          painter: _DependencyArrowPainter(
            fromX: fromCenter - left,
            fromY: fromY - top,
            toX: toCenter - left,
            toY: toY - top,
            linkType: link.type ?? 'FS',
          ),
        ),
      );
    }).toList();
  }

  double _connectionPoint(
      BcGanttTask task, String linkType, double unitWidth, bool isFrom) {
    final barLeft = task.start * unitWidth;
    final barRight = barLeft + task.duration * unitWidth;
    switch (linkType) {
      case 'FS':
        return isFrom ? barRight : barLeft;
      case 'FF':
        return barRight;
      case 'SS':
        return barLeft;
      case 'SF':
        return isFrom ? barLeft : barRight;
      default:
        return isFrom ? barRight : barLeft;
    }
  }
}

class _GanttTimelineHeaderPainter extends CustomPainter {
  final BcGanttZoomLevel zoomLevel;
  final double unitWidth;
  final DateTime timelineStart;
  final DateTime timelineEnd;

  _GanttTimelineHeaderPainter({
    required this.zoomLevel,
    required this.unitWidth,
    required this.timelineStart,
    required this.timelineEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 0.5;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final totalDays = timelineEnd.difference(timelineStart).inDays;

    switch (zoomLevel) {
      case BcGanttZoomLevel.day:
        for (int d = 0; d <= totalDays; d++) {
          final x = d * unitWidth;
          if (x > size.width) break;
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
          if (d % 2 == 0) {
            final date = timelineStart.add(Duration(days: d));
            tp.text = TextSpan(
              text: '${date.day}',
              style: const TextStyle(color: Colors.black87, fontSize: 10),
            );
            tp.layout();
            tp.paint(canvas, Offset(x + 2, 4));
            tp.text = TextSpan(
              text: _monthAbbr(date.month),
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 9),
            );
            tp.layout();
            tp.paint(canvas, Offset(x + 2, 18));
          }
        }
        break;
      case BcGanttZoomLevel.week:
        for (int w = 0; w * 7 <= totalDays; w++) {
          final x = w * unitWidth;
          if (x > size.width) break;
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
          final weekStart = timelineStart.add(Duration(days: w * 7));
          tp.text = TextSpan(
            text: '${weekStart.month}/${weekStart.day}',
            style: const TextStyle(color: Colors.black87, fontSize: 10),
          );
          tp.layout();
          tp.paint(canvas, Offset(x + 2, 12));
        }
        break;
      case BcGanttZoomLevel.month:
        var current =
            DateTime(timelineStart.year, timelineStart.month);
        while (current.isBefore(timelineEnd)) {
          final d = current.difference(timelineStart).inDays;
          final x = (d / 30) * unitWidth;
          if (x > size.width) break;
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
          tp.text = TextSpan(
            text: '${_monthAbbr(current.month)} ${current.year}',
            style:
                const TextStyle(color: Colors.black87, fontSize: 10),
          );
          tp.layout();
          tp.paint(canvas, Offset(x + 2, 12));
          current = DateTime(current.year, current.month + 1);
        }
        break;
      case BcGanttZoomLevel.quarter:
        var qMonth = ((timelineStart.month - 1) ~/ 3) * 3 + 1;
        var current = DateTime(timelineStart.year, qMonth);
        while (current.isBefore(timelineEnd)) {
          final d = current.difference(timelineStart).inDays;
          final x = (d / 90) * unitWidth;
          if (x > size.width) break;
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
          final q = ((current.month - 1) ~/ 3) + 1;
          tp.text = TextSpan(
            text: 'Q$q ${current.year}',
            style:
                const TextStyle(color: Colors.black87, fontSize: 10),
          );
          tp.layout();
          tp.paint(canvas, Offset(x + 2, 12));
          current = DateTime(current.year, current.month + 3);
        }
        break;
    }
  }

  String _monthAbbr(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  @override
  bool shouldRepaint(_GanttTimelineHeaderPainter old) =>
      zoomLevel != old.zoomLevel || unitWidth != old.unitWidth;
}

class _GanttChartPainter extends CustomPainter {
  final List<BcGanttTask> tasks;
  final List<BcGanttLink> links;
  final BcGanttZoomLevel zoomLevel;
  final double unitWidth;
  final double rowHeight;
  final DateTime timelineStart;
  final DateTime timelineEnd;
  final bool showTodayLine;
  final bool showProgress;
  final bool showAssignees;
  final bool showCriticalPath;

  _GanttChartPainter({
    required this.tasks,
    required this.links,
    required this.zoomLevel,
    required this.unitWidth,
    required this.rowHeight,
    required this.timelineStart,
    required this.timelineEnd,
    required this.showTodayLine,
    required this.showProgress,
    required this.showAssignees,
    required this.showCriticalPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawAlternatingRows(canvas, size);
    _drawBars(canvas);
    _drawProgress(canvas);
    if (showTodayLine) _drawTodayLine(canvas, size);
    _drawLinks(canvas);
    if (showAssignees) _drawAssignees(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;
    final totalDays = timelineEnd.difference(timelineStart).inDays;
    int step;
    switch (zoomLevel) {
      case BcGanttZoomLevel.day:
        step = 1;
        break;
      case BcGanttZoomLevel.week:
        step = 7;
        break;
      case BcGanttZoomLevel.month:
        step = 30;
        break;
      case BcGanttZoomLevel.quarter:
        step = 90;
        break;
    }
    for (int d = 0; d <= totalDays; d += step) {
      final x = d * unitWidth;
      if (x > size.width) break;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawAlternatingRows(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade50;
    for (int i = 0; i < tasks.length; i++) {
      if (i % 2 == 1) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * rowHeight, size.width, rowHeight),
          paint,
        );
      }
    }
  }

  void _drawBars(Canvas canvas) {
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final left = task.start * unitWidth;
      final top = i * rowHeight + (rowHeight - _taskBarHeight) / 2;
      final width = task.duration * unitWidth;
      final color = _parseColor(task.color);
      final taskType = task.type ?? BcGanttTaskType.task;

      if (taskType == BcGanttTaskType.milestone) {
        final center =
            Offset(left + _milestoneSize / 2, top + _taskBarHeight / 2);
        final diamond = Path()
          ..moveTo(center.dx, center.dy - _milestoneSize / 2)
          ..lineTo(center.dx + _milestoneSize / 2, center.dy)
          ..lineTo(center.dx, center.dy + _milestoneSize / 2)
          ..lineTo(center.dx - _milestoneSize / 2, center.dy)
          ..close();
        canvas.drawPath(diamond, Paint()..color = color);
      } else if (taskType == BcGanttTaskType.summary) {
        final barPaint = Paint()
          ..color = color.withAlpha(179)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, math.max(width, 4), _taskBarHeight),
              const Radius.circular(4)),
          barPaint,
        );
        final bracketPaint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        final bracketY = top - 2;
        canvas.drawLine(
            Offset(left, bracketY), Offset(left, bracketY + 4), bracketPaint);
        canvas.drawLine(Offset(left, bracketY),
            Offset(left + math.max(width, 4), bracketY), bracketPaint);
        canvas.drawLine(
            Offset(left + math.max(width, 4), bracketY),
            Offset(left + math.max(width, 4), bracketY + 4),
            bracketPaint);
      } else {
        final barPaint = Paint()..color = color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, math.max(width, 4), _taskBarHeight),
              const Radius.circular(3)),
          barPaint,
        );
        if (showCriticalPath) {
          final borderPaint = Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(
                    left, top, math.max(width, 4), _taskBarHeight),
                const Radius.circular(3)),
            borderPaint,
          );
        }
      }
    }
  }

  void _drawProgress(Canvas canvas) {
    if (!showProgress) return;
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final progress = task.progress ?? 0;
      if (progress <= 0) continue;
      final left = task.start * unitWidth;
      final top = i * rowHeight + (rowHeight - _taskBarHeight) / 2;
      final barWidth = math.max(task.duration * unitWidth, 4);
      final progressWidth = barWidth * (progress.clamp(0, 100) / 100);
      final progressPaint = Paint()..color = Colors.green.withAlpha(102);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, progressWidth, _taskBarHeight),
            const Radius.circular(3)),
        progressPaint,
      );
    }
  }

  void _drawTodayLine(Canvas canvas, Size size) {
    final now = DateTime.now();
    final daysDiff = now.difference(timelineStart).inDays;
    double x;
    switch (zoomLevel) {
      case BcGanttZoomLevel.day:
        x = daysDiff * unitWidth;
        break;
      case BcGanttZoomLevel.week:
        x = (daysDiff / 7) * unitWidth;
        break;
      case BcGanttZoomLevel.month:
        x = (daysDiff / 30) * unitWidth;
        break;
      case BcGanttZoomLevel.quarter:
        x = (daysDiff / 90) * unitWidth;
        break;
    }
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }

  void _drawLinks(Canvas canvas) {
    for (final link in links) {
      final fromIdx = tasks.indexWhere((t) => t.id == link.from);
      final toIdx = tasks.indexWhere((t) => t.id == link.to);
      if (fromIdx < 0 || toIdx < 0) continue;

      final fromTask = tasks[fromIdx];
      final toTask = tasks[toIdx];
      final linkType = link.type ?? 'FS';

      final fromX = _connX(fromTask, linkType, true);
      final fromY = fromIdx * rowHeight + rowHeight / 2;
      final toX = _connX(toTask, linkType, false);
      final toY = toIdx * rowHeight + rowHeight / 2;

      final paint = Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final midX = (fromX + toX) / 2;
      final path = Path()
        ..moveTo(fromX, fromY)
        ..lineTo(midX, fromY)
        ..lineTo(midX, toY)
        ..lineTo(toX, toY);
      canvas.drawPath(path, paint);

      const arrowSize = 6.0;
      final arrowPath = Path()
        ..moveTo(toX, toY)
        ..lineTo(toX - arrowSize, toY - arrowSize / 2)
        ..lineTo(toX - arrowSize, toY + arrowSize / 2)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = Colors.blueGrey);
    }
  }

  double _connX(BcGanttTask task, String linkType, bool isFrom) {
    final barLeft = task.start * unitWidth;
    final barRight = barLeft + task.duration * unitWidth;
    switch (linkType) {
      case 'FS':
        return isFrom ? barRight : barLeft;
      case 'FF':
        return barRight;
      case 'SS':
        return barLeft;
      case 'SF':
        return isFrom ? barLeft : barRight;
      default:
        return isFrom ? barRight : barLeft;
    }
  }

  void _drawAssignees(Canvas canvas) {
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.assignees == null || task.assignees!.isEmpty) continue;
      final left = task.start * unitWidth + 4;
      final top = i * rowHeight +
          (rowHeight - _taskBarHeight) / 2 +
          _taskBarHeight +
          2;
      final tp = TextPainter(
        text: TextSpan(
          text: task.assignees!.join(', '),
          style: const TextStyle(color: Colors.black87, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(left, top));
    }
  }

  @override
  bool shouldRepaint(_GanttChartPainter old) => true;
}

class _TaskBarPainter extends CustomPainter {
  final BcGanttTaskType taskType;
  final Color color;
  final double width;
  final double height;
  final String label;
  final bool showAssignees;
  final List<String>? assignees;
  final bool criticalPath;

  _TaskBarPainter({
    required this.taskType,
    required this.color,
    required this.width,
    required this.height,
    required this.label,
    required this.showAssignees,
    this.assignees,
    required this.criticalPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (taskType) {
      case BcGanttTaskType.milestone:
        final center = Offset(size.width / 2, size.height / 2);
        final diamond = Path()
          ..moveTo(center.dx, center.dy - _milestoneSize / 2)
          ..lineTo(center.dx + _milestoneSize / 2, center.dy)
          ..lineTo(center.dx, center.dy + _milestoneSize / 2)
          ..lineTo(center.dx - _milestoneSize / 2, center.dy)
          ..close();
        canvas.drawPath(diamond, Paint()..color = color);
        break;
      case BcGanttTaskType.summary:
        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(4));
        canvas.drawRRect(rect, Paint()..color = color.withAlpha(179));
        final bracketPaint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(0, -2), const Offset(0, 2), bracketPaint);
        canvas.drawLine(
            const Offset(0, -2), Offset(size.width, -2), bracketPaint);
        canvas.drawLine(
            Offset(size.width, -2), Offset(size.width, 2), bracketPaint);
        break;
      case BcGanttTaskType.task:
        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(3));
        canvas.drawRRect(rect, Paint()..color = color);
        if (criticalPath) {
          canvas.drawRRect(
            rect,
            Paint()
              ..color = Colors.red
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(_TaskBarPainter old) =>
      taskType != old.taskType ||
      color != old.color ||
      width != old.width ||
      criticalPath != old.criticalPath;
}

class _DependencyArrowPainter extends CustomPainter {
  final double fromX;
  final double fromY;
  final double toX;
  final double toY;
  final String linkType;

  _DependencyArrowPainter({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.linkType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final midX = (fromX + toX) / 2;
    final path = Path()
      ..moveTo(fromX, fromY)
      ..lineTo(midX, fromY)
      ..lineTo(midX, toY)
      ..lineTo(toX, toY);
    canvas.drawPath(path, paint);

    const arrowSize = 6.0;
    final arrowPath = Path()
      ..moveTo(toX, toY)
      ..lineTo(toX - arrowSize, toY - arrowSize / 2)
      ..lineTo(toX - arrowSize, toY + arrowSize / 2)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = Colors.blueGrey);
  }

  @override
  bool shouldRepaint(_DependencyArrowPainter old) =>
      fromX != old.fromX ||
      fromY != old.fromY ||
      toX != old.toX ||
      toY != old.toY;
}
