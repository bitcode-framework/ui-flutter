import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_code.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  group('BcCode', () {
    testWidgets('renders label and code editor (VAL-CODE-001)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcCode(label: 'Source', value: 'void main() {}'),
          ),
        ),
      );

      expect(find.text('Source'), findsOneWidget);
      expect(find.byKey(const Key('bc-code-editor')), findsOneWidget);
    });

    testWidgets('editing emits code string with input reason and keyboard source (VAL-CODE-002)',
        (tester) async {
      String? captured;
      BcChangeMeta? meta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcCode(
              language: 'dart',
              value: 'void main() {}',
              onValueChange: (v, m) {
                captured = v;
                meta = m;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(const Key('bc-code-editor')), 'print("hi");');
      await tester.pump();

      expect(captured, 'print("hi");');
      expect(meta?.reason, BcChangeReason.input);
      expect(meta?.source, BcEventSource.keyboard);
    });

    testWidgets('language badge shown when language is not text (VAL-CODE-003)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcCode(language: 'python', value: 'print(1)'),
          ),
        ),
      );

      expect(find.text('python'), findsOneWidget);
    });

    testWidgets('language badge hidden when language is text (VAL-CODE-004)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcCode(language: 'text', value: 'plain'),
          ),
        ),
      );

      expect(find.text('text'), findsNothing);
    });

    testWidgets('syntax highlighting applies keyword color for dart (VAL-CODE-005)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcCode(language: 'dart', value: 'void main() {}'),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-code-highlighted')), findsOneWidget);
      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byKey(const Key('bc-code-highlighted')),
          matching: find.byType(RichText),
        ),
      );
      final span = richText.text as TextSpan;
      final hasKeywordColor =
          span.children!.any((c) => (c as TextSpan).style?.color != null);
      expect(hasKeywordColor, isTrue);
    });

    testWidgets('disabled code editor blocks edits but still renders highlighted content (VAL-CODE-006)',
        (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcCode(
              language: 'dart',
              value: 'void main() {}',
              disabled: true,
              onValueChange: (v, m) {
                callCount++;
              },
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-code-highlighted')), findsOneWidget);

      final textField = tester.widget<TextField>(
        find.byKey(const Key('bc-code-editor')),
      );
      expect(textField.enabled, isFalse);
      expect(callCount, 0);
    });

    testWidgets('controlled value syncs editor content (VAL-CODE-007)',
        (tester) async {
      String value = 'a = 1';

      late StateSetter setStateRef;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateRef = setState;
                return BcCode(language: 'python', value: value);
              },
            ),
          ),
        ),
      );

      setStateRef(() {
        value = 'a = 2';
      });
      await tester.pumpAndSettle();

      expect(find.text('a = 2'), findsWidgets);
    });

    testWidgets('rows controls the visible line count of the editor viewport (VAL-CODE-008)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcCode(rows: 12, value: 'line1\nline2'),
          ),
        ),
      );

      final constrained = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byKey(const Key('bc-code-editor')),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrained.constraints.minHeight, greaterThanOrEqualTo(12 * 18.0));
    });

    testWidgets('required marker renders asterisk (VAL-CODE-009)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcCode(label: 'Snippet', required: true),
          ),
        ),
      );

      expect(find.text('Snippet'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('monospace font family applied (VAL-CODE-010)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcCode(value: 'x'),
          ),
        ),
      );

      final textField = tester.widget<TextField>(
        find.byKey(const Key('bc-code-editor')),
      );
      expect(textField.style?.fontFamily, 'monospace');
    });
  });
}
