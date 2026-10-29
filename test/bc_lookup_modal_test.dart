import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_lookup_modal.dart';
import 'package:bc_ui_flutter/src/components/bc_data_table.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

/// Widget tests for [BcLookupModal] (ADR-011 Phase 5b.2).
///
/// Covers the 35 VAL-LOOKUP assertions from the validation contract plus
/// VAL-CROSS-005 (BcDataTable reuse inside dialog). Tests pump the widget
/// into a MaterialApp + Scaffold harness, then assert on rendered output
/// and captured callback values.
void main() {
  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  List<Map<String, dynamic>> sampleData() => <Map<String, dynamic>>[
        <String, dynamic>{
          'id': '1',
          'name': 'Alice',
          'email': 'alice@example.com'
        },
        <String, dynamic>{
          'id': '2',
          'name': 'Bob',
          'email': 'bob@example.com'
        },
        <String, dynamic>{
          'id': '3',
          'name': 'Charlie',
          'email': 'charlie@example.com'
        },
      ];

  List<BcLookupModalColumn> sampleColumns() => <BcLookupModalColumn>[
        const BcLookupModalColumn(key: 'name', label: 'Name'),
        const BcLookupModalColumn(key: 'email', label: 'Email'),
      ];

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------

  group('BcLookupModal rendering', () {
    testWidgets('does not render dialog when open is false (VAL-LOOKUP-001)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: false,
          title: 'Pick Contact',
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Pick Contact'), findsNothing);
    });

    testWidgets(
        'renders title and BcDataTable inside dialog when open (VAL-LOOKUP-002, VAL-CROSS-005)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Pick Contact',
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Pick Contact'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is BcDataTable),
        findsOneWidget,
      );
    });

    testWidgets('renders column labels in order (VAL-LOOKUP-003)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders data rows with cell values (VAL-LOOKUP-004)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('shows empty state when data is empty (VAL-LOOKUP-023)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: const <Map<String, dynamic>>[],
        ),
      ));
      await tester.pump();

      expect(find.text('No records found'), findsOneWidget);
    });

    testWidgets('omits title when not provided (VAL-LOOKUP-034)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
      // No title text rendered in the header Row
      final headerRow = tester.widget<Row>(find.byType(Row).first);
      expect(
        headerRow.children.any((c) => c is Text && c.data != null),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  group('BcLookupModal search', () {
    testWidgets('search filters rows by searchFields (VAL-LOOKUP-005)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          searchable: true,
          searchFields: const ['name', 'email'],
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('searchInput')), findsOneWidget);

      await tester.enterText(
          find.byKey(const ValueKey<String>('searchInput')), 'ali');
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
      expect(find.text('Charlie'), findsNothing);
    });

    testWidgets('hides search input when searchable is false (VAL-LOOKUP-030)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          searchable: false,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(
          find.byKey(const ValueKey<String>('searchInput')), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  group('BcLookupModal pagination', () {
    testWidgets(
        'next button advances to next page (VAL-LOOKUP-007)', (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          pageSize: 1,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('nextButton')));
      await tester.pump();

      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets(
        'prev button returns to previous page (VAL-LOOKUP-006)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          pageSize: 1,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      // Go to page 2
      await tester.tap(find.byKey(const ValueKey<String>('nextButton')));
      await tester.pump();
      expect(find.text('2 / 3'), findsOneWidget);

      // Go back to page 1
      await tester.tap(find.byKey(const ValueKey<String>('prevButton')));
      await tester.pump();
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('page info displays current/total (VAL-LOOKUP-008)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          pageSize: 1,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('default pageSize paginates large data (VAL-LOOKUP-033)',
        (tester) async {
      final bigData = List<Map<String, dynamic>>.generate(
        25,
        (i) => <String, dynamic>{
          'id': '$i',
          'name': 'User $i',
          'email': 'user$i@example.com'
        },
      );

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: bigData,
        ),
      ));
      await tester.pump();

      // Default pageSize is 10, so 25 items = 3 pages (10, 10, 5)
      expect(find.text('1 / 3'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Single select
  // ---------------------------------------------------------------------------

  group('BcLookupModal single select', () {
    testWidgets('row tap selects and confirm emits value (VAL-LOOKUP-009)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      // Tap a row to select
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(capturedReason, BcChangeReason.select);

      // Confirm selection
      await tester
          .tap(find.byKey(const ValueKey<String>('confirmButton')));
      await tester.pumpAndSettle();

      expect(capturedValue, '1');
      expect(capturedReason, BcChangeReason.confirm);
    });

    testWidgets('single select value is String (VAL-LOOKUP-010)',
        (tester) async {
      dynamic capturedValue;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onValueChange: (value, meta) {
            capturedValue = value;
          },
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(capturedValue, isA<String>());
      expect(capturedValue, '1');
    });

    testWidgets('row tap fires onValueChange with select reason (VAL-LOOKUP-019)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      expect(capturedValue, '1');
      expect(capturedReason, BcChangeReason.select);
    });

    testWidgets('pre-selected value highlights row on open (VAL-LOOKUP-031)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          value: '2',
        ),
      ));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('row-selected-2')),
        findsOneWidget,
      );
    });

    testWidgets('confirm disabled without selection (VAL-LOOKUP-035)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey<String>('confirmButton')),
      );
      expect(button.onPressed, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Multiple select
  // ---------------------------------------------------------------------------

  group('BcLookupModal multiple select', () {
    testWidgets('renders checkbox per row in multiple mode (VAL-LOOKUP-011)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          multiple: true,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      // 3 data rows × 1 checkbox each = 3 checkboxes
      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('multiple confirm emits List<String> (VAL-LOOKUP-012)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          multiple: true,
          columns: sampleColumns(),
          data: sampleData(),
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      // Check first two checkboxes
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0));
      await tester.pump();
      await tester.tap(checkboxes.at(1));
      await tester.pump();

      // Confirm
      await tester
          .tap(find.byKey(const ValueKey<String>('confirmButton')));
      await tester.pumpAndSettle();

      expect(capturedValue, isA<List<String>>());
      expect(capturedValue, containsAll(<String>['1', '2']));
      expect(capturedReason, BcChangeReason.confirm);
    });

    testWidgets('deselect fires clear reason (VAL-LOOKUP-020)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          multiple: true,
          columns: sampleColumns(),
          data: sampleData(),
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      // Check first checkbox
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0));
      await tester.pump();
      expect(capturedReason, BcChangeReason.select);

      // Uncheck it — selection becomes empty, fires clear
      await tester.tap(checkboxes.at(0));
      await tester.pump();
      expect(capturedValue, <String>[]);
      expect(capturedReason, BcChangeReason.clear);
    });

    testWidgets(
        'pre-selected multiple values check boxes (VAL-LOOKUP-032)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          multiple: true,
          columns: sampleColumns(),
          data: sampleData(),
          value: const <String>['1', '3'],
        ),
      ));
      await tester.pump();

      final checkboxes = tester.widgetList<Checkbox>(
        find.byType(Checkbox),
      );
      final checkedCount =
          checkboxes.where((cb) => cb.value == true).length;
      expect(checkedCount, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // Closeable / overlay behavior
  // ---------------------------------------------------------------------------

  group('BcLookupModal closeable and overlay', () {
    testWidgets('closeable false hides close button (VAL-LOOKUP-013)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          closeable: false,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('closeButton')),
        findsNothing,
      );
    });

    testWidgets('closeable true shows close button (VAL-LOOKUP-014)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          closeable: true,
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('closeButton')),
        findsOneWidget,
      );
    });

    testWidgets(
        'closeOnOverlay true closes on overlay tap (VAL-LOOKUP-015)',
        (tester) async {
      bool? capturedOpen;
      BcChangeReason? capturedReason;
      int valueChangeCount = 0;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          closeOnOverlay: true,
          columns: sampleColumns(),
          data: sampleData(),
          onOpenChange: (open, meta) {
            capturedOpen = open;
            capturedReason = meta.reason;
          },
          onValueChange: (_, __) {
            valueChangeCount++;
          },
        ),
      ));
      await tester.pump();

      // Tap outside the dialog (top-left corner of the barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(capturedOpen, isFalse);
      expect(capturedReason, BcChangeReason.overlayClick);
      expect(valueChangeCount, 0);
    });

    testWidgets(
        'closeOnOverlay false keeps dialog open (VAL-LOOKUP-016)',
        (tester) async {
      bool openChangeCalled = false;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          closeOnOverlay: false,
          columns: sampleColumns(),
          data: sampleData(),
          onOpenChange: (_, __) {
            openChangeCalled = true;
          },
        ),
      ));
      await tester.pump();

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(openChangeCalled, isFalse);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('close button closes dialog (VAL-LOOKUP-025)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          defaultOpen: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester
          .tap(find.byKey(const ValueKey<String>('closeButton')));
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Cancel / Confirm
  // ---------------------------------------------------------------------------

  group('BcLookupModal cancel and confirm', () {
    testWidgets('cancel closes without emitting value (VAL-LOOKUP-017)',
        (tester) async {
      BcChangeReason? openReason;
      int valueChangeCount = 0;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onOpenChange: (_, meta) {
            openReason = meta.reason;
          },
          onValueChange: (_, __) {
            valueChangeCount++;
          },
        ),
      ));
      await tester.pump();

      // Select a row first
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      final selectCount = valueChangeCount;

      // Cancel
      await tester
          .tap(find.byKey(const ValueKey<String>('cancelButton')));
      await tester.pumpAndSettle();

      expect(openReason, BcChangeReason.cancel);
      expect(valueChangeCount, selectCount); // no additional value emission
    });

    testWidgets(
        'confirm emits value and closes dialog (VAL-LOOKUP-018)',
        (tester) async {
      dynamic capturedValue;
      BcChangeReason? valueReason;
      BcChangeReason? openReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onValueChange: (value, meta) {
            capturedValue = value;
            valueReason = meta.reason;
          },
          onOpenChange: (_, meta) {
            openReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      // Select row
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      // Confirm
      await tester
          .tap(find.byKey(const ValueKey<String>('confirmButton')));
      await tester.pumpAndSettle();

      expect(capturedValue, '1');
      expect(valueReason, BcChangeReason.confirm);
      expect(openReason, BcChangeReason.confirm);
    });
  });

  // ---------------------------------------------------------------------------
  // Escape key
  // ---------------------------------------------------------------------------

  group('BcLookupModal keyboard', () {
    testWidgets('escape key closes with escape reason (VAL-LOOKUP-022)',
        (tester) async {
      bool? capturedOpen;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onOpenChange: (open, meta) {
            capturedOpen = open;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(capturedOpen, isFalse);
      expect(capturedReason, BcChangeReason.escape);
    });
  });

  // ---------------------------------------------------------------------------
  // Controlled / uncontrolled open state
  // ---------------------------------------------------------------------------

  group('BcLookupModal open state', () {
    testWidgets(
        'external open true fires toggle reason (VAL-LOOKUP-021)',
        (tester) async {
      bool isOpen = false;
      BcChangeReason? capturedReason;
      late StateSetter outerSetState;

      await tester.pumpWidget(harness(
        StatefulBuilder(
          builder: (context, setState) {
            outerSetState = setState;
            return BcLookupModal(
              open: isOpen,
              title: 'Test',
              columns: sampleColumns(),
              data: sampleData(),
              onOpenChange: (_, meta) {
                capturedReason = meta.reason;
              },
            );
          },
        ),
      ));
      await tester.pump();

      isOpen = true;
      outerSetState(() {});
      await tester.pump();

      expect(capturedReason, BcChangeReason.toggle);
    });

    testWidgets('defaultOpen renders dialog open (VAL-LOOKUP-024)',
        (tester) async {
      await tester.pumpWidget(harness(
        BcLookupModal(
          defaultOpen: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
        ),
      ));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets(
        'controlled open false hides dialog (VAL-LOOKUP-026)',
        (tester) async {
      bool isOpen = true;
      late StateSetter outerSetState;

      await tester.pumpWidget(harness(
        StatefulBuilder(
          builder: (context, setState) {
            outerSetState = setState;
            return BcLookupModal(
              open: isOpen,
              title: 'Test',
              columns: sampleColumns(),
              data: sampleData(),
            );
          },
        ),
      ));
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);

      isOpen = false;
      outerSetState(() {});
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Imperative methods
  // ---------------------------------------------------------------------------

  group('BcLookupModal imperative methods', () {
    testWidgets('reset fires programmatic reason (VAL-LOOKUP-027)',
        (tester) async {
      final key = GlobalKey<BcLookupModalState>();
      dynamic capturedValue;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          key: key,
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onValueChange: (value, meta) {
            capturedValue = value;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      // Select a row first
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();

      // Reset
      key.currentState!.reset();
      await tester.pump();

      expect(capturedReason, BcChangeReason.programmatic);
      expect(capturedValue, '');
    });

    testWidgets(
        'imperative open fires programmatic reason (VAL-LOOKUP-028)',
        (tester) async {
      final key = GlobalKey<BcLookupModalState>();
      bool? capturedOpen;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          key: key,
          open: false,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onOpenChange: (open, meta) {
            capturedOpen = open;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      key.currentState!.open();
      await tester.pump();

      expect(capturedOpen, isTrue);
      expect(capturedReason, BcChangeReason.programmatic);
    });

    testWidgets(
        'imperative close fires programmatic reason (VAL-LOOKUP-029)',
        (tester) async {
      final key = GlobalKey<BcLookupModalState>();
      bool? capturedOpen;
      BcChangeReason? capturedReason;

      await tester.pumpWidget(harness(
        BcLookupModal(
          key: key,
          open: true,
          title: 'Test',
          columns: sampleColumns(),
          data: sampleData(),
          onOpenChange: (open, meta) {
            capturedOpen = open;
            capturedReason = meta.reason;
          },
        ),
      ));
      await tester.pump();

      key.currentState!.close();
      await tester.pump();

      expect(capturedOpen, isFalse);
      expect(capturedReason, BcChangeReason.programmatic);
    });
  });
}
