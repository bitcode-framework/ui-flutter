import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_markdown.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  group('BcMarkdown', () {
    testWidgets('renders label and markdown editor (VAL-MD-001)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcMarkdown(label: 'Docs', value: '# Title'),
          ),
        ),
      );

      expect(find.text('Docs'), findsOneWidget);
      expect(find.byKey(const Key('bc-markdown-editor')), findsOneWidget);
    });

    testWidgets('editing emits markdown string with input reason (VAL-MD-002)',
        (tester) async {
      String? captured;
      BcChangeMeta? meta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMarkdown(
              value: '# Hi',
              onValueChange: (v, m) {
                captured = v;
                meta = m;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(const Key('bc-markdown-editor')), '# Hello World');
      await tester.pump();

      expect(captured, '# Hello World');
      expect(meta?.reason, BcChangeReason.input);
    });

    testWidgets('preview mode renders formatted markdown (VAL-MD-003)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcMarkdown(
              value: '# Heading',
              defaultView: BcMarkdownView.preview,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-markdown-preview')), findsOneWidget);
      expect(find.text('Heading'), findsWidgets);
    });

    testWidgets('view toggle does not emit onValueChange (VAL-MD-004)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMarkdown(
              value: '# Hi',
              onValueChange: (v, m) {
                callCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-markdown-view-toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-markdown-preview')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-markdown-view-toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-markdown-editor')), findsOneWidget);
      expect(callCount, 0);
    });

    testWidgets('bold toolbar inserts markdown bold syntax (VAL-MD-005)',
        (tester) async {
      String? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMarkdown(
              value: 'word',
              onValueChange: (v, m) {
                captured = v;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-markdown-toolbar-bold')));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.contains('**'), isTrue);
      expect(captured!.contains('word'), isTrue);
    });

    testWidgets('disabled blocks edits and toolbar (VAL-MD-006)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcMarkdown(
              value: '# frozen',
              disabled: true,
              onValueChange: (v, m) {
                callCount++;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(const Key('bc-markdown-editor')), 'changed');
      await tester.pump();

      await tester.tap(find.byKey(const Key('bc-markdown-toolbar-bold')));
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('controlled value syncs editor content (VAL-MD-007)',
        (tester) async {
      String value = '# First';

      late StateSetter setStateRef;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateRef = setState;
                return BcMarkdown(value: value);
              },
            ),
          ),
        ),
      );

      setStateRef(() {
        value = '# Second';
      });
      await tester.pumpAndSettle();

      expect(find.text('# Second'), findsWidgets);
    });

    testWidgets('required marker renders asterisk (VAL-MD-008)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcMarkdown(label: 'Content', required: true),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('rows controls minimum editor height (VAL-MD-009)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcMarkdown(rows: 14),
          ),
        ),
      );

      final constrained = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byKey(const Key('bc-markdown-editor')),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrained.constraints.minHeight, greaterThanOrEqualTo(14 * 18.0));
    });

    testWidgets('preview renders heading and list items (VAL-MD-010)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcMarkdown(
              value: '# Title\n- item one\n- item two',
              defaultView: BcMarkdownView.preview,
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsWidgets);
      expect(find.text('item one'), findsOneWidget);
      expect(find.text('item two'), findsOneWidget);
    });
  });
}
