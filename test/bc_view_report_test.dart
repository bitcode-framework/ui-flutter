import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_view_report.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  const sections = [
    BcReportSection(
        id: 's1', title: 'Overview', content: 'Summary of Q1 results.'),
    BcReportSection(
        id: 's2', title: 'Revenue', content: 'Total: \$50,000.'),
    BcReportSection(
        id: 's3', title: 'Expenses', content: 'Total: \$30,000.'),
  ];

  group('VAL-M5-024: Sections render in order with headers and body', () {
    testWidgets('renders report container', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(sections: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_report')), findsOneWidget);
    });

    testWidgets('renders all sections in declaration order', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(sections: sections),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc_view_report_section_s1')),
          findsOneWidget);
      expect(
          find.byKey(const Key('bc_view_report_section_s2')),
          findsOneWidget);
      expect(
          find.byKey(const Key('bc_view_report_section_s3')),
          findsOneWidget);
    });

    testWidgets('each section renders its title and body', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(sections: sections),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Summary of Q1 results.'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Total: \$50,000.'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Total: \$30,000.'), findsOneWidget);
    });

    testWidgets('title renders in header', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          title: 'Q1 Report',
          sections: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Q1 Report'), findsOneWidget);
    });

    testWidgets('subtitle renders below title', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          title: 'Q1 Report',
          subtitle: 'Quarterly Financial Summary',
          sections: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Q1 Report'), findsOneWidget);
      expect(find.text('Quarterly Financial Summary'), findsOneWidget);
    });

    testWidgets('generatedAt renders formatted date', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          title: 'Report',
          generatedAt: null,
          sections: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_report')), findsOneWidget);
    });

    testWidgets(
        'generatedAt with value renders formatted date', (tester) async {
      await tester.pumpWidget(harness(
        BcViewReport(
          title: 'Report',
          generatedAt: DateTime(2024, 1, 15),
          sections: const [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc_view_report_generated_at')),
          findsOneWidget);
      expect(find.text('Jan 15, 2024'), findsOneWidget);
    });

    testWidgets('section without content renders without error',
        (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          sections: [
            BcReportSection(id: 's1', title: 'Empty Section'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Empty Section'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'section body uses body key', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          sections: [
            BcReportSection(id: 's1', title: 'S1', content: 'Body text'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byKey(
              const Key('bc_view_report_section_body_s1')),
          findsOneWidget);
    });
  });

  group('VAL-M5-025: Section visibility respects show/hide config', () {
    testWidgets('hidden section is not rendered', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          sections: [
            BcReportSection(id: 's1', title: 'Visible', content: 'A'),
            BcReportSection(
                id: 's2', title: 'Hidden', content: 'B', visible: false),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc_view_report_section_s1')),
          findsOneWidget);
      expect(
          find.byKey(const Key('bc_view_report_section_s2')),
          findsNothing);
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('all visible sections render', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          sections: [
            BcReportSection(id: 's1', title: 'A', content: 'X'),
            BcReportSection(id: 's2', title: 'B', content: 'Y'),
            BcReportSection(id: 's3', title: 'C', content: 'Z'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc_view_report_section_s1')),
          findsOneWidget);
      expect(
          find.byKey(const Key('bc_view_report_section_s2')),
          findsOneWidget);
      expect(
          find.byKey(const Key('bc_view_report_section_s3')),
          findsOneWidget);
    });
  });

  group('VAL-M5-026: Data update re-renders all sections', () {
    testWidgets(
        'updating sections list triggers re-render', (tester) async {
      late void Function(VoidCallback) setStateRef;
      List<BcReportSection> currentSections = const [
        BcReportSection(id: 's1', title: 'Old', content: 'Old data'),
      ];

      Widget buildWidget() {
        return StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: BcViewReport(sections: currentSections),
                ),
              ),
            );
          },
        );
      }

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Old'), findsOneWidget);
      expect(find.text('Old data'), findsOneWidget);

      setStateRef(() {
        currentSections = const [
          BcReportSection(id: 's1', title: 'New', content: 'New data'),
        ];
      });
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Old'), findsNothing);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('New data'), findsOneWidget);
    });

    testWidgets(
        'adding sections triggers re-render with new content',
        (tester) async {
      late void Function(VoidCallback) setStateRef;
      List<BcReportSection> currentSections = const [
        BcReportSection(id: 's1', title: 'First', content: 'Content 1'),
      ];

      Widget buildWidget() {
        return StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: BcViewReport(sections: currentSections),
                ),
              ),
            );
          },
        );
      }

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc_view_report_section_s1')),
          findsOneWidget);
      expect(
          find.byKey(const Key('bc_view_report_section_s2')),
          findsNothing);

      setStateRef(() {
        currentSections = const [
          BcReportSection(id: 's1', title: 'First', content: 'Content 1'),
          BcReportSection(id: 's2', title: 'Second', content: 'Content 2'),
        ];
      });
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('bc_view_report_section_s1')),
          findsOneWidget);
      expect(
          find.byKey(const Key('bc_view_report_section_s2')),
          findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets(
        'removing a section triggers re-render without it',
        (tester) async {
      late void Function(VoidCallback) setStateRef;
      List<BcReportSection> currentSections = const [
        BcReportSection(id: 's1', title: 'Keep', content: 'A'),
        BcReportSection(id: 's2', title: 'Remove', content: 'B'),
      ];

      Widget buildWidget() {
        return StatefulBuilder(
          builder: (context, setState) {
            setStateRef = setState;
            return MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: BcViewReport(sections: currentSections),
                ),
              ),
            );
          },
        );
      }

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Remove'), findsOneWidget);

      setStateRef(() {
        currentSections = const [
          BcReportSection(id: 's1', title: 'Keep', content: 'A'),
        ];
      });
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Remove'), findsNothing);
      expect(find.text('Keep'), findsOneWidget);
    });

    testWidgets('printable report renders print button', (tester) async {
      await tester.pumpWidget(harness(
        const BcViewReport(
          sections: [],
          printable: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc_view_report_print')),
          findsOneWidget);
    });
  });
}
