import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/core/types.dart';
import 'package:bc_ui_flutter/src/theme/bc_theme.dart';
import 'package:bc_ui_flutter/src/components/bc_export.dart';

void main() {
  group('BcExport', () {
    Widget buildHarness({
      List<BcExportFormat> formats = const [
        BcExportFormat.csv,
        BcExportFormat.xlsx,
        BcExportFormat.pdf,
      ],
      bool disabled = false,
      String label = 'Export',
      void Function(BcExportFormat, BcChangeMeta)? onExport,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcExport(
              formats: formats,
              disabled: disabled,
              label: label,
              onExport: onExport,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'menu lists all configured formats and opens on tap '
        '(VAL-M6-027)', (tester) async {
      await tester.pumpWidget(buildHarness());

      expect(find.byKey(const Key('bc-export-trigger')), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);

      // Menu not visible before tap
      expect(find.byKey(const Key('bc-export-item-csv')), findsNothing);

      await tester.tap(find.byKey(const Key('bc-export-trigger')));
      await tester.pumpAndSettle();

      // Menu items visible
      expect(find.byKey(const Key('bc-export-item-csv')), findsOneWidget);
      expect(find.byKey(const Key('bc-export-item-xlsx')), findsOneWidget);
      expect(find.byKey(const Key('bc-export-item-pdf')), findsOneWidget);

      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('Excel'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);

      // Selecting an item closes the menu
      await tester.tap(find.byKey(const Key('bc-export-item-csv')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-export-item-csv')), findsNothing);
    });

    testWidgets(
        'empty formats renders disabled trigger that does not open '
        '(VAL-M6-027)', (tester) async {
      await tester.pumpWidget(buildHarness(formats: const []));

      // The trigger is rendered with muted background when disabled
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('bc-export-trigger')),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, BcTheme.muted);

      await tester.tap(find.byKey(const Key('bc-export-trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-export-item-csv')), findsNothing);
    });

    testWidgets(
        'outside tap closes the menu (VAL-M6-027)', (tester) async {
      await tester.pumpWidget(buildHarness());

      await tester.tap(find.byKey(const Key('bc-export-trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-export-item-csv')), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-export-item-csv')), findsNothing);
    });

    testWidgets(
        'selecting a format emits onExport with format id and meta '
        '(VAL-M6-028)', (tester) async {
      BcExportFormat? capturedFormat;
      BcChangeMeta? capturedMeta;

      await tester.pumpWidget(buildHarness(
        onExport: (format, meta) {
          capturedFormat = format;
          capturedMeta = meta;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-export-trigger')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-export-item-csv')));
      await tester.pumpAndSettle();

      expect(capturedFormat, BcExportFormat.csv);
      expect(capturedMeta, isNotNull);
      expect(capturedMeta!.source, BcEventSource.pointer);

      expect(find.byKey(const Key('bc-export-item-csv')), findsNothing);
    });

    testWidgets(
        'selecting the same format twice emits both times '
        '(VAL-M6-028)', (tester) async {
      final capturedFormats = <BcExportFormat>[];

      await tester.pumpWidget(buildHarness(
        onExport: (format, meta) {
          capturedFormats.add(format);
        },
      ));

      await tester.tap(find.byKey(const Key('bc-export-trigger')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-export-item-pdf')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('bc-export-trigger')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bc-export-item-pdf')));
      await tester.pumpAndSettle();

      expect(capturedFormats.length, 2);
      expect(capturedFormats[0], BcExportFormat.pdf);
      expect(capturedFormats[1], BcExportFormat.pdf);
    });

    testWidgets(
        'disabled prevents menu opening and no onExport fires '
        '(VAL-M6-028)', (tester) async {
      var callbackCount = 0;

      await tester.pumpWidget(buildHarness(
        disabled: true,
        onExport: (format, meta) {
          callbackCount++;
        },
      ));

      await tester.tap(find.byKey(const Key('bc-export-trigger')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-export-item-csv')), findsNothing);
      expect(callbackCount, 0);
    });

    testWidgets(
        'loading shows a progress indicator on the trigger (ADR-014)',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: BcExport(
              formats: const [BcExportFormat.csv],
              loading: true,
            ),
          ),
        ),
      ));

      // The trigger renders and shows a CircularProgressIndicator while loading.
      expect(find.byKey(const Key('bc-export-trigger')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'displays custom label text (VAL-M6-027)', (tester) async {
      await tester.pumpWidget(buildHarness(label: 'Download'));

      expect(find.text('Download'), findsOneWidget);
    });
  });
}
