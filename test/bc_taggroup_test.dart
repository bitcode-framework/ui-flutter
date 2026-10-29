import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/src/components/bc_taggroup.dart';

void main() {
  final initialTags = <BcTagGroupTag>[
    const BcTagGroupTag(label: 'Dart', value: 'dart'),
    const BcTagGroupTag(label: 'Flutter', value: 'flutter'),
    const BcTagGroupTag(label: 'Go', value: 'go'),
  ];

  Widget harness(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets(
      'BcTagGroup renders tags from value list '
      '(VAL-M5-008)', (tester) async {
    await tester.pumpWidget(harness(
      BcTagGroup(tags: initialTags),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Go'), findsOneWidget);

    expect(find.byKey(const Key('bc_taggroup_tag_dart')), findsOneWidget);
    expect(find.byKey(const Key('bc_taggroup_tag_flutter')), findsOneWidget);
    expect(find.byKey(const Key('bc_taggroup_tag_go')), findsOneWidget);
  });

  testWidgets(
      'BcTagGroup remove control deletes the tag '
      '(VAL-M5-008)', (tester) async {
    List<BcTagGroupTag>? emittedTags;
    var metaCount = 0;

    await tester.pumpWidget(harness(
      BcTagGroup(
        tags: initialTags,
        removable: true,
        onChange: (tags, meta) {
          emittedTags = tags;
          metaCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_taggroup_remove_dart')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bc_taggroup_remove_dart')));
    await tester.pumpAndSettle();

    expect(emittedTags, isNotNull);
    expect(emittedTags!.length, 2,
        reason: 'After removing Dart, 2 tags should remain');
    expect(emittedTags!.any((t) => t.value == 'dart'), isFalse);
    expect(metaCount, 1);
  });

  testWidgets(
      'BcTagGroup removable false hides remove controls '
      '(VAL-M5-008)', (tester) async {
    await tester.pumpWidget(harness(
      BcTagGroup(tags: initialTags, removable: false),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bc_taggroup_remove_dart')), findsNothing);
  });

  testWidgets(
      'BcTagGroup adding a tag appends and emits '
      '(VAL-M5-009)', (tester) async {
    List<BcTagGroupTag>? emittedTags;
    var metaCount = 0;

    await tester.pumpWidget(harness(
      BcTagGroup(
        tags: initialTags,
        addable: true,
        onChange: (tags, meta) {
          emittedTags = tags;
          metaCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('bc_taggroup_input')),
      'Rust',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(emittedTags, isNotNull);
    expect(emittedTags!.length, 4,
        reason: 'After adding Rust, 4 tags should exist');
    expect(emittedTags!.any((t) => t.value == 'rust'), isTrue);
    expect(metaCount, 1);
  });

  testWidgets(
      'BcTagGroup rejects empty and whitespace-only labels '
      '(VAL-M5-009)', (tester) async {
    var metaCount = 0;

    await tester.pumpWidget(harness(
      BcTagGroup(
        tags: initialTags,
        addable: true,
        onChange: (tags, meta) {
          metaCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('bc_taggroup_input')),
      '   ',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(metaCount, 0, reason: 'Whitespace-only label should be rejected');
  });

  testWidgets(
      'BcTagGroup rejects duplicates when allowDuplicates is false '
      '(VAL-M5-009)', (tester) async {
    var metaCount = 0;

    await tester.pumpWidget(harness(
      BcTagGroup(
        tags: initialTags,
        addable: true,
        allowDuplicates: false,
        onChange: (tags, meta) {
          metaCount++;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('bc_taggroup_input')),
      'Dart',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(metaCount, 0,
        reason: 'Duplicate label should be rejected');
  });

  testWidgets(
      'BcTagGroup allows duplicates when allowDuplicates is true '
      '(VAL-M5-009)', (tester) async {
    List<BcTagGroupTag>? emittedTags;

    await tester.pumpWidget(harness(
      BcTagGroup(
        tags: initialTags,
        addable: true,
        allowDuplicates: true,
        onChange: (tags, meta) {
          emittedTags = tags;
        },
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('bc_taggroup_input')),
      'Dart',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(emittedTags, isNotNull);
    expect(emittedTags!.length, 4,
        reason: 'Duplicate should be allowed when allowDuplicates is true');
    expect(
      emittedTags!.where((t) => t.label == 'Dart').length,
      2,
    );
  });

  testWidgets(
      'BcTagGroup max display count truncates and shows overflow '
      '(VAL-M5-010)', (tester) async {
    final manyTags = List.generate(
      6,
      (i) => BcTagGroupTag(label: 'Tag$i', value: 'tag_$i'),
    );

    await tester.pumpWidget(harness(
      BcTagGroup(tags: manyTags, max: 3),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tag0'), findsOneWidget);
    expect(find.text('Tag1'), findsOneWidget);
    expect(find.text('Tag2'), findsOneWidget);
    expect(find.text('Tag3'), findsNothing,
        reason: 'Tag3 should be truncated');
    expect(find.text('+3 more'), findsOneWidget,
        reason: 'Overflow indicator should show hidden count');
  });

  testWidgets(
      'BcTagGroup max with fewer tags shows no overflow '
      '(VAL-M5-010)', (tester) async {
    await tester.pumpWidget(harness(
      BcTagGroup(tags: initialTags, max: 5),
    ));
    await tester.pumpAndSettle();

    expect(find.text('+'), findsNothing,
        reason: 'No overflow when tags fit within max');
  });
}
