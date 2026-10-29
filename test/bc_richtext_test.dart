import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_richtext.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  group('BcRichText', () {
    testWidgets('renders label and editable region (VAL-RT-001)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcRichText(label: 'Body', value: 'hello'),
          ),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(find.byKey(const Key('bc-richtext-editor')), findsOneWidget);
    });

    testWidgets('renders placeholder when empty (VAL-RT-002)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcRichText(placeholder: 'Start typing...'),
          ),
        ),
      );

      expect(find.text('Start typing...'), findsOneWidget);
    });

    testWidgets('uncontrolled typing emits value with input meta (VAL-RT-003)',
        (tester) async {
      String? captured;
      BcChangeMeta? meta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRichText(
              onValueChange: (v, m) {
                captured = v;
                meta = m;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(const Key('bc-richtext-editor')), 'hi there');
      await tester.pump();

      expect(captured, 'hi there');
      expect(meta?.reason, BcChangeReason.input);
    });

    testWidgets('bold toolbar toggle wraps selection and emits valueChange meta (VAL-RT-004)',
        (tester) async {
      String? captured;
      BcChangeMeta? meta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRichText(
              value: 'hello',
              onValueChange: (v, m) {
                captured = v;
                meta = m;
              },
            ),
          ),
        ),
      );

      final editor = find.byKey(const Key('bc-richtext-editor'));
      await tester.tap(editor);
      await tester.pump();
      await tester.enterText(editor, 'hello');
      await tester.pump();

      await tester.tap(find.byKey(const Key('bc-richtext-toolbar-bold')));
      await tester.pump();

      expect(captured, isNotNull);
      expect(meta?.reason, BcChangeReason.valueChange);
      expect(meta?.source, BcEventSource.pointer);
      expect(captured!.contains('<b>'), isTrue);
      expect(captured!.contains('hello'), isTrue);
    });

    testWidgets('italic and underline toolbar toggles also emit valueChange (VAL-RT-005)',
        (tester) async {
      final List<String> captured = [];
      final List<BcChangeReason> reasons = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRichText(
              value: 'word',
              onValueChange: (v, m) {
                captured.add(v);
                reasons.add(m.reason);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-richtext-toolbar-italic')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('bc-richtext-toolbar-underline')));
      await tester.pump();

      expect(captured.length, greaterThanOrEqualTo(2));
      for (final r in reasons) {
        expect(r, BcChangeReason.valueChange);
      }
      expect(captured[0].contains('<i>'), isTrue);
      expect(captured[1].contains('<u>'), isTrue);
    });

    testWidgets('clear toolbar button resets to empty with clear reason (VAL-RT-006)',
        (tester) async {
      String? captured;
      BcChangeReason? reason;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRichText(
              value: 'some content',
              onValueChange: (v, m) {
                captured = v;
                reason = m.reason;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-richtext-toolbar-clear')));
      await tester.pump();

      expect(captured, '');
      expect(reason, BcChangeReason.clear);
    });

    testWidgets('disabled editor is read-only and blocks toolbar + typing (VAL-RT-007)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcRichText(
              value: 'frozen',
              disabled: true,
              onValueChange: (v, m) {
                callCount++;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(const Key('bc-richtext-editor')), 'changed');
      await tester.pump();

      await tester.tap(find.byKey(const Key('bc-richtext-toolbar-bold')));
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('controlled value prop drives displayed content (VAL-RT-008)',
        (tester) async {
      String value = 'first';

      late StateSetter setStateRef;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateRef = setState;
                return BcRichText(value: value);
              },
            ),
          ),
        ),
      );

      expect(find.text('first'), findsWidgets);

      setStateRef(() {
        value = 'second';
      });
      await tester.pumpAndSettle();

      expect(find.text('second'), findsWidgets);
      expect(find.text('first'), findsNothing);
    });

    testWidgets('required marker renders asterisk (VAL-RT-009)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcRichText(label: 'Notes', required: true),
          ),
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('rows controls minimum editor height (VAL-RT-010)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcRichText(rows: 10),
          ),
        ),
      );

      final sizedBox = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byKey(const Key('bc-richtext-editor')),
          matching: find.byType(ConstrainedBox),
        ),
      );
      final constraint = sizedBox.constraints;
      expect(constraint.minHeight, greaterThanOrEqualTo(10 * 20.0));
    });
  });
}
