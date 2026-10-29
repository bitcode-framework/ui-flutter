import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_json.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  group('BcJson', () {
    testWidgets('renders label and raw textarea by default (VAL-JSON-001)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcJson(label: 'Config', value: '{"k":1}'),
          ),
        ),
      );

      expect(find.text('Config'), findsOneWidget);
      expect(find.byKey(const Key('bc-json-raw-editor')), findsOneWidget);
    });

    testWidgets('raw-mode edit emits parsed/serialized JSON with input reason (VAL-JSON-002)',
        (tester) async {
      String? captured;
      BcChangeMeta? meta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcJson(
              value: '{"a":1}',
              onValueChange: (v, m) {
                captured = v;
                meta = m;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(const Key('bc-json-raw-editor')), '{"b":2}');
      await tester.pump();

      expect(captured, '{"b":2}');
      expect(meta?.reason, BcChangeReason.input);
    });

    testWidgets('invalid JSON surfaces error indicator without emitting a new value (VAL-JSON-003)',
        (tester) async {
      String? captured;
      int callCount = 0;

      late StateSetter setStateRef;
      String value = '{"a":1}';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateRef = setState;
                return BcJson(
                  value: value,
                  onValueChange: (v, m) {
                    captured = v;
                    callCount++;
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(const Key('bc-json-raw-editor')), '{invalid');
      await tester.pump();

      expect(find.text('Invalid JSON'), findsOneWidget);
      expect(callCount, 1);
      expect(captured, '{invalid');

      setStateRef(() {});
      await tester.pump();
    });

    testWidgets('valid JSON shows no error indicator (VAL-JSON-004)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcJson(value: '{"valid": true}'),
          ),
        ),
      );

      expect(find.text('Invalid JSON'), findsNothing);
    });

    testWidgets('tree/raw view toggle does not emit onValueChange (VAL-JSON-005)',
        (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcJson(
              value: '{"k": 1}',
              onValueChange: (v, m) {
                callCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('bc-json-view-toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-json-tree-view')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc-json-view-toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bc-json-raw-editor')), findsOneWidget);
      expect(callCount, 0);
    });

    testWidgets('tree view renders keys and values (VAL-JSON-006)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcJson(
              value: '{"name": "Alice", "age": 30}',
              defaultView: BcJsonView.tree,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bc-json-tree-view')), findsOneWidget);
      expect(find.text('name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('age'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('disabled blocks edits in raw mode (VAL-JSON-007)',
        (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcJson(
              value: '{"a":1}',
              disabled: true,
              onValueChange: (v, m) {
                callCount++;
              },
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(
        find.byKey(const Key('bc-json-raw-editor')),
      );
      expect(textField.enabled, isFalse);
      expect(callCount, 0);
    });

    testWidgets('disabled blocks view toggle interaction (VAL-JSON-008)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcJson(value: '{"a":1}', disabled: true),
          ),
        ),
      );

      final toggle = tester.widget<IconButton>(
        find.byKey(const Key('bc-json-view-toggle')),
      );
      expect(toggle.onPressed, isNull);
    });

    testWidgets('controlled value syncs displayed content (VAL-JSON-009)',
        (tester) async {
      String value = '{"x": 1}';

      late StateSetter setStateRef;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateRef = setState;
                return BcJson(value: value);
              },
            ),
          ),
        ),
      );

      setStateRef(() {
        value = '{"x": 2}';
      });
      await tester.pumpAndSettle();

      expect(find.text('{"x": 2}'), findsWidgets);
    });

    testWidgets('required marker renders asterisk (VAL-JSON-010)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BcJson(label: 'Payload', required: true),
          ),
        ),
      );

      expect(find.text('Payload'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('format on blur pretty-prints valid JSON (VAL-JSON-011)',
        (tester) async {
      String? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BcJson(
              value: '{"b":2,"a":1}',
              onValueChange: (v, m) {
                captured = v;
              },
            ),
          ),
        ),
      );

      final editor = find.byKey(const Key('bc-json-raw-editor'));
      await tester.enterText(editor, '{"a":1,"b":2}');
      await tester.pump();

      editor;
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.contains('\n'), isTrue);
    });
  });
}
