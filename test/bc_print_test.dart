import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_print.dart';

void main() {
  group('BcPrint', () {
    Widget buildHarness({
      String? label,
      String? target,
      bool disabled = false,
      bool confirm = false,
      BcPrintVariant variant = BcPrintVariant.defaultVariant,
      void Function()? onBeforePrint,
      void Function(String, BcChangeMeta)? onPrint,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 400,
            child: BcPrint(
              label: label,
              target: target,
              disabled: disabled,
              confirm: confirm,
              variant: variant,
              onBeforePrint: onBeforePrint,
              onPrint: onPrint,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'print button renders and triggers the print flow on tap '
        '(VAL-M6-029)', (tester) async {
      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-001',
        confirm: true,
      ));

      expect(find.byKey(const Key('bc-print-button')), findsOneWidget);
      expect(find.text('Print'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-print-dialog')), findsOneWidget);
    });

    testWidgets(
        'disabled button does not open dialog (VAL-M6-029)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-001',
        disabled: true,
      ));

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-print-dialog')), findsNothing);
    });

    testWidgets(
        'print without confirm triggers onPrint immediately on tap '
        '(VAL-M6-030)', (tester) async {
      String? capturedRef;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-001',
        onPrint: (ref, meta) {
          capturedRef = ref;
          capturedMeta = meta;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      expect(capturedRef, 'report-001');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets(
        'print with confirm requires dialog confirmation '
        '(VAL-M6-030)', (tester) async {
      String? capturedRef;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-002',
        confirm: true,
        onPrint: (ref, meta) {
          capturedRef = ref;
          capturedMeta = meta;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-print-dialog')), findsOneWidget);
      expect(capturedRef, isNull);

      await tester.tap(find.byKey(const Key('bc-print-confirm')));
      await tester.pumpAndSettle();

      expect(capturedRef, 'report-002');
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);

      expect(find.byKey(const Key('bc-print-dialog')), findsNothing);
    });

    testWidgets(
        'canceling the dialog does not emit onPrint (VAL-M6-030)',
        (tester) async {
      String? capturedRef;

      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-003',
        confirm: true,
        onPrint: (ref, meta) {
          capturedRef = ref;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-print-cancel')));
      await tester.pumpAndSettle();

      expect(capturedRef, isNull);
      expect(find.byKey(const Key('bc-print-dialog')), findsNothing);
    });

    testWidgets(
        'disabled prevents any onPrint (VAL-M6-030)', (tester) async {
      var callbackCount = 0;

      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-004',
        disabled: true,
        onPrint: (ref, meta) {
          callbackCount++;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      expect(callbackCount, 0);
    });

    testWidgets(
        'onBeforePrint fires before opening dialog (VAL-M6-029)',
        (tester) async {
      var beforePrintCalled = false;

      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-005',
        onBeforePrint: () {
          beforePrintCalled = true;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      expect(beforePrintCalled, isTrue);
    });

    testWidgets(
        'ghost variant renders button without solid background '
        '(VAL-M6-029)', (tester) async {
      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-006',
        variant: BcPrintVariant.ghost,
      ));

      expect(find.byKey(const Key('bc-print-button')), findsOneWidget);
    });

    testWidgets(
        'dialog cancel via scrim tap dismisses without printing '
        '(VAL-M6-030)', (tester) async {
      String? capturedRef;

      await tester.pumpWidget(buildHarness(
        label: 'Print',
        target: 'report-007',
        confirm: true,
        onPrint: (ref, meta) {
          capturedRef = ref;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-print-button')));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(capturedRef, isNull);
      expect(find.byKey(const Key('bc-print-dialog')), findsNothing);
    });
  });
}
