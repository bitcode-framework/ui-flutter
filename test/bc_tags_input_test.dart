import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_tags_input.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcTagsInput child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('BcTagsInput — VAL-M2-013', () {
    testWidgets('Enter adds a tag and emits updated list with input reason', (tester) async {
      List<String>? emitted;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcTagsInput(
          defaultValue: const ['alpha'],
          onChange: (v, m) {
            emitted = v;
            meta = m;
          },
        ),
      ));

      await tester.enterText(find.byKey(const Key('bc_tags_input_field')), 'beta');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      expect(emitted, ['alpha', 'beta']);
      expect(meta!.reason, BcChangeReason.input);
      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
    });

    testWidgets('Comma adds a tag and clears the input', (tester) async {
      List<String>? emitted;

      await tester.pumpWidget(harness(
        child: BcTagsInput(
          onChange: (v, _) => emitted = v,
        ),
      ));

      await tester.enterText(find.byKey(const Key('bc_tags_input_field')), 'tag1,');
      await tester.pump();

      expect(emitted, ['tag1']);
      expect(find.text('tag1'), findsOneWidget);
    });
  });

  group('BcTagsInput — VAL-M2-014', () {
    testWidgets('Backspace on empty input removes the last tag', (tester) async {
      List<String>? emitted;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcTagsInput(
          defaultValue: const ['one', 'two'],
          onChange: (v, m) {
            emitted = v;
            meta = m;
          },
        ),
      ));

      expect(find.text('two'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bc_tags_input_field')));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(emitted, ['one']);
      expect(meta!.reason, BcChangeReason.back);
      expect(find.text('two'), findsNothing);
    });

    testWidgets('Chip remove button removes that specific tag', (tester) async {
      List<String>? emitted;
      BcChangeMeta? meta;

      await tester.pumpWidget(harness(
        child: BcTagsInput(
          defaultValue: const ['keep', 'remove'],
          onChange: (v, m) {
            emitted = v;
            meta = m;
          },
        ),
      ));

      final removeBtn = find.byKey(const Key('bc_tags_input_remove_1'));
      expect(removeBtn, findsOneWidget);

      await tester.tap(removeBtn);
      await tester.pumpAndSettle();

      expect(emitted, ['keep']);
      expect(meta!.reason, BcChangeReason.deselect);
      expect(find.text('remove'), findsNothing);
      expect(find.text('keep'), findsOneWidget);
    });
  });

  group('BcTagsInput — VAL-M2-015', () {
    testWidgets('maxTags blocks further adds', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        child: BcTagsInput(
          defaultValue: const ['a', 'b', 'c'],
          maxTags: 3,
          onChange: (_, __) => callCount++,
        ),
      ));

      await tester.enterText(find.byKey(const Key('bc_tags_input_field')), 'd');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(callCount, 0);
      expect(find.text('d'), findsNothing);
    });

    testWidgets('disabled ignores all input', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        child: BcTagsInput(
          defaultValue: const ['a'],
          disabled: true,
          onChange: (_, __) => callCount++,
        ),
      ));

      await tester.tap(find.byKey(const Key('bc_tags_input_remove_0')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('bc_tags_input_field')), 'b');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(callCount, 0);
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('renders label and required marker', (tester) async {
      await tester.pumpWidget(harness(
        child: const BcTagsInput(
          label: 'Tags',
          required: true,
          placeholder: 'Add tags...',
        ),
      ));

      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('Add tags...'), findsOneWidget);
    });
  });
}
