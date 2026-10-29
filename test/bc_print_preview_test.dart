import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_print_preview.dart';

void main() {
  group('BcPrintPreview', () {
    const html = '<html><body><h1>Invoice #1</h1><p>Total: \$100</p></body></html>';

    Widget buildHarness({
      String? content = html,
      String title = 'Print Preview',
      String triggerLabel = 'Print',
      bool disabled = false,
      bool hideToolbar = false,
      BcChangeHandler<void>? onPrint,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: BcPrintPreview(
              content: content,
              title: title,
              triggerLabel: triggerLabel,
              disabled: disabled,
              hideToolbar: hideToolbar,
              onPrint: onPrint,
            ),
          ),
        ),
      );
    }

    testWidgets('renders toolbar title + trigger button + preview content (VAL-E4-001)',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-print-preview-root')), findsOneWidget);
      expect(find.text('Print Preview'), findsOneWidget);
      expect(find.byKey(const Key('bc-print-preview-trigger')), findsOneWidget);
      expect(find.byKey(const Key('bc-print-preview-body')), findsOneWidget);
      // _stripHtml collapses whitespace; the stripped text contains the
      // invoice heading words as plain text.
      expect(find.textContaining('Invoice'), findsOneWidget);
    });

    testWidgets('tap trigger invokes onPrint with pointer source (VAL-E4-002)',
        (tester) async {
      BcChangeMeta? meta;
      await tester.pumpWidget(buildHarness(
        onPrint: (_, m) => meta = m,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-print-preview-trigger')));
      await tester.pumpAndSettle();
      expect(meta, isNotNull);
      expect(meta!.source, BcEventSource.pointer);
    });

    testWidgets('disabled trigger does not fire onPrint (VAL-E4-003)',
        (tester) async {
      bool fired = false;
      await tester.pumpWidget(buildHarness(
        disabled: true,
        onPrint: (_, __) => fired = true,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-print-preview-trigger')));
      await tester.pumpAndSettle();
      expect(fired, isFalse);
    });

    testWidgets('hideToolbar=true omits the toolbar (VAL-E4-004)',
        (tester) async {
      await tester.pumpWidget(buildHarness(hideToolbar: true));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bc-print-preview-toolbar')), findsNothing);
      expect(find.byKey(const Key('bc-print-preview-body')), findsOneWidget);
    });

    testWidgets('null/empty content shows empty-state message (VAL-E4-005)',
        (tester) async {
      await tester.pumpWidget(buildHarness(content: ''));
      await tester.pumpAndSettle();
      expect(find.text('No content to preview'), findsOneWidget);
    });

    testWidgets('custom triggerLabel renders (VAL-E4-006)', (tester) async {
      await tester.pumpWidget(buildHarness(triggerLabel: 'Print Invoice'));
      await tester.pumpAndSettle();
      expect(find.text('Print Invoice'), findsOneWidget);
    });
  });
}
