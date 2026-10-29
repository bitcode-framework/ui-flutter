import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_calendar_view.dart';

void main() {
  group('BcCalendarView', () {
    Widget buildHarness({
      BcCalendarViewMode view = BcCalendarViewMode.month,
      DateTime? date,
      List<BcCalendarViewEvent> events = const [],
      void Function(DateTime date, dynamic meta)? onDateSelect,
      void Function(BcCalendarViewEvent event)? onEventClick,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BcCalendarView(
            view: view,
            date: date,
            events: events,
            onDateSelect: onDateSelect,
            onEventClick: onEventClick,
          ),
        ),
      );
    }

    testWidgets('renders month grid with header (VAL-A5-001)', (tester) async {
      await tester.pumpWidget(buildHarness(
        date: DateTime(2026, 6, 15),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-calendar-view')), findsOneWidget);
      expect(find.byKey(const Key('bc-calendar-view-header')), findsOneWidget);
      expect(find.text('June 2026'), findsOneWidget);
    });

    testWidgets('renders weekday headers (VAL-A5-002)', (tester) async {
      await tester.pumpWidget(buildHarness(
        date: DateTime(2026, 6, 15),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
    });

    testWidgets('events render as badges in cells (VAL-A5-003)', (tester) async {
      final eventDate = DateTime(2026, 6, 15);
      await tester.pumpWidget(buildHarness(
        date: DateTime(2026, 6, 1),
        events: [
          BcCalendarViewEvent(
            id: 'e1',
            title: 'Meeting',
            start: eventDate,
            end: eventDate.add(const Duration(hours: 1)),
          ),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-calendar-view-event-e1')), findsOneWidget);
      expect(find.text('Meeting'), findsOneWidget);
    });

    testWidgets('day tap forwards onDateSelect (VAL-A5-004)', (tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(buildHarness(
        date: DateTime(2026, 6, 1),
        onDateSelect: (date, meta) => selectedDate = date,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-calendar-view-cell-2026-06-15')));
      await tester.pumpAndSettle();
      expect(selectedDate, isNotNull);
    });

    testWidgets('view mode switch renders week grid (VAL-A5-005)', (tester) async {
      await tester.pumpWidget(buildHarness(
        view: BcCalendarViewMode.week,
        date: DateTime(2026, 6, 15),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-calendar-view-week')), findsOneWidget);
    });

    testWidgets('view mode switch renders day view (VAL-A5-006)', (tester) async {
      await tester.pumpWidget(buildHarness(
        view: BcCalendarViewMode.day,
        date: DateTime(2026, 6, 15),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-calendar-view-day')), findsOneWidget);
    });
  });
}
