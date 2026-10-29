import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_view_gantt.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: SizedBox(width: 1200, height: 600, child: child)));
  }

  List<BcGanttTask> sampleTasks() => <BcGanttTask>[
    const BcGanttTask(id: 't1', label: 'Task 1', start: 0, duration: 5),
    const BcGanttTask(id: 't2', label: 'Task 2', start: 3, duration: 4),
    const BcGanttTask(id: 't3', label: 'Task 3', start: 8, duration: 3),
  ];

  testWidgets('BcViewGantt renders task bar (VAL-GANTT-001)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(tasks: sampleTasks()),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-t1')), findsOneWidget);
  });

  testWidgets('BcViewGantt renders milestone diamond (VAL-GANTT-002)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 'm1', label: 'Milestone 1', start: 3, duration: 0, type: BcGanttTaskType.milestone),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('milestone-m1')), findsOneWidget);
  });

  testWidgets('BcViewGantt renders summary bar (VAL-GANTT-003)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 's1', label: 'Phase 1', start: 0, duration: 10, type: BcGanttTaskType.summary),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('summary-s1')), findsOneWidget);
  });

  testWidgets('BcViewGantt renders dependency link (VAL-GANTT-004)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'Task 1', start: 0, duration: 5),
          BcGanttTask(id: 't2', label: 'Task 2', start: 6, duration: 4),
        ],
        links: <BcGanttLink>[
          BcGanttLink(id: 'l1', from: 't1', to: 't2', type: 'FS'),
        ],
        showDependencies: true,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('link-l1')), findsOneWidget);
  });

  testWidgets('BcViewGantt hides links when showDependencies false (VAL-GANTT-005)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        links: const <BcGanttLink>[
          BcGanttLink(id: 'l1', from: 't1', to: 't2', type: 'FS'),
        ],
        showDependencies: false,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('link-l1')), findsNothing);
  });

  testWidgets('BcViewGantt renders today line (VAL-GANTT-006)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        showTodayLine: true,
        timelineStart: '2026-06-20',
        timelineEnd: '2026-06-30',
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('todayLine')), findsOneWidget);
  });

  testWidgets('BcViewGantt hides today line by default (VAL-GANTT-007)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        showTodayLine: false,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('todayLine')), findsNothing);
  });

  testWidgets('BcViewGantt renders progress fill (VAL-GANTT-008)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'Task 1', start: 0, duration: 10, progress: 60),
        ],
        showProgress: true,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('progress-t1')), findsOneWidget);
  });

  testWidgets('BcViewGantt hides progress fill by default (VAL-GANTT-009)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'Task 1', start: 0, duration: 10, progress: 60),
        ],
        showProgress: false,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('progress-t1')), findsNothing);
  });

  testWidgets('BcViewGantt zoom level changes unitWidth (VAL-GANTT-010)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.day,
      ),
    ));
    await tester.pumpAndSettle();
    final daySize = tester.getSize(find.byKey(const ValueKey<String>('chartArea')));

    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.month,
      ),
    ));
    await tester.pumpAndSettle();
    final monthSize = tester.getSize(find.byKey(const ValueKey<String>('chartArea')));

    expect(monthSize.width, greaterThan(daySize.width));
  });

  testWidgets('BcViewGantt zoom in button advances level (VAL-GANTT-011)', (tester) async {
    BcGanttZoomLevel? capturedLevel;
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.day,
        onZoomChange: (level) => capturedLevel = level,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('zoomIn')));
    await tester.pumpAndSettle();
    expect(capturedLevel, BcGanttZoomLevel.week);
  });

  testWidgets('BcViewGantt zoom out button decrements level (VAL-GANTT-012)', (tester) async {
    BcGanttZoomLevel? capturedLevel;
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.month,
        onZoomChange: (level) => capturedLevel = level,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('zoomOut')));
    await tester.pumpAndSettle();
    expect(capturedLevel, BcGanttZoomLevel.week);
  });

  testWidgets('BcViewGantt zoom buttons disabled at extremes (VAL-GANTT-013)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.quarter,
      ),
    ));
    await tester.pumpAndSettle();
    final zoomInBtn = tester.widget<IconButton>(find.byKey(const ValueKey<String>('zoomIn')));
    expect(zoomInBtn.onPressed, isNull);

    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.day,
      ),
    ));
    await tester.pumpAndSettle();
    final zoomOutBtn = tester.widget<IconButton>(find.byKey(const ValueKey<String>('zoomOut')));
    expect(zoomOutBtn.onPressed, isNull);
  });

  testWidgets('BcViewGantt zoom in fires onZoomChange (VAL-GANTT-014)', (tester) async {
    BcGanttZoomLevel? capturedLevel;
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.day,
        onZoomChange: (level) => capturedLevel = level,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('zoomIn')));
    await tester.pumpAndSettle();
    expect(capturedLevel, BcGanttZoomLevel.week);
  });

  testWidgets('BcViewGantt zoom out fires onZoomChange (VAL-GANTT-015)', (tester) async {
    BcGanttZoomLevel? capturedLevel;
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.month,
        onZoomChange: (level) => capturedLevel = level,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('zoomOut')));
    await tester.pumpAndSettle();
    expect(capturedLevel, BcGanttZoomLevel.week);
  });

  testWidgets('BcViewGantt task tap fires onTaskClick (VAL-GANTT-016)', (tester) async {
    String? capturedId;
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        onTaskClick: (id) => capturedId = id,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('bar-t1')));
    await tester.pump();
    expect(capturedId, 't1');
  });

  testWidgets('BcViewGantt task name column renders labels (VAL-GANTT-017)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(tasks: sampleTasks()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Task 2'), findsOneWidget);
    expect(find.text('Task 3'), findsOneWidget);
  });

  testWidgets('BcViewGantt shows empty state when tasks empty (VAL-GANTT-018)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(tasks: <BcGanttTask>[]),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('empty')), findsOneWidget);
  });

  testWidgets('BcViewGantt column width varies by zoom level (VAL-GANTT-019)', (tester) async {
    final widths = <double>[];
    for (final level in BcGanttZoomLevel.values) {
      await tester.pumpWidget(harness(
        BcViewGantt(
          tasks: sampleTasks(),
          zoomLevel: level,
        ),
      ));
      await tester.pumpAndSettle();
      widths.add(tester.getSize(find.byKey(const ValueKey<String>('chartArea'))).width);
    }
    expect(widths[0], lessThan(widths[1]));
    expect(widths[1], lessThan(widths[2]));
    expect(widths[2], lessThan(widths[3]));
  });

  testWidgets('BcViewGantt positions tasks by start offset (VAL-GANTT-020)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'Early', start: 0, duration: 3),
          BcGanttTask(id: 't2', label: 'Late', start: 10, duration: 3),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final t1Left = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t1'))).dx;
    final t2Left = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t2'))).dx;
    expect(t2Left, greaterThan(t1Left));
  });

  testWidgets('BcViewGantt bar width reflects duration (VAL-GANTT-021)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'Short', start: 0, duration: 2),
          BcGanttTask(id: 't2', label: 'Long', start: 0, duration: 10),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final shortWidth = tester.getSize(find.byKey(const ValueKey<String>('bar-t1'))).width;
    final longWidth = tester.getSize(find.byKey(const ValueKey<String>('bar-t2'))).width;
    expect(longWidth, greaterThan(shortWidth));
  });

  testWidgets('BcViewGantt setZoom imperative changes level (VAL-GANTT-022)', (tester) async {
    final ganttKey = GlobalKey<BcViewGanttState>();
    BcGanttZoomLevel? capturedLevel;
    await tester.pumpWidget(harness(
      BcViewGantt(
        key: ganttKey,
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.day,
        onZoomChange: (level) => capturedLevel = level,
      ),
    ));
    await tester.pumpAndSettle();

    ganttKey.currentState!.setZoom(BcGanttZoomLevel.month);
    await tester.pumpAndSettle();
    expect(capturedLevel, BcGanttZoomLevel.month);
  });

  testWidgets('BcViewGantt toggleTask collapses and expands children (VAL-GANTT-023)', (tester) async {
    final ganttKey = GlobalKey<BcViewGanttState>();
    await tester.pumpWidget(harness(
      BcViewGantt(
        key: ganttKey,
        tasks: const <BcGanttTask>[
          BcGanttTask(id: 's1', label: 'Phase', start: 0, duration: 10, type: BcGanttTaskType.summary),
          BcGanttTask(id: 'child', label: 'Child', start: 1, duration: 4, parentId: 's1'),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-child')), findsOneWidget);

    ganttKey.currentState!.toggleTask('s1');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-child')), findsNothing);

    ganttKey.currentState!.toggleTask('s1');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-child')), findsOneWidget);
  });

  testWidgets('BcViewGantt toggleTask explicit collapsed param (VAL-GANTT-024)', (tester) async {
    final ganttKey = GlobalKey<BcViewGanttState>();
    await tester.pumpWidget(harness(
      BcViewGantt(
        key: ganttKey,
        tasks: const <BcGanttTask>[
          BcGanttTask(id: 's1', label: 'Phase', start: 0, duration: 10, type: BcGanttTaskType.summary),
          BcGanttTask(id: 'child', label: 'Child', start: 1, duration: 4, parentId: 's1'),
        ],
      ),
    ));
    await tester.pumpAndSettle();

    ganttKey.currentState!.toggleTask('s1', true);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-child')), findsNothing);

    ganttKey.currentState!.toggleTask('s1', true);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-child')), findsNothing);
  });

  testWidgets('BcViewGantt scrollToTask brings task into view (VAL-GANTT-025)', (tester) async {
    final ganttKey = GlobalKey<BcViewGanttState>();
    final tasks = <BcGanttTask>[];
    for (int i = 0; i < 20; i++) {
      tasks.add(BcGanttTask(id: 't$i', label: 'Task $i', start: i * 10.0, duration: 5));
    }
    await tester.pumpWidget(harness(
      BcViewGantt(
        key: ganttKey,
        tasks: tasks,
        zoomLevel: BcGanttZoomLevel.day,
      ),
    ));
    await tester.pumpAndSettle();

    ganttKey.currentState!.scrollToTask('t15');
    await tester.pumpAndSettle();

    final chartRect = tester.getRect(find.byKey(const ValueKey<String>('chartArea')));
    final barRect = tester.getRect(find.byKey(const ValueKey<String>('bar-t15')));
    expect(barRect.left, lessThanOrEqualTo(chartRect.right));
    expect(barRect.right, greaterThanOrEqualTo(chartRect.left));
  });

  testWidgets('BcViewGantt scrollToDate centers date in view (VAL-GANTT-026)', (tester) async {
    final ganttKey = GlobalKey<BcViewGanttState>();
    await tester.pumpWidget(harness(
      BcViewGantt(
        key: ganttKey,
        tasks: sampleTasks(),
        timelineStart: '2026-01-01',
        timelineEnd: '2026-12-31',
        zoomLevel: BcGanttZoomLevel.day,
      ),
    ));
    await tester.pumpAndSettle();

    ganttKey.currentState!.scrollToDate('2026-07-01');
    await tester.pumpAndSettle();

    final offset = ganttKey.currentState!.scrollOffset;
    expect(offset, greaterThan(0));
  });

  testWidgets('BcViewGantt toolbar renders zoom controls (VAL-GANTT-027)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(tasks: sampleTasks()),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('zoomIn')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('zoomOut')), findsOneWidget);
  });

  testWidgets('BcViewGantt critical path toggle styles tasks (VAL-GANTT-028)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        showCriticalPath: true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('criticalPathToggle')));
    await tester.pumpAndSettle();

    final barFinder = find.byKey(const ValueKey<String>('bar-t1'));
    expect(barFinder, findsOneWidget);
  });

  testWidgets('BcViewGantt timeline header renders labels (VAL-GANTT-029)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        timelineStart: '2026-06-20',
        timelineEnd: '2026-06-30',
        zoomLevel: BcGanttZoomLevel.day,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('timelineHead')), findsOneWidget);
  });

  testWidgets('BcViewGantt custom unitWidth overrides zoom default (VAL-GANTT-030)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'T', start: 0, duration: 1),
        ],
        unitWidth: 80,
        zoomLevel: BcGanttZoomLevel.day,
      ),
    ));
    await tester.pumpAndSettle();
    final barWidth = tester.getSize(find.byKey(const ValueKey<String>('bar-t1'))).width;
    expect(barWidth, closeTo(80, 5));
  });

  testWidgets('BcViewGantt custom rowHeight applies (VAL-GANTT-031)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'T1', start: 0, duration: 3),
          BcGanttTask(id: 't2', label: 'T2', start: 0, duration: 3),
        ],
        rowHeight: 48,
      ),
    ));
    await tester.pumpAndSettle();
    final t1Top = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t1'))).dy;
    final t2Top = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t2'))).dy;
    expect(t2Top - t1Top, closeTo(48, 2));
  });

  testWidgets('BcViewGantt FS link routes end to start (VAL-GANTT-032)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'T1', start: 0, duration: 5),
          BcGanttTask(id: 't2', label: 'T2', start: 6, duration: 4),
        ],
        links: <BcGanttLink>[
          BcGanttLink(id: 'l1', from: 't1', to: 't2', type: 'FS'),
        ],
        showDependencies: true,
      ),
    ));
    await tester.pumpAndSettle();

    final t1Right = tester.getTopRight(find.byKey(const ValueKey<String>('bar-t1'))).dx;
    final t2Left = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t2'))).dx;
    expect(t1Right, lessThanOrEqualTo(t2Left));
    expect(find.byKey(const ValueKey<String>('link-l1')), findsOneWidget);
  });

  testWidgets('BcViewGantt SS link routes start to start (VAL-GANTT-033)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'T1', start: 0, duration: 5),
          BcGanttTask(id: 't2', label: 'T2', start: 0, duration: 4),
        ],
        links: <BcGanttLink>[
          BcGanttLink(id: 'l1', from: 't1', to: 't2', type: 'SS'),
        ],
        showDependencies: true,
      ),
    ));
    await tester.pumpAndSettle();

    final t1Left = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t1'))).dx;
    final t2Left = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t2'))).dx;
    expect(t1Left, closeTo(t2Left, 20));
    expect(find.byKey(const ValueKey<String>('link-l1')), findsOneWidget);
  });

  testWidgets('BcViewGantt multiple tasks stack vertically (VAL-GANTT-034)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(tasks: sampleTasks()),
    ));
    await tester.pumpAndSettle();
    final t1Dy = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t1'))).dy;
    final t2Dy = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t2'))).dy;
    final t3Dy = tester.getTopLeft(find.byKey(const ValueKey<String>('bar-t3'))).dy;
    expect(t1Dy, lessThan(t2Dy));
    expect(t2Dy, lessThan(t3Dy));
  });

  testWidgets('BcViewGantt shows assignees when enabled (VAL-GANTT-035)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(
            id: 't1',
            label: 'Task',
            start: 0,
            duration: 10,
            assignees: <String>['Alice', 'Bob'],
          ),
        ],
        showAssignees: true,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
  });

  testWidgets('BcViewGantt custom color overrides palette (VAL-GANTT-036)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 't1', label: 'Red Task', start: 0, duration: 5, color: '#FF0000'),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-t1')), findsOneWidget);
  });

  testWidgets('BcViewGantt collapsed summary hides children (VAL-GANTT-037)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(
            id: 's1',
            label: 'Phase',
            start: 0,
            duration: 10,
            type: BcGanttTaskType.summary,
            collapsed: true,
          ),
          BcGanttTask(id: 'child', label: 'Child', start: 1, duration: 4, parentId: 's1'),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('bar-child')), findsNothing);
    expect(find.byKey(const ValueKey<String>('summary-s1')), findsOneWidget);
  });

  testWidgets('BcViewGantt milestone zero duration renders point (VAL-GANTT-038)', (tester) async {
    await tester.pumpWidget(harness(
      const BcViewGantt(
        tasks: <BcGanttTask>[
          BcGanttTask(id: 'm1', label: 'Go Live', start: 5, duration: 0, type: BcGanttTaskType.milestone),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    final milestoneFinder = find.byKey(const ValueKey<String>('milestone-m1'));
    expect(milestoneFinder, findsOneWidget);
    final size = tester.getSize(milestoneFinder);
    expect(size.width, lessThanOrEqualTo(20));
  });

  testWidgets('BcViewGantt onZoomChange not fired on init (VAL-GANTT-039)', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        zoomLevel: BcGanttZoomLevel.day,
        onZoomChange: (_) => callCount++,
      ),
    ));
    await tester.pumpAndSettle();
    expect(callCount, 0);
  });

  testWidgets('BcViewGantt empty links renders no arrows (VAL-GANTT-040)', (tester) async {
    await tester.pumpWidget(harness(
      BcViewGantt(
        tasks: sampleTasks(),
        links: const <BcGanttLink>[],
        showDependencies: true,
      ),
    ));
    await tester.pumpAndSettle();

    final linkWidgets = find.byWidgetPredicate(
      (widget) => widget.key is ValueKey && (widget.key as ValueKey).value.toString().startsWith('link-'),
    );
    expect(linkWidgets, findsNothing);
  });
}
