import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_mentions.dart';
import 'package:bc_ui_flutter/src/core/types.dart';

void main() {
  Widget harness({required BcMentions child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  final options = <BcMentionOption>[
    const BcMentionOption(value: 'alice', label: 'Alice'),
    const BcMentionOption(value: 'bob', label: 'Bob'),
    const BcMentionOption(value: 'charlie', label: 'Charlie Brown'),
  ];

  group('BcMentions — VAL-M2-037', () {
    testWidgets('Typing @ opens a fuzzy-matched suggestion dropdown', (tester) async {
      await tester.pumpWidget(harness(
        child: BcMentions(
          options: options,
        ),
      ));

      await tester.enterText(find.byKey(const Key('bc_mentions_field')), '@al');
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
      expect(find.text('Charlie Brown'), findsNothing);
    });

    testWidgets('Dropdown closes when token has space', (tester) async {
      await tester.pumpWidget(harness(
        child: BcMentions(options: options),
      ));

      await tester.enterText(find.byKey(const Key('bc_mentions_field')), '@al test');
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsNothing);
    });
  });

  group('BcMentions — VAL-M2-038', () {
    testWidgets('Picking a suggestion replaces the token and fires onChange + onSelect', (tester) async {
      String? changedValue;
      BcChangeMeta? changedMeta;
      BcMentionOption? selected;

      await tester.pumpWidget(harness(
        child: BcMentions(
          options: options,
          onChange: (v, m) {
            changedValue = v;
            changedMeta = m;
          },
          onSelect: (o) => selected = o,
        ),
      ));

      await tester.enterText(find.byKey(const Key('bc_mentions_field')), '@al');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alice').last);
      await tester.pumpAndSettle();

      expect(changedValue, '@alice ');
      expect(changedMeta!.reason, BcChangeReason.valueChange);
      expect(selected, isNotNull);
      expect(selected!.value, 'alice');
    });
  });

  group('BcMentions — VAL-M2-039', () {
    testWidgets('Free typing emits onChange with input reason', (tester) async {
      String? changedValue;
      BcChangeMeta? changedMeta;

      await tester.pumpWidget(harness(
        child: BcMentions(
          options: options,
          onChange: (v, m) {
            changedValue = v;
            changedMeta = m;
          },
        ),
      ));

      await tester.enterText(find.byKey(const Key('bc_mentions_field')), 'hello world');
      await tester.pump();

      expect(changedValue, 'hello world');
      expect(changedMeta!.reason, BcChangeReason.input);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('Disabled blocks typing and suggestions', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(harness(
        child: BcMentions(
          options: options,
          disabled: true,
          onChange: (_, __) => callCount++,
        ),
      ));

      await tester.enterText(find.byKey(const Key('bc_mentions_field')), '@al');
      await tester.pumpAndSettle();

      expect(callCount, 0);
      expect(find.text('Alice'), findsNothing);
    });
  });
}
