// Views demo - BcViewMap, BcViewReport, BcViewEditor, BcViewActivity,
// BcViewGantt, BcKanbanBoard, BcVirtualScroller, BcTieredMenu, BcOrgChart,
// BcCarousel, BcPivot.
library views_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class ViewsSection extends StatelessWidget {
  const ViewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Views',
          subtitle: 'Enterprise data views: Kanban, Gantt, maps, reports, activity, org charts, and more.',
        ),

        // -- BcKanbanBoard --
        DemoCard(
          title: 'BcKanbanBoard',
          description: 'Kanban board with cross-column drag-drop.',
          child: SizedBox(
            height: 320,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 720,
                child: BcKanbanBoard(
                  boardTitle: 'Sprint Board',
                  columns: const [
                    BcKanbanColumnConfig(id: 'todo', name: 'To Do'),
                    BcKanbanColumnConfig(id: 'doing', name: 'In Progress'),
                    BcKanbanColumnConfig(id: 'done', name: 'Done'),
                  ],
                  cards: const [
                    BcKanbanCard(id: '1', title: 'Setup CI', column: 'todo'),
                    BcKanbanCard(id: '2', title: 'Fix login bug', column: 'doing'),
                    BcKanbanCard(id: '3', title: 'Write docs', column: 'doing'),
                    BcKanbanCard(id: '4', title: 'Design homepage', column: 'done'),
                  ],
                ),
              ),
            ),
          ),
        ),

        // -- BcViewGantt --
        DemoCard(
          title: 'BcViewGantt',
          description: 'Gantt chart with task bars and timeline.',
          child: SizedBox(
            height: 260,
            child: BcViewGantt(
              tasks: const [
                BcGanttTask(id: 't1', label: 'Planning', start: 0, duration: 5, progress: 100),
                BcGanttTask(id: 't2', label: 'Design', start: 3, duration: 7, progress: 60),
                BcGanttTask(id: 't3', label: 'Development', start: 8, duration: 12, progress: 20),
                BcGanttTask(id: 't4', label: 'Testing', start: 18, duration: 5, progress: 0),
              ],
              timelineStart: '2026-06-01',
              timelineEnd: '2026-07-15',
              zoomLevel: BcGanttZoomLevel.week,
              showProgress: true,
              showTodayLine: true,
            ),
          ),
        ),

        // -- BcViewMap --
        DemoCard(
          title: 'BcViewMap',
          description: 'Map view with geo markers and tap selection.',
          child: BcViewMap(
            height: 240,
            center: const BcGeoCoord(lat: -6.2088, lng: 106.8456),
            zoom: 10,
            markers: const [
              BcMapMarker(id: 'hq', lat: -6.2088, lng: 106.8456, label: 'HQ'),
              BcMapMarker(id: 'branch', lat: -6.2200, lng: 106.8600, label: 'Branch Office'),
              BcMapMarker(id: 'warehouse', lat: -6.1900, lng: 106.8300, label: 'Warehouse'),
            ],
          ),
        ),

        // -- BcViewReport --
        DemoCard(
          title: 'BcViewReport',
          description: 'Structured report with titled sections.',
          child: BcViewReport(
            title: 'Q2 2026 Summary',
            subtitle: 'Engineering Department',
            sections: const [
              BcReportSection(
                id: 's1',
                title: 'Highlights',
                content: 'Shipped 14 demo sections, reached full component parity.',
              ),
              BcReportSection(
                id: 's2',
                title: 'Metrics',
                content: '11 widget tests pass, 0 analyze issues, 95+ components demoed.',
              ),
              BcReportSection(
                id: 's3',
                title: 'Next Quarter',
                content: 'Focus on BcRenderer, reactive engine wiring, and offline sync.',
              ),
            ],
          ),
        ),

        // -- BcViewActivity --
        DemoCard(
          title: 'BcViewActivity',
          description: 'Activity feed timeline sorted newest-first.',
          child: SizedBox(
            height: 280,
            child: BcViewActivity(
              entries: [
                BcViewActivityEntry(
                  id: '1',
                  timestamp: DateTime(2026, 6, 28, 14, 30),
                  actor: 'Alice',
                  action: 'merged PR #42',
                  detail: 'Flutter demo parity complete',
                ),
                BcViewActivityEntry(
                  id: '2',
                  timestamp: DateTime(2026, 6, 28, 10, 15),
                  actor: 'Bob',
                  action: 'opened issue #99',
                  detail: 'BcChart crash in headless tests',
                ),
                BcViewActivityEntry(
                  id: '3',
                  timestamp: DateTime(2026, 6, 27, 16, 0),
                  actor: 'Charlie',
                  action: 'pushed 3 commits',
                ),
              ],
            ),
          ),
        ),

        // -- BcViewEditor --
        DemoCard(
          title: 'BcViewEditor',
          description: 'Visual layout editor with drag-to-reorder components (disabled here to show static layout).',
          child: BcViewEditor(
            disabled: true,
            defaultComponents: const [
              BcViewEditorComponent(id: 'c1', type: 'list', label: 'Task List'),
              BcViewEditorComponent(id: 'c2', type: 'chart', label: 'Burndown Chart'),
              BcViewEditorComponent(id: 'c3', type: 'form', label: 'New Task Form'),
            ],
          ),
        ),

        // -- BcOrgChart --
        DemoCard(
          title: 'BcOrgChart',
          description: 'Organizational hierarchy with expandable nodes.',
          child: BcOrgChart(
            defaultExpanded: const ['ceo', 'vp1'],
            root: const BcOrgNode(
              id: 'ceo',
              label: 'CEO',
              title: 'Chief Executive',
              children: [
                BcOrgNode(
                  id: 'vp1',
                  label: 'VP Engineering',
                  title: 'Engineering',
                  children: [
                    BcOrgNode(id: 'lead1', label: 'Tech Lead', title: 'Frontend'),
                    BcOrgNode(id: 'lead2', label: 'Tech Lead', title: 'Backend'),
                  ],
                ),
                BcOrgNode(
                  id: 'vp2',
                  label: 'VP Sales',
                  title: 'Sales',
                ),
              ],
            ),
          ),
        ),

        // -- BcTieredMenu --
        DemoCard(
          title: 'BcTieredMenu',
          description: 'Cascading tiered menu with submenus.',
          child: BcTieredMenu(
            items: const [
              BcTieredMenuItem(
                key: 'new',
                label: 'New',
                icon: Icons.add,
                children: [
                  BcTieredMenuItem(key: 'project', label: 'Project'),
                  BcTieredMenuItem(key: 'file', label: 'File'),
                  BcTieredMenuItem(key: 'folder', label: 'Folder'),
                ],
              ),
              BcTieredMenuItem(
                key: 'export',
                label: 'Export As',
                icon: Icons.download,
                children: [
                  BcTieredMenuItem(key: 'csv', label: 'CSV'),
                  BcTieredMenuItem(key: 'pdf', label: 'PDF'),
                ],
              ),
              BcTieredMenuItem(key: 'exit', label: 'Exit', icon: Icons.exit_to_app),
            ],
          ),
        ),

        // -- BcVirtualScroller --
        DemoCard(
          title: 'BcVirtualScroller',
          description: 'Windowed virtual list for large datasets.',
          child: SizedBox(
            height: 200,
            child: BcVirtualScroller(
              items: List.generate(
                500,
                (i) => BcVirtualScrollerItem(
                  id: '$i',
                  label: 'Item ${i + 1}',
                  description: 'Description for item ${i + 1}',
                ),
              ),
            ),
          ),
        ),

        // -- BcCarousel --
        DemoCard(
          title: 'BcCarousel',
          description: 'Image carousel with autoplay, dots, and arrows.',
          child: BcCarousel(
            aspectRatio: 16 / 9,
            autoplay: false,
            slides: const [
              BcCarouselSlide(caption: 'Slide One'),
              BcCarouselSlide(caption: 'Slide Two'),
              BcCarouselSlide(caption: 'Slide Three'),
            ],
          ),
        ),

        // -- BcDetailView --
        DemoCard(
          title: 'BcDetailView',
          description: 'Master-detail renderer with fields and tabs.',
          child: BcDetailView(
            title: 'Customer Detail',
            fields: const [
              BcDetailViewField(label: 'Name', value: 'Acme Corp'),
              BcDetailViewField(label: 'Email', value: 'contact@acme.com'),
              BcDetailViewField(label: 'Phone', value: '+1 555-0100'),
            ],
          ),
        ),

        // -- BcGridView --
        DemoCard(
          title: 'BcGridView',
          description: 'Spreadsheet-style grid with columns and rows.',
          child: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: BcGridView(
                columns: const [
                  BcGridViewColumn(key: 'id', label: 'ID'),
                  BcGridViewColumn(key: 'name', label: 'Name'),
                  BcGridViewColumn(key: 'status', label: 'Status'),
                ],
                rows: const [
                  {'id': '001', 'name': 'Alice', 'status': 'Active'},
                  {'id': '002', 'name': 'Bob', 'status': 'Pending'},
                  {'id': '003', 'name': 'Charlie', 'status': 'Active'},
                ],
              ),
            ),
          ),
        ),

        // -- BcTreeView --
        DemoCard(
          title: 'BcTreeView',
          description: 'Hierarchical tree with expand/collapse.',
          child: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: BcTreeView(
                defaultExpandedKeys: const {'1', '1b'},
                data: const [
                  BcTreeViewNode(id: '1', label: 'Root', children: [
                    BcTreeViewNode(id: '1a', label: 'Child A'),
                    BcTreeViewNode(id: '1b', label: 'Child B', children: [
                      BcTreeViewNode(id: '1b1', label: 'Grandchild'),
                    ]),
                  ]),
                  BcTreeViewNode(id: '2', label: 'Root 2'),
                ],
              ),
            ),
          ),
        ),

        // -- BcKanbanView --
        DemoCard(
          title: 'BcKanbanView',
          description: 'Kanban board with columns and drag-drop cards.',
          child: SizedBox(
            height: 280,
            child: BcKanbanView(
              columns: const [
                BcKanbanViewColumn(id: 'todo', title: 'To Do'),
                BcKanbanViewColumn(id: 'doing', title: 'In Progress'),
                BcKanbanViewColumn(id: 'done', title: 'Done'),
              ],
              cards: const [
                BcKanbanViewCard(id: '1', title: 'Setup CI', columnId: 'todo'),
                BcKanbanViewCard(id: '2', title: 'Fix bug', columnId: 'doing'),
              ],
            ),
          ),
        ),

        // -- BcCalendarView --
        DemoCard(
          title: 'BcCalendarView',
          description: 'Calendar with month/week/day views and events.',
          child: SizedBox(
            height: 320,
            child: BcCalendarView(
              events: [
                BcCalendarViewEvent(
                  id: '1',
                  title: 'Team Meeting',
                  start: DateTime(2026, 6, 29, 10, 0),
                  end: DateTime(2026, 6, 29, 11, 0),
                ),
              ],
            ),
          ),
        ),

        // -- BcDashboard --
        DemoCard(
          title: 'BcDashboard',
          description: 'Widget grid with configurable columns.',
          child: BcDashboard(
            columns: 3,
            widgets: const [
              BcDashboardWidget(id: '1', title: 'Revenue', kind: BcDashboardWidgetKind.stat),
              BcDashboardWidget(id: '2', title: 'Users', kind: BcDashboardWidgetKind.stat),
              BcDashboardWidget(id: '3', title: 'Orders', kind: BcDashboardWidgetKind.stat),
            ],
          ),
        ),

        // -- BcPivot --
        DemoCard(
          title: 'BcPivot',
          description: 'Pivot table with 2D aggregation matrix and row/column totals.',
          child: BcPivot(
            title: 'Sales by Region × Quarter',
            showTotals: true,
            showGrandTotal: true,
            result: BcPivotResult(
              rowHeaders: const ['North', 'South', 'East', 'West'],
              colHeaders: const ['Q1', 'Q2', 'Q3', 'Q4'],
              cells: const [
                [[120.0], [150.0], [180.0], [200.0]],
                [[90.0], [110.0], [130.0], [160.0]],
                [[200.0], [220.0], [240.0], [260.0]],
                [[75.0], [95.0], [115.0], [135.0]],
              ],
              rowTotals: const [
                [650.0],
                [490.0],
                [920.0],
                [420.0],
              ],
              colTotals: const [
                [485.0],
                [575.0],
                [665.0],
                [755.0],
              ],
              grandTotal: const [2480.0],
              valueFields: const [
                BcPivotValueField(field: 'sales', agg: BcPivotAggFunc.sum, alias: 'Revenue'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
