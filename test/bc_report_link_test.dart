import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/components/bc_report_link.dart';

void main() {
  group('BcReportLink', () {
    Widget buildHarness({
      String? reportRef,
      String label = 'Generate Link',
      String baseUrl = 'https://example.com/reports',
      bool disabled = false,
      void Function(String, BcChangeMeta)? onLinkGenerated,
      void Function(String, BcChangeMeta)? onCopy,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 400,
            child: BcReportLink(
              reportRef: reportRef,
              label: label,
              baseUrl: baseUrl,
              disabled: disabled,
              onLinkGenerated: onLinkGenerated,
              onCopy: onCopy,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'generate produces a shareable link for a valid report ref '
        '(VAL-M6-031)', (tester) async {
      await tester.pumpWidget(buildHarness(
        reportRef: 'invoice-123',
        baseUrl: 'https://example.com/reports',
      ));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-report-link-display')), findsOneWidget);

      final linkFinder = find.byKey(const Key('bc-report-link-text'));
      expect(linkFinder, findsOneWidget);

      final linkText = tester.widget<Text>(linkFinder).data!;
      expect(linkText, contains('invoice-123'));
      expect(linkText, startsWith('https://'));
      expect(Uri.tryParse(linkText), isNotNull);
      expect(Uri.tryParse(linkText)!.hasAbsolutePath, isTrue);
    });

    testWidgets(
        'empty/null reportRef does not produce a link and renders error '
        '(VAL-M6-031)', (tester) async {
      await tester.pumpWidget(buildHarness(
        reportRef: null,
      ));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-report-link-display')), findsNothing);
      expect(find.byKey(const Key('bc-report-link-error')), findsOneWidget);
      expect(find.byKey(const Key('bc-report-link-text')), findsNothing);
    });

    testWidgets(
        'empty string reportRef also renders error state '
        '(VAL-M6-031)', (tester) async {
      await tester.pumpWidget(buildHarness(
        reportRef: '',
      ));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-report-link-error')), findsOneWidget);
      expect(find.byKey(const Key('bc-report-link-text')), findsNothing);
    });

    testWidgets(
        'link generation emits onLinkGenerated with link and meta '
        '(VAL-M6-032)', (tester) async {
      String? capturedLink;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(buildHarness(
        reportRef: 'report-456',
        baseUrl: 'https://app.test/r',
        onLinkGenerated: (link, meta) {
          capturedLink = link;
          capturedMeta = meta;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      expect(capturedLink, isNotNull);
      expect(capturedLink, contains('report-456'));
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets(
        'copy button emits onCopy with the link and meta '
        '(VAL-M6-032)', (tester) async {
      String? capturedLink;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(buildHarness(
        reportRef: 'report-789',
        baseUrl: 'https://app.test/r',
        onCopy: (link, meta) {
          capturedLink = link;
          capturedMeta = meta;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-report-link-copy')));
      await tester.pumpAndSettle();

      expect(capturedLink, isNotNull);
      expect(capturedLink, contains('report-789'));
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);
    });

    testWidgets(
        'disabled prevents generate and copy callbacks '
        '(VAL-M6-032)', (tester) async {
      var generateCount = 0;
      var copyCount = 0;

      await tester.pumpWidget(buildHarness(
        reportRef: 'report-disabled',
        disabled: true,
        onLinkGenerated: (link, meta) {
          generateCount++;
        },
        onCopy: (link, meta) {
          copyCount++;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      expect(generateCount, 0);
      expect(find.byKey(const Key('bc-report-link-display')), findsNothing);

      expect(find.byKey(const Key('bc-report-link-copy')), findsNothing);
      expect(copyCount, 0);
    });

    testWidgets(
        'custom label renders on the generate button '
        '(VAL-M6-031)', (tester) async {
      await tester.pumpWidget(buildHarness(
        reportRef: 'report-custom',
        label: 'Create Link',
      ));

      expect(find.text('Create Link'), findsOneWidget);
    });

    testWidgets(
        'regenerate produces a new link (VAL-M6-031)',
        (tester) async {
      await tester.pumpWidget(buildHarness(
        reportRef: 'report-regen',
        baseUrl: 'https://app.test/r',
      ));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      final linkText1 = tester
          .widget<Text>(find.byKey(const Key('bc-report-link-text')))
          .data!;
      expect(linkText1, contains('report-regen'));

      await tester.tap(find.byKey(const Key('bc-report-link-generate')));
      await tester.pumpAndSettle();

      final linkText2 = tester
          .widget<Text>(find.byKey(const Key('bc-report-link-text')))
          .data!;

      expect(linkText2, contains('report-regen'));
      expect(Uri.tryParse(linkText2), isNotNull);
    });
  });
}
